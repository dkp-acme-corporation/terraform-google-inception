#######################################################################################################################
## ----------------------------------------------------------------------------------------------------------------- ##
## Terraform Root Module
## ------------------------------
## - 
## ----------------------------------------------------------------------------------------------------------------- ##
#######################################################################################################################
#BOF
#
## ---------------------------------------------------
variable "gcpProject" {
  type = string
}
## ---------------------------------------------------
variable "gcpRegion" {
  type = string
}
## ---------------------------------------------------
variable "gcpZone" {
  type = string
}
## ---------------------------------------------------
## ---------------------------------------------------
variable "rootDnsZoneName" {
  type = string
}
## ---------------------------------------------------
## ---------------------------------------------------
variable "azActiveDirectoryDomainVerificationTxt" {
  type = string
}
#
#######################################################################################################################
## ----------------------------------------------------------------------------------------------------------------- ##
#######################################################################################################################
#EOF