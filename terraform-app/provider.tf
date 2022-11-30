terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.36.1"
    }
  }
}

provider "aws" {
   region = var.region
   #Para git-actions y jenkins, es necesarios crear sus propias credenciales
  #Si quieres usar las variables de tu maquina, puedes usar la siguiente sintaxis:
  #shared_credentials_files = "$HOME/.aws/credentials"
  #si quieres usar variables de entorno, debes usar la siguiente sintaxis:
  #export AWS_ACCESS_KEY_ID="tu access key alojada en $HOME/./aws/credentials"
  #export AWS_SECRET_ACCESS_KEY="tu secret access key alojada en $HOME/./aws/credentials"
  # Configuration options
}
