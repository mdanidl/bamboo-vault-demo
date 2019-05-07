variable "address" {
    default = "http://localhost:8200"
}

variable "token" {
    default = "root"
}

provider "vault" {
  address = "${var.address}"
  token   = "${var.token}"
  skip_tls_verify = true

}

resource "vault_generic_secret" "example" {
  path = "secret/foo"

  data_json = <<EOT
{
  "foo":   "bar",
  "pizza": "cheese"
}
EOT
}