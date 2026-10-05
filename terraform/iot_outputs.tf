data "aws_iot_endpoint" "stadium_iot" {
  endpoint_type = "iot:Data-ATS"
}

output "iot_certificate_pem" {
  value     = aws_iot_certificate.stadium_simulator.certificate_pem
  sensitive = true
}

output "iot_private_key" {
  value     = aws_iot_certificate.stadium_simulator.private_key
  sensitive = true
}

output "iot_certificate_arn" {
  value = aws_iot_certificate.stadium_simulator.arn
}

output "iot_endpoint" {
  value = data.aws_iot_endpoint.stadium_iot.endpoint_address
}