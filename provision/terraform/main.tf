terraform {
   required_providers {
      linode = {
         source  = "linode/linode"
         version = "1.29.4"

      }
      sops = {
         source  = "carlpett/sops"
         version = "0.7.2"
      }
   }
}

provider "sops" {}

data "sops_file" "secrets" {
  source_file = "secrets.sops.yaml"
}

provider "linode" {
     token = data.sops_file.secrets.data["linode_token"]
}

resource "linode_lke_cluster" "cluster" {
   label = "cluster"
   k8s_version = "1.23"
   region = "us-east"
   pool {
      type = "g6-standard-1"
      count = 1
   }
}

resource "local_sensitive_file" "kubeconfig" {
   content_base64 = linode_lke_cluster.cluster.kubeconfig
   filename = "../kubeconfig"
}
