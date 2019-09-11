package main

deny[msg] {
  not input.alerting.enabled = "true"
  msg = "Alerting should turned on"
}

deny[msg] {
  not input.server.http_port = "3443"
  msg = "Grafana port should be 3443"
}

deny[msg] {
  not input.server.protocol = "https"
  msg = "Grafana should use default https"
}

deny[msg] {
  not input.users.allow_sign_up = "false"
  msg = "Users cannot sign up themselves"
}

deny[msg] {
  not input.users.verify_email_enabled = "true"
  msg = "Users should verify their e-mail address"
}
