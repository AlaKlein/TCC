# Configure HyperV
provider "hyperv" {
  #user            = "administrator"
  password        = "123mudar*"
  host            = "192.168.32.130"
  port            = 5986
  https           = false
  insecure        = true
  use_ntlm        = true
  tls_server_name = ""
  cacert_path     = ""
  cert_path       = ""
  key_path        = ""
  script_path     = "C:/Temp/terraform_%RAND%.cmd"
  timeout         = "240s"
}
