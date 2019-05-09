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

resource "vault_generic_secret" "myapp" {
  path = "secret/my_app"

  data_json = <<EOT
{
  "my_secret_parameter":   "foo-bar"
}
EOT
}

resource "vault_policy" "application" {
  name = "application"
  policy = <<EOT
path "secret/data/my_app" {
  capabilities = ["read"]
}
path "secret/*" {
    capabilities = ["list"]
}
EOT
}
resource "vault_policy" "bamboo" {
  name = "bamboo"
  policy = <<EOT
path "auth/approle/role/my-app/role-id" {
  capabilities = ["read"]
}
path "auth/approle/role/my-app/secret-id" {
  capabilities = ["create","update"]
}
EOT
}
resource "vault_policy" "configmgmt" {
  name = "cfgmgmt"
  policy = <<EOT
path "auth/approle/role/my-app/secret-id" {
  capabilities = ["create","update"]
}
EOT
}

resource "vault_policy" "ui-policy" {
  name = "ui-policy"
  policy = <<EOT
path "auth/approle/role/*" {
    capabilities = ["create","read","update","delete","list"]
}
EOT
}


resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "my-app_role" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "my-app"

  policies  = ["default", "application"]
#   bound_cidr_list = ["10.10.0.0/16"]
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "${vault_approle_auth_backend_role.my-app_role.role_name}"

  metadata = <<EOT
{
  "adgrp": "blah-TEC-APMID-NP-blah"
}
EOT
}


resource "vault_token_auth_backend_role" "bamboo" {
  role_name           = "bamboo-role"
  allowed_policies    = ["bamboo"]
  orphan              = true
  period              = "86400"
  renewable           = true
  explicit_max_ttl    = "115200"
#   bound_cidrs = ["172.21.0.2/32"]
}

resource "template_file" "sentinel_meta" {
  template = "${file("sentinel/extract_meta.sentinel")}"
}

# resource "vault_rgp_policy" "meta_extract" {
#   name = "meta_extract"
#   enforcement_level = "soft-mandatory"
#   policy = "${template_file.sentinel_meta.rendered}"
# }
resource "vault_egp_policy" "meta_extract" {
  name = "meta_extract"
  enforcement_level = "soft-mandatory"
  policy = "${template_file.sentinel_meta.rendered}"
    paths = ["secret/*"]

}

output "cmd" {
    value = "vault write auth/approle/login role_id=${vault_approle_auth_backend_role.my-app_role.role_id} secret_id=${vault_approle_auth_backend_role_secret_id.id.secret_id}"
}