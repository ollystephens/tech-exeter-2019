package main

resources_that_take_tags = {
  "aws_iam_role",
  "aws_instance",
  "aws_internet_gateway",
  "aws_security_group",
  "aws_subnet",
  "aws_vpc"
}

deny[msg] {
  some i
  name := input.resource_changes[i].name
  type := input.resource_changes[i].type
  resources_that_take_tags[type]
  not input.resource_changes[i].change.after.tags.cost_code

  msg := sprintf("%s.%s does not have cost_code tag",
           [type, name])
}
