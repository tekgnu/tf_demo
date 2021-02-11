### USAGE terraform apply --var-file=production_vm.tfvars

# Region to deploy 
variable "region" {
    type        = string
    description = "Azure Region"
    default     = "eastus2"
}

# Environment scope to deploy
variable "environment" {
    type        = string
    description = "VM deployment Environment"    
    default     = "demo"
}
# Resource to deploy into 

variable "vm_resource_group" {
    type        = string
    description = "Azure Region"
 }

# VNET Resource Details
 variable "vnet_name" {
    type        = string
    description = "Vnet Name for the environment"
 }

variable "vnet_addr_space" {
    type        = string
    description = "CIDR for the vnet"
}

variable "subnet_name_1" {
    type        = string
    description = "Subnet Name"
}

variable "subnet_cidr_1" {
    type        = string
    description = "CIDR address for first subnet"
}

variable "subnet_name_2" {
    type        = string
    description = "CIDR address for second subnet"
}

variable "subnet_cidr_2" {
    type        = string
    description = "CIDR address for second subnet"
}

variable "vm_nic" {
    type        = string
    description = "vmnic name"
}

## VM Resource Details
variable "vm_name" {
    type        = string
    description = "VM Name"
}

variable "vm_admin_id" {
    type        = string
    default     = "azureuser"
}

variable "vm_size" {
    type        = string
    description = "Azure VM size designations"
    default     = "Standard_DS1_v2"
}

variable "os_disk_name" {
    type        = string
    description = "OS disk name"
    default     = "myOsDisk"    
}

variable "image_config" {
  type = map
  default = {
    publisher   = "Canonical"
    offer       = "UbuntuServer"
    sku         = "18.04-LTS"
    version     = "latest"
  }
}


