job "fabio" {
  datacenters = ["dc1"]
  type = "system"
  group "fabio" {
    network {
      port "lb" { static = 80 }
      port "ui" {}
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
registry.consul.register.tags = urlprefix-fabio.lan/
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
