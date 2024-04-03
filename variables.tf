# Openstack connexion
variable "user_name" {
    description = "Your Openstack Username."
}

variable "password" {
    description = "Your Openstack Password."
}

variable "tenant_id" {
    description = "Your Openstack Tenant ID."
}

variable "tenant_name" {
    description = "Your Openstack Tenant Name."
}

# Main options
variable "keypair_name" {
    description = "The keypair to be used."
    default  = "ssh-admin"
}

variable "ssh_key" {
    description = "Your SSH key"
}

variable "floating_ip_pool" {
    description = "The pool to be used to get floating ip"
    default = "ext-floating1"
}

variable "floating_ip_pool_id" {
    description = "The pool to be used to get floating ip"
    default = "0f9c3806-bd21-490f-918d-4a6d1c648489" # ext-floating1
}

# Managment options
variable "managment_num" {
    description = "The Number of instances to be created."
    default  = 1
}

variable "managment_image" {
    description = "The image to be used."
    default  = "a585ad4f-1311-49f6-be60-a6481ec2f1c1" # Debian 11 Bullseye
}

variable "managment_flavor" {
    description = "The flavor to be used."
    default  = "b6b7baeb-2328-48c9-8543-88cccec8ec4b" # a2-ram4-disk20-perf1
}

# Controlplane options
variable "controlplane_num" {
    description = "The Number of instances to be created."
    default  = 3
}

variable "controlplane_flavor" {
    description = "The flavor to be used."
    default  = "b6b7baeb-2328-48c9-8543-88cccec8ec4b" # a2-ram4-disk20
}

variable "controlplane_volume_size" {
    description = "The size of storage."
    default  = 20
}

# Worler options
variable "worker_num" {
    description = "The Number of instances to be created."
    default  = 2
}

variable "worker_flavor" {
    description = "The flavor to be used."
    default  = "b6b7baeb-2328-48c9-8543-88cccec8ec4b" # a2-ram4-disk20
}

variable "worker_volume_size" {
    description = "The size of storage."
    default  = 100
}
