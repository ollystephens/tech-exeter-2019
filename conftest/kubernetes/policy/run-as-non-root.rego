package main

deny[msg] {
  input.kind = "Deployment"
  not input.spec.template.spec.securityContext.runAsNonRoot = true
  msg = sprintf("Containers in deployment '%s' must not run as root",
                [input.metadata.name])
}
