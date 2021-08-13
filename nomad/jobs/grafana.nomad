job "grafana" {
  datacenters = ["lab"]
  type = "service"

  group "grafana" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "grafana" {
      driver = "docker"

      env {
        GF_SECURITY_ADMIN_USER = "admin"
        GF_SECURITY_ADMIN_PASSWORD = "admin"
        GF_USERS_ALLOW_SIGN_UP = "false"
        GF_PATHS_PROVISIONING = "/etc/grafana/provisioning/"
        GF_INSTALL_PLUGINS = "grafana-piechart-panel"
      }

      config {
        image = "grafana/grafana:6.3.5"
        network_mode = "host"

        dns_servers = ["${NOMAD_IP_http}", "8.8.8.8", "8.8.8.4"]

        port_map {
          http = 3000
        }
      }

      resources {
        cpu    = 200 # 200 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "http" {
            static = "3000"
          }
        }
      }

      service {
        name = "grafana"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.grafana.rule=Host(`grafana.lab.example.com`)"
        ]
        port = "http"

        check {
          name     = "http port alive"
          type     = "http"
          path     = "/api/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
