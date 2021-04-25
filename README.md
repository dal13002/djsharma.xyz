# Infrastructure as code for personal site
This repo contains all code needed to create the infrastructure and application deployment for djsharma.xyz. The goal is to host this personal site as cheap as possible in multiple clouds using multiple technology stacks and use a highly avaiable proxy as the entry point for the user.

## Overview
The following list is done via terraform 
1. Create VPC, subnet, and security groups on AWS
2. Create [free] EC2 instance on AWS with cloudint script that:
   a. Installs Docker
   b. Runs nginx docker image with mTLS enabled
   c. Sets up script to start nginx on reboots 
3. Create A-record with proxy enabled on CloudFlare using EC2 instance IP

## Environment Variables 
This is the list of variables that need to be set for terraform to run
```
# cloudflare
CLOUDFLARE_API_KEY=
CLOUDFLARE_EMAIL=
CLOUDFLARE_API_USER_SERVICE_KEY=

# aws
AWS_ACCESS_KEY_ID=
AWS_AWS_SECRET_ACCESS_KEY=

# ibm cloud
IC_API_KEY=

```

## Prerequisite
1. Update the `publickey.crt` with a public key to add to a server
1. [Free Tier AWS Account](https://aws.amazon.com/free/)
3. [Free Tier CloudFlare Account](https://www.cloudflare.com/plans/)
4. Ownership of a domain- djsharma.xyz in this case

## Delegate DNS to CloudFlare
We will be using CloudFlare to configure DNS, provide proxy with TLS, and provide mtls connection with the origin. Either buy a domain directly from CloudFlare or delegate the domain to them via NS records on your authority.
 