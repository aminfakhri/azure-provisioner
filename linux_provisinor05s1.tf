resource "null_resource" "linux_provisioner" {
 count      = var.nb_count
 depends_on = [azurerm_linux_virtual_machine.vminfo]

 provisioner "remote-exec" {
   inline = [
     "usr/bin/hostname"
   ]
   connection {
        type        = "ssh"
        user        = var.username
        private_key = file(var.ssh_private_key)
        host        = element(azurerm_public_ip.pip[*].fqdn, count.index + 1)
        #host       = elemenet(azurerm_linux_virtual_machine.vminfo[*].public_ip_address, count.index + 1)
     }
   }
}
