job "fabio" {
  datacenters = ["dc1"]
  type = "system"
  group "fabio" {
    network {
      port "lb" { static = 80 }
      port "ui" {}
    }
    service {
      name = "fabio"
      port = "ui"
      tags = ["urlprefix-fabio.lan/"]
      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }
    task "fabio" {
      driver = "docker"
      config {
        image = "blmhemu/fabio"
        # Host network mode because fabio need to be able to ping other services
        network_mode = "host"
        ports = ["lb","ui"]
        volumes = [
          "local/fabio.properties:/etc/fabio/fabio.properties",
        ]
      }
      template {
        data = <<EOF
proxy.addr = :80
ui.addr = :{{env "NOMAD_PORT_ui"}}
EOF
        destination = "local/fabio.properties"
      }
      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
