resource "aws_iot_thing" "stadium_simulator" {
  name = "stadium-iot-simulator"
}

resource "aws_iot_policy" "stadium_simulator" {
  name = "stadium-iot-simulator-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = "iot:Connect"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "iot:Publish"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iot_certificate" "stadium_simulator" {
  active = true
}

resource "aws_iot_thing_principal_attachment" "stadium_simulator" {
  thing     = aws_iot_thing.stadium_simulator.name
  principal = aws_iot_certificate.stadium_simulator.arn
}

resource "aws_iot_policy_attachment" "stadium_simulator" {
  policy = aws_iot_policy.stadium_simulator.name
  target = aws_iot_certificate.stadium_simulator.arn
}