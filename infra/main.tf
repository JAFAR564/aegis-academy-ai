terraform {
  required_version = ">= 1.0.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Network for services to communicate
resource "docker_network" "aegis_net" {
  name = "aegis-net"
}

# Database container
resource "docker_container" "postgres" {
  name  = "aegis-postgres"
  image = "postgres:latest"
  env = [
    "POSTGRES_PASSWORD=mysecretpassword",
    "POSTGRES_USER=aegis",
    "POSTGRES_DB=aegis_academy"
  ]
  ports {
    internal = 5432
    external = 5432
  }
  networks_advanced {
    name = docker_network.aegis_net.name
  }
}

# Message bus container
resource "docker_container" "rabbitmq" {
  name  = "aegis-rabbitmq"
  image = "rabbitmq:3-management"
  ports {
    internal = 5672
    external = 5672
  }
  ports {
    internal = 15672
    external = 15672
  }
  networks_advanced {
    name = docker_network.aegis_net.name
  }
}