package main

valid_waivers = {
  "SNYK-JAVA-CHQOSLOGBACK-173711",
  "SNYK-JAVA-COMFASTERXMLJACKSONCORE-450207"
}

deny[msg] {
  ignored := { name | input.ignore[name] = _ }
  invalid_waivers := ignored - valid_waivers
  count(invalid_waivers) > 0
  msg = sprintf("Vulnerabilities %s are not in the allowed waiver list",
          [concat(", ", invalid_waivers)])
}
