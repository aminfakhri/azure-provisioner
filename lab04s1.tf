resource "azurerm_availability_set" "avset" {

   name                 = var.avs
   location             = var.location
   resource_group_name  = var.rg_name
   platform_fault_domain_count = 2
   platform_update_domain_count = 5
   depends_on           = [azurerm_resource_group.rg2]
}


resource "azurerm_linux_virtual_machine" "vminfo" {
  count               = var.nb_count
  name                = "${var.linux_name["linux"]}${format("%1d", count.index + 1)}"
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.linux_name["size"]
  admin_username      = var.username
  network_interface_ids = [element(azurerm_network_interface.nic[*].id, count.index + 1)]
  availability_set_id   = azurerm_availability_set.avset.id
  computer_name         = "${var.linux_name["linux"]} -${format("%1d", count.index + 1)}"

  depends_on = [azurerm_availability_set.avset]
 
  
  


admin_ssh_key {
    username   = var.username
    public_key = file(var.ssh_public_key)
  }

os_disk {
    caching              = var.os_disk["cache"]
    storage_account_type = var.os_disk["storage"]
    disk_size_gb         = var.os_disk["disk_size_gb"]

  }

source_image_reference {
    publisher = var.source_image["publisher"]
    offer     = var.source_image["offer"]
    sku       = var.source_image["sku"]
    version   = var.source_image["version"]
  }
}


resource "azurerm_subnet" "subnet3" {
  name                 = var.subnet3
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet3-space
}


resource "azurerm_network_interface" "nic" {
  count    = var.nb_count
  name     = "${var.linux_name["linux"]}-nic-${format("%1d", count.index + 1)}"
  location = var.location
  resource_group_name = var.rg_name
  tags                 = local.common_tags
 


  ip_configuration {
    name                          = "${var.linux_name["linux"]}-ip-${format("%1d", count.index + 1)}"
    subnet_id                     = azurerm_subnet.subnet3.id
    public_ip_address_id          = element(azurerm_public_ip.pip[*].id, count.index + 1)
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_public_ip" "pip" {
  count               = var.nb_count
  name                = "${var.linux_name["linux"]}-pip-${format("%1d", count.index + 1)}"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Dynamic"
  depends_on          = [azurerm_resource_group.rg2]

  
}
