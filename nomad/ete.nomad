job "ete" {
  datacenters = ["dc1"]
  type = "service"
  group "ete" {
    count = 1
    network {
      port "http" { to = 3735 }
    }
    service {
      name = "ete"
      tags = ["urlprefix-ete.lan/"]
      port = "http"
      check {
        type     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "5s"
      }
    }
    volume "eted" {
      type      = "host"
      source    = "eted"
      read_only = false
    }
    task "syn" {
      driver = "docker"
      user   = "1000:1000"
      config {
        image = "victorrds/etesync"
        hostname = "HomeNAS"
        ports = ["http"]
        dns_servers = ["172.17.0.1", "1.1.1.1", "8.8.8.8"]
      }
      env {
        PUID          = 1000
        PGID          = 1000
        # Can be changed from UI after deployment
        SUPER_USER    = "admin"
        SUPER_PASS    = "admin"
      }
      volume_mount {
        volume      = "eted"
        destination = "/data"
        read_only   = false
      }
      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
