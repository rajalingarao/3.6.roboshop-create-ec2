resource "aws_instance" "roboshop" {
    for_each = var.instances
    ami           = data.aws_ami.rhel_info.id
    instance_type = each.value
    vpc_security_group_ids = [var.allow_all]
    root_block_device {
        encrypted             = false
        volume_type           = "gp3"
        volume_size           = 50
        iops                  = 3000
        throughput            = 125
        delete_on_termination = true
    }
    tags = {
        Name = each.key
    }
}
resource "aws_route53_record" "roboshop_r53" {
    for_each = aws_instance.roboshop
    zone_id = var.zone_id
    name    = each.key == "web"? var.domain_name : "${each.key}.${var.domain_name}" 
    type    = "A"
    ttl     = 1
    records = each.key == "web" ? [each.value.public_ip]:[each.value.private_ip]
    allow_overwrite = true
}