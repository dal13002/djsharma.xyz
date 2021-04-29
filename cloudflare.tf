# Zone info
data "cloudflare_zones" "dj_domain" {
  filter {
    name = local.domain_name
  }
}

# A record for AWS server
resource "cloudflare_record" "aws_web" {
  zone_id = lookup(data.cloudflare_zones.dj_domain.zones[0], "id")
  name    = local.domain_name
  value   = aws_instance.web.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

# Unique a record for AWS server 
# Easier for debugging since direct link to aws- would not need this in prod
resource "cloudflare_record" "aws_unqiue_web" {
  zone_id = lookup(data.cloudflare_zones.dj_domain.zones[0], "id")
  name    = "aws-app"
  value   = aws_instance.web.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

# A record for ibm cloud k8s
resource "cloudflare_record" "ibmcloud_web" {
  zone_id = lookup(data.cloudflare_zones.dj_domain.zones[0], "id")
  name    = local.domain_name
  value   = data.ibm_container_cluster_worker.dj_cluster_solo_worker.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

# Unique a record for ibmcloud k8s 
# Easier for debugging since direct link to ibm cloud- would not need this in prod
resource "cloudflare_record" "ibmcloud_unqiue_web" {
  zone_id = lookup(data.cloudflare_zones.dj_domain.zones[0], "id")
  name    = "ibmcloud-app"
  value   = data.ibm_container_cluster_worker.dj_cluster_solo_worker.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

# A record for azure vm
resource "cloudflare_record" "azure_web" {
  zone_id = lookup(data.cloudflare_zones.dj_domain.zones[0], "id")
  name    = local.domain_name
  value   = azurerm_linux_virtual_machine.web_server.public_ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}

# Unique a record for azure vm
# Easier for debugging since direct link to azure- would not need this in prod
resource "cloudflare_record" "azure_unqiue_web" {
  zone_id = lookup(data.cloudflare_zones.dj_domain.zones[0], "id")
  name    = "azure-app"
  value   = azurerm_linux_virtual_machine.web_server.public_ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}
