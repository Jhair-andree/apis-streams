variable "bucket_name" {
    default = "acme-storage-carlosfeu"
}
variable "access_key" {
     description = "Access key to AWS console que tendremos en el terraform.tfvars"
}
variable "secret_key" {
     description = "Secret key to AWS console que tendremos en el terraform.tfvars"
}
variable "region" {
     description = "Region of AWS VPC que tendremos en el terraform.tfvars"
}