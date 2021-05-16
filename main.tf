terraform {
      backend "remote" {
        # The name of your Terraform Cloud organization.
        organization = "hamtaro702"

        # The name of the Terraform Cloud workspace to store Terraform state files in.
        workspaces {
          name = "Terraform-huawei"
        }
      }
    }

provider "huaweicloud" {
  region     = "ap-southeast-2"
  access_key = "U3VVWQHSNWBKT2LWDAEE"
  secret_key = "pqDFPaq9fXicb5s08pADRcOHv4vK9NrWacL21mbV"
}

data "huaweicloud_availability_zones" "myaz" {}

data "huaweicloud_compute_flavors" "myflavor" {
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  performance_type  = "normal"
  cpu_core_count    = 2
  memory_size       = 4
}

data "huaweicloud_vpc_subnet" "default_vpc" {
  name = "subnet-42d9"
}

data "huaweicloud_images_image" "myimage" {
  name        = "Ubuntu 18.04 server 64bit"
  most_recent = true
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%*"
}

resource "huaweicloud_compute_instance" "basic" {
  name              = "basic"
  admin_pass        = random_password.password.result
  image_id          = data.huaweicloud_images_image.myimage.id
  flavor_id         = data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_groups   = ["default"]
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  system_disk_type = "SAS"

  network {
    uuid = data.huaweicloud_vpc_subnet.default_vpc.id
  }
}
