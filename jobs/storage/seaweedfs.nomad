# WWW naster: http://seaweedfs-master.service.consul:9333/
# WWW filer: http://seaweedfs-filer.service.consul:8888/

job "seaweedfs" {
  datacenters = ["dc1"]
  type = "service"

  # Master Group
  group "seaweedfs-master" {
    count = 1

    constraint {
      attribute = "${attr.unique.hostname}"
      operator  = "regexp"
      # We need static IPs for master servers
      # nas0 - xxx.xxx.xxx.xxx
      # nas1 - yyy.yyy.yyy.yyy
      # nas2 - zzz.zzz.zzz.zzz
      value     = "^nas0$"
    }

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    update {
      max_parallel = 1
      stagger      = "5m"
      canary       = 0
    }

    migrate {
      min_healthy_time = "2m"
    }

    network {
      port "http" {
        static = 9333
      }
      port "grpc" {
        static = 19333
      }
    }

    task "seaweedfs-master" {
      driver = "docker"
      env {
        WEED_MASTER_VOLUME_GROWTH_COPY_1 = "1"
        WEED_MASTER_VOLUME_GROWTH_COPY_2 = "2"
        WEED_MASTER_VOLUME_GROWTH_COPY_OTHER = "1"
      }
      config {
        image = "chrislusf/seaweedfs:latest"
        force_pull = "true"
        network_mode = "host"
        args = [
          "-v=1", "master",
          "-volumeSizeLimitMB=100",
          "-resumeState=false",
          "-ip=${NOMAD_IP_http}",
          "-port=${NOMAD_PORT_http}",
          "-peers=${NOMAD_ADDR_http}",
          "-mdir=${NOMAD_TASK_DIR}/master"
        ]
      }

      resources {
        cpu = 128
        memory = 128
      }

      service {
        tags = ["${node.unique.name}"]
        name = "seaweedfs-master"
        port = "http"
        check {
          type = "tcp"
          port = "http"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }

  # Volume Group
  group "seaweedfs-volume" {
    count = 1

    constraint {
      attribute = "${attr.unique.hostname}"
      operator  = "regexp"
      # We want to store data on predictive servers
      value     = "^nas0$"
    }

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    update {
      max_parallel      = 1
      stagger           = "2m"
    }

    migrate {
      min_healthy_time = "2m"
    }

    network {
      port "http" {
        static = 8082
      }
      port "grpc" {
        static = 18082
      }
    }

    volume "seaweedfs-vol" {
      type      = "host"
      source    = "seaweedfs"
      read_only = true
    }

    task "seaweedfs-volume" {
      driver = "docker"
      user = "1000:1000"

      config {
        image = "chrislusf/seaweedfs:latest"
        force_pull = "true"
        network_mode = "host"
        args = [
          "volume",
          "-dataCenter=${NOMAD_DC}",
#          "-rack=${meta.rack}",
          "-rack=${node.unique.name}",
          "-mserver=seaweedfs-master.service.consul:9333",
          "-port=${NOMAD_PORT_http}",
          "-ip=${NOMAD_IP_http}",
          "-publicUrl=${NOMAD_ADDR_http}",
          "-preStopSeconds=1",
          "-dir=/data"
        ]
      }

      volume_mount {
        volume = "seaweedfs-vol"
        destination = "/data"
        read_only = false
      }

      resources {
        cpu = 512
        memory = 2048
        # memory_max = 4096 # W need to have memory oversubscription enabled
      }

      service {
        tags = ["${node.unique.name}"]
        name = "seaweedfs-volume"
        port = "http"
        check {
          type = "tcp"
          port = "http"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }


  group "seaweedfs-filer" {
    count = 1

    constraint {
      attribute = "${attr.unique.hostname}"
      operator  = "regexp"
      value     = "^nas0$"
    }

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    migrate {
      min_healthy_time = "2m"
    }

    network {
      port "http" {
        static = 8888
      }
      port "grpc" {
        static = 18888
      }
      port "s3" {
        static = 8333
      }
    }

    volume "filer-vol" {
      type = "host"
      source = "filer"
      read_only = false
    }

    task "seaweedfs-filer" {
      driver = "docker"
      user = "1000:1000"

      config {
        image = "chrislusf/seaweedfs:latest"
        force_pull = "true"
        network_mode = "host"
        args = [
          "filer",
          "-dataCenter=${NOMAD_DC}",
#          "-rack=${meta.rack}",
          "-rack=${node.unique.name}",
          "-defaultReplicaPlacement=000",
          "-master=seaweedfs-master.service.consul:9333",
          "-s3",
          "-ip=${NOMAD_IP_http}",
          "-port=${NOMAD_PORT_http}",
          "-s3.port=${NOMAD_PORT_s3}"
        ]

        volumes = [
          "local/filer.toml:/etc/seaweedfs/filer.toml"
        ]
      }

      volume_mount {
        volume = "filer-vol"
        destination = "/datastore"
        read_only = false
      }

      template {
        destination = "local/filer.toml"
        change_mode = "restart"
        data = <<EOH
[leveldb2]
# local on disk, mostly for simple single-machine setup, fairly scalable
# faster than previous leveldb, recommended.
enabled = true
dir = "/datastore/filerldb2" # directory to store level db files
EOH
      }

      resources {
        cpu = 512
        memory = 256
      }

      service {
        tags = ["${node.unique.name}"]
        name = "seaweedfs-filer"
        port = "http"
        check {
          type = "tcp"
          port = "http"
          interval = "10s"
          timeout = "2s"
        }
      }

      service {
        tags = ["${node.unique.name}"]
        name = "seaweedfs-s3"
        port = "s3"
        check {
          type = "tcp"
          port = "s3"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }

}