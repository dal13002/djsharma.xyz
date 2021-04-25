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

# TXT record for AWS server 
# Easier for debugging- would not do this in prod as we want to keep our ips as secret as we can
resource "cloudflare_record" "aws_txt" {
  zone_id = lookup(data.cloudflare_zones.dj_domain.zones[0], "id")
  name    = "_aws_web"
  value   = aws_instance.web.public_ip
  type    = "TXT"
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

# TXT record for ibm cloud k8s
# Easier for debugging- would not do this in prod as we want to keep our ips as secret as we can
resource "cloudflare_record" "ibmcloud_txt" {
  zone_id = lookup(data.cloudflare_zones.dj_domain.zones[0], "id")
  name    = "_ibmcloud_web"
  value   = data.ibm_container_cluster_worker.dj_cluster_solo_worker.public_ip
  type    = "TXT"
}
