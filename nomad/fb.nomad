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
      user = "1000:1000"
      config {
        image = "hurlenko/filebrowser"
        ports = ["http"]
        args = ["--config", "filebrowser.json",]
        volumes = ["local/filebrowser.json:/filebrowser.json",]
      }
      volume_mount {
        volume      = "fbrc"
        destination = "/config"
        read_only   = false
      }
      template {
        data = <<EOF
{
  "port": {{ env "NOMAD_PORT_http" }},
  "baseURL": "",
  "address": "",
  "log": "stdout",
  "database": "/config/database.db",
  "root": "/data"
}
EOF
        destination = "local/filebrowser.json"
      }
      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
