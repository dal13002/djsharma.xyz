# Zone info
data "cloudflare_zones" "dj_domain" {
  filter {
    name = "djsharma.xyz"
  }
}

# A record for AWS server
resource "cloudflare_record" "www" {
  zone_id = lookup(data.cloudflare_zones.dj_domain.zones[0], "id")
  name    = "www"
  value   = aws_instance.web.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}
