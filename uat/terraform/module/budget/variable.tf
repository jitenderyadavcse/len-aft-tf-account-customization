variable "budget" {
  type    = string
  default = "1"
}

variable "notification_subscriber_email" {
  type    = set(string)
  default = ["cpadmin@lennar.com"]
}