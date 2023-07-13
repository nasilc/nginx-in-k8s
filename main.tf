terraform {
  required_version = ">=1.5.2"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~>2.21.1"
    }
  }
}

#-----------------------------------------
# Define Provider: Kubernetes
#-----------------------------------------
provider "kubernetes" {
  host                   = var.k8sHost
  client_certificate     = base64decode(yamldecode(file("${path.module}/kubeconfig/kubeconfig.yaml"))["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(file("${path.module}/kubeconfig/kubeconfig.yaml"))["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(file("${path.module}/kubeconfig/kubeconfig.yaml"))["clusters"][0]["cluster"]["certificate-authority-data"])
}

#-----------------------------------------
# Namespace: harrison
#-----------------------------------------
resource "kubernetes_namespace" "harrison" {
  metadata {
    name = "harrison"
  }
}

#-----------------------------------------
# ConfigMap: nginx-files
#-----------------------------------------
resource "kubernetes_config_map" "nginx_config_map" {
  metadata {
    name = "nginx-files"
    namespace = kubernetes_namespace.harrison.metadata[0].name
  }

  data = {
    "nginx.conf" = "${file("${path.module}/nginx.conf")}"
    "index.html" = "${file("${path.module}/index.html")}"
  }

}

#-----------------------------------------
# Deployment: nginx_deployment
#-----------------------------------------
resource "kubernetes_deployment" "nginx_deployment" {
  metadata {
    name = "harrison-nginx"
    namespace = kubernetes_namespace.harrison.metadata[0].name
    labels = {
      App = "harrison-nginx"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "harrison-nginx"
      }
    }
    template {
      metadata {
        labels = {
          App = "harrison-nginx"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx"
          port {
            container_port = 8080
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          volume_mount {
            name = "nginx-conf"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path = "nginx.conf"
            read_only = true
          }
          volume_mount {
            name = "nginx-conf"
            mount_path = "/usr/share/nginx/html/index.html"
            sub_path = "index.html"
            read_only = true
          }
        }
        volume {
          name = "nginx-conf"
          config_map {
            name = kubernetes_config_map.nginx_config_map.metadata[0].name
            items {
              key = "nginx.conf"
              path = "nginx.conf"
            }
            items {
              key = "index.html"
              path = "index.html"
            }
          }
        }
      }
    }
  }
}

#-----------------------------------------
# Service: nginx_service
#-----------------------------------------
resource "kubernetes_service" "nginx_service" {
  metadata {
    name = "harrison-nginx"
    namespace = kubernetes_namespace.harrison.metadata[0].name
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx_deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port = 8080
      target_port = 8080
      protocol = "TCP"
    }
    type = "ClusterIP"
  }
}

#-----------------------------------------
# Ingress: nginx_ingress
#-----------------------------------------
resource "kubernetes_ingress_v1" "nginx_ingress" {
  metadata {
    name = "harrison-nginx"
    namespace = kubernetes_namespace.harrison.metadata[0].name
  }

  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service.nginx_service.metadata[0].name
              port {
                number = kubernetes_service.nginx_service.spec[0].port[0].port
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}