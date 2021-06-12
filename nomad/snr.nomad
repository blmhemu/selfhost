job "snr" {
  datacenters = ["dc1"]
  type = "service"
  group "snr" {
    count = 1
    network {
      port "http" {
        to = 8989
      }
    }
    service {
      name = "snr"
      tags = ["urlprefix-snr.lan/"]
      port = "http"
      check {
        type     = "http"
        path     = "/"
        interval = "300s"
        timeout  = "30s"
      }
    }
    volume "snr" {
      type      = "host"
      source    = "snr"
      read_only = false
    }
    task "snr" {
      driver = "docker"
      config {
        image = "hotio/sonarr"
        ports = ["http"]
      }
      volume_mount {
        volume      = "snr"
        destination = "/config"
        read_only   = false
      }
      resources {
        cpu    = 300
        memory = 256
      }
    }
  }
}
