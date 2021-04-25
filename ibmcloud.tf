# Kuberntes cluster
resource "ibm_container_cluster" "dj_cluster" {
  name         = local.resource_name_tag
  datacenter   = "dal10" # required
  hardware     = "shared"
  wait_till    = "OneWorkerNodeReady"
  machine_type = "free"

  lifecycle {
    ignore_changes = [
      datacenter # ibm cloud requires `datacenter` but does not respect it for free clusters
    ]
  }
}

# Get the cluster's info to send to k8s provider
data "ibm_container_cluster_config" "dj_cluster" {
  cluster_name_id = ibm_container_cluster.dj_cluster.id
  admin           = true
  network         = true
  config_dir      = "/tmp"
}

# Calico polices for cloud flare allow list
# TODO: write a custom calico provider as it does not exist
resource "null_resource" "calico_setup" {
  # Since the cluster ID will only change one time, this will only run one time- after
  # the cluster is done provisioning
  triggers = {
    cluster_id = ibm_container_cluster.dj_cluster.id
  }

  provisioner "local-exec" {
    command     = "tf_files/k8s_calico_setup.sh"
    interpreter = ["bash"]

    environment = {
      CONFIGFILE = data.ibm_container_cluster_config.dj_cluster.calico_config_file_path
    }
  }
}

# Namespace
resource "kubernetes_namespace" "dj_namespace" {
  metadata {
    name = local.resource_name_tag
  }
}

# Configmap for nginx config
resource "kubernetes_config_map" "nginx_conf" {
  metadata {
    name      = "nginx-conf"
    namespace = local.resource_name_tag
  }

  data = {
    "nginx.conf" = file("tf_files/k8s_nginx_config.txt")
  }

  depends_on = [kubernetes_namespace.dj_namespace]
}

# Configmap for script for additional nginx setup
resource "kubernetes_config_map" "nginx_setup" {
  metadata {
    name      = "nginx-setup"
    namespace = local.resource_name_tag
  }

  data = {
    "setup.sh" = file("tf_files/k8s_startup.sh")
  }

  depends_on = [kubernetes_namespace.dj_namespace]
}

# Website (nginx) deployment
###########################################################################################
# IMPORTANT NOTES: 
# 1. We are running this on the host network on 443 instead of using "ingress" cause IKS does not support 
# ingress (floating IPs) for free clusters
# 2. We are not using nodeport, which would be the next logically step, because free cloudflare wants :443
# when proxying our DNS request. This would not be the case if we were paying for load balancing
###########################################################################################
resource "kubernetes_deployment" "dj_personal_app" {
  metadata {
    name      = local.resource_name_tag
    namespace = local.resource_name_tag
    labels = {
      app = local.resource_name_tag
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.resource_name_tag
      }
    }

    template {
      metadata {
        labels = {
          app = local.resource_name_tag
        }
      }

      spec {
        host_network = true

        container {
          image = "nginx:latest"
          name  = local.resource_name_tag

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          port {
            container_port = 443
            host_port      = 443
            protocol       = "TCP"
          }

          volume_mount {
            mount_path = "/etc/nginx/nginx.conf"
            name       = "config"
            sub_path   = "nginx.conf"
          }
          volume_mount {
            mount_path = "/docker-entrypoint.d/setup.sh"
            name       = "setup"
            sub_path   = "setup.sh"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.nginx_conf.metadata[0].name
            items {
              key  = "nginx.conf"
              path = "nginx.conf"
            }
          }
        }
        volume {
          name = "setup"
          config_map {
            name = kubernetes_config_map.nginx_setup.metadata[0].name
            items {
              key  = "setup.sh"
              path = "setup.sh"
            }
            default_mode = "0777" # in production would want to set correct permissions
          }
        }
      }
    }
  }
}

# Expose the pod as nodeport
# resource "kubernetes_service" "dj_app_svc" {
#   metadata {
#     name      = local.resource_name_tag
#     namespace = local.resource_name_tag
#   }
#   spec {
#     selector = {
#       app = local.resource_name_tag
#     }
#     port {
#       port        = 443
#       target_port = 443
#     }

#     type = "NodePort"
#   }
# }

data "ibm_container_cluster_worker" "dj_cluster_solo_worker" {
  worker_id = ibm_container_cluster.dj_cluster.workers_info[0].id
}
