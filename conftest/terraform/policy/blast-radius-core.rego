blast_radius = 10

weights = {
    "aws_autoscaling_group": {"delete": 100, "create": 10, "modify": 1},
    "aws_instance": {"delete": 10, "create": 1, "modify": 1}
}

resource_types = {"aws_autoscaling_group", "aws_instance",
    "aws_iam", "aws_launch_configuration"}

deny[msg] {
    score > blast_radius
    msg = sprintf("Makes too many changes, scoring %v which
            is greater than current maximum %v", [score, blast_radius])
}

# Compute the score for a Terraform plan as the
# weighted sum of deletions, creations, modifications

score = s {
    all := [ x |
            some resource_type
            crud := weights[resource_type];
            del := crud["delete"] * num_deletes[resource_type];
            new := crud["create"] * num_creates[resource_type];
            mod := crud["modify"] * num_modifies[resource_type];
            x := del + new + mod
    ]
    s := sum(all)
}
