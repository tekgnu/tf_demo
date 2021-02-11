# Matthew created terraform to deploy a demo ubuntu image
##  source: https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure
###
# Configure the Microsoft Azure Provider
# Latest Resource provider 2/10/2021
provider "azurerm" {
   //Deprecated version = "~>2.46.1"
    features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = var.vm_resource_group
    location = var.region

    tags = {
        environment = var.environment
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = var.vnet_name
    address_space       = [var.vnet_addr_space]
    location            = var.region
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = var.environment
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = var.subnet_name_1
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = [var.subnet_cidr_1]
}

# Matthew Added Azure Bastion Subnet
resource "azurerm_subnet" "tfbastionsubnet" {
    name                 = var.subnet_name_2
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = [var.subnet_cidr_2]
}

/* MWP DISABLING THE PIP THIS IS ONLY A DEMO AND WILL HAVE BASTION ACCESS
# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

/* MWP REMOVING THE NSG RULE USING AZURE BASTION FOR ACCESS
# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}
*/

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = var.vm_nic
    location                  = var.region
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
# MWP DisableD PIP
#        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = var.environment
    }
}

/* MWP DISABLED NSG THEREFORE WON'T NEED THE NST BINDING
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}
*/

/* MWP DISABLING THE NEXT SECTION NOT GOING TO KEEP BOOT DIAGNOSTICS
# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }

    byte_length = 8
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}
*/

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = var.vm_name
    location              = var.region
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = var.vm_size

    os_disk {
        name                 = var.os_disk_name
        caching              = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher           = var.image_config["publisher"]
        offer               = var.image_config["offer"]
        sku                 = var.image_config["sku"]
        version             = var.image_config["version"]
    }

    computer_name  = var.vm_name
    admin_username = var.vm_admin_id
    disable_password_authentication = true

    admin_ssh_key {
        username            = var.vm_admin_id
        public_key          = tls_private_key.example_ssh.public_key_openssh
    }

/* MWP DISABLING BOOT DIAGNOSTICS
    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }
*/
    tags = {
        environment = var.environment
    }
}