job "syn" {
  datacenters = ["dc1"]
  type = "service"
  group "syn" {
    count = 1
    network {
      port "http" {}
    }
    service {
      name = "syn"
      tags = ["urlprefix-syn.lan/"]
      port = "http"
      # TCP because we setup a basic auth which gives 4xx error if http is used
      check {
        type     = "tcp"
        interval = "30s"
        timeout  = "5s"
      }
    }
    volume "synd" {
      type      = "host"
      source    = "synd"
      read_only = false
    }
    task "syn" {
      driver = "docker"
      config {
        image = "syncthing/syncthing"
        hostname = "HomeNAS"
        ports = ["http"]
        # Host networking for local device discovery
        # https://github.com/syncthing/syncthing/blob/main/README-Docker.md
        network_mode = "host"
        dns_servers = ["172.17.0.1", "1.1.1.1", "8.8.8.8"]
      }
      env {
        PUID          = 1000
        PGID          = 1000
        STGUIADDRESS  = "0.0.0.0:${NOMAD_PORT_http}"
      }
      volume_mount {
        volume      = "synd"
        destination = "/var/syncthing"
        read_only   = false
      }
      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
