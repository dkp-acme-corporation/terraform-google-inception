#######################################################################################################################
## ----------------------------------------------------------------------------------------------------------------- ##
## Terraform Root Module
## ------------------------------
## - 
## ----------------------------------------------------------------------------------------------------------------- ##
#######################################################################################################################
#BOF
terraform {
  # Terraform version required for this module to function
  required_version = "~> 1.2"
  # ---------------------------------------------------
  # Setup providers
  # ---------------------------------------------------
  required_providers {
    #
    google = {
      source  = "registry.terraform.io/hashicorp/google"
      version = "~> 4.40"
    }
  } #END => required_providers
  # ---------------------------------------------------
  # Setup Backend
  # ---------------------------------------------------
  # 
  # ---------------------------------------------------
} #END => terraform
## ---------------------------------------------------
## provider setup and authorization
## ---------------------------------------------------
provider "google" {
  # assign the project to execute within
  project = var.gcpProject
  # setup location
  region = var.gcpRegion
  zone   = var.gcpZone
} # END => provider
#######################################################################################################################
## ----------------------------------------------------------------------------------------------------------------- ##
## Local variable setup
## ----------------------------------------------------------------------------------------------------------------- ##
#######################################################################################################################
locals {
  #
  dnsZoneName = "acme-corporation"
  # output data setup

}
#######################################################################################################################
## ----------------------------------------------------------------------------------------------------------------- ##
## Data
## ----------------------------------------------------------------------------------------------------------------- ##
#######################################################################################################################
#
## ---------------------------------------------------
## ---------------------------------------------------
data "google_dns_managed_zone" "root" {
  name = var.rootDnsZoneName
}
## ---------------------------------------------------
## ---------------------------------------------------
data "google_dns_keys" "default" {
  managed_zone = resource.google_dns_managed_zone.default.id
}

#
#######################################################################################################################
## ----------------------------------------------------------------------------------------------------------------- ##
## Resources
## ----------------------------------------------------------------------------------------------------------------- ##
#######################################################################################################################
#
## ---------------------------------------------------
## ---------------------------------------------------
resource "google_dns_managed_zone" "default" {
  name = local.dnsZoneName
  #
  dns_name    = format("%s.%s.", local.dnsZoneName, trimsuffix(data.google_dns_managed_zone.root.dns_name, "."))
  description = "The parent DNS zone for this solution"
  visibility  = "public"
  dnssec_config {
    state = "on"
  }
  #
  labels = {
    "managed-by" = "terraform"
  }
}
resource "google_dns_record_set" "default-ns" {
  name         = resource.google_dns_managed_zone.default.dns_name
  managed_zone = data.google_dns_managed_zone.root.name
  #
  type    = "NS"
  ttl     = 21600
  rrdatas = resource.google_dns_managed_zone.default.name_servers
}
resource "google_dns_record_set" "default-ds" {
  name         = resource.google_dns_managed_zone.default.dns_name
  managed_zone = data.google_dns_managed_zone.root.name
  #
  type    = "DS"
  ttl     = 3600
  rrdatas = [data.google_dns_keys.default.key_signing_keys[0].ds_record]
}
## ---------------------------------------------------
## Active Directory custom domain verification
## ---------------------------------------------------
resource "google_dns_record_set" "azure-activeDirectoryDomain" {
  name         = resource.google_dns_managed_zone.default.dns_name
  managed_zone = resource.google_dns_managed_zone.default.name
  #
  type    = "TXT"
  ttl     = 3600
  rrdatas = [var.azActiveDirectoryDomainVerificationTxt]
}
## ---------------------------------------------------
## ---------------------------------------------------
resource "google_compute_network" "default" {
  name = resource.google_dns_managed_zone.default.name
  #
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "default" {
  name = format("%s-%s", resource.google_compute_network.default.name, "management")
  #
  ip_cidr_range = "10.2.1.0/24"
  region        = var.gcpRegion
  network       = resource.google_compute_network.default.id
}
#
#######################################################################################################################
## ----------------------------------------------------------------------------------------------------------------- ##
#######################################################################################################################
#EOF