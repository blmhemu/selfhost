job "echo" {
  datacenters = ["dc1"]
  type = "service"
  group "echo" {
    count = 1
    network {
      port "http" {
        to = 8080
      }
    }
    service {
      name = "echo"
      tags = ["urlprefix-echo.lan/"]
      port = "http"
      check {
        type     = "http"
        path     = "/"
        interval = "300s"
        timeout  = "30s"
      }
    }
    task "echo" {
      driver = "docker"
      config {
        image = "tenzer/http-echo-test"
        ports = ["http"]
      }
      resources {
        cpu    = 50
        memory = 32
      }
    }
  }
}
