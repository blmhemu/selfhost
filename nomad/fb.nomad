job "fbr" {
  datacenters = ["dc1"]
  type = "service"
  group "fbr" {
    count = 1
    network {
      port "http" {}
    }
    service {
      name = "fbr"
      tags = ["urlprefix-fbr.lan/"]
      port = "http"
      check {
        type     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "5s"
      }
    }
    volume "fbrc" {
      type      = "host"
      source    = "fbr"
      read_only = false
    }
    task "fbr" {
      driver = "docker"
      config {
        image = "hurlenko/filebrowser"
        ports = ["http"]
      }
      volume_mount {
        volume      = "fbrc"
        destination = "/config"
        read_only   = false
      }
      user = "1000:1000"
      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
