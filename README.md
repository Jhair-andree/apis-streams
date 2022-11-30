[![S3 bucket creation](https://github.com/KeepCodingCloudDevops6/cicd-carlosfeu/actions/workflows/terraform.yml/badge.svg)](https://github.com/KeepCodingCloudDevops6/cicd-carlosfeu/actions/workflows/terraform.yml)

# cicd-carlosfeu
Proyecto de CI/CD Carlos Feu

Para ver el despliegue en local con Makefile, tenemos que abrir el README.dev.md

El primer paso que vamos a hacer es el clonado del repositorio para ello lanzamos el siguiente comando:

```bash
https://github.com/KeepCodingCloudDevops6/cicd-carlosfeu.git
```
- Una vez realicemos este paso, vamos a ver lo que hay dentro del repositorio sobre el que vamos a trabajar con la creación de un Bucket S3 de AWS. A través de GitHub Actions y de Jenkins, este último a través de "Continuous Delivery" y "Continuous Deployment".

- Vamos a ver el código sobre el que vamos a trabajar con estos deployments. Se trata de la creación de un Bucket S3 de AWS a través de Terraform. Y a su vez la creación de un objeto, es decir, la subida de un archivo con el que vamos a trabajar más adelante. En vez de hacer un script en bash o python para subir dicho archivo, la manera más fácil y efectiva es hacerlo con terraform.

```bash
resource "aws_s3_bucket" "acme-storage-carlosfeu" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = var.bucket_name
  acl    = "private"
}
resource "aws_s3_object" "video_mas_20_mb" {
  bucket = aws_s3_bucket.acme-storage-carlosfeu.id
  key    = "gatitos.mp4"
  source = "gatitos.mp4"
  content_type = "mp4"
}
```
- Hemos creado un archivo con variables que podemos ver junto con el provider en la carpeta llamada "terraform-app" y el ARN del bucket. Y el archivo que hemos subido al Bucket S3 en el despliegue. Sobre esto anteriormente mostrado vamos a hacer diferentes tipos de despliegues con el mismo código.

# Despliegue en GitHub Actions

- Dentro del repositorio, encontramos una sucesión de carpetas que acaba con un "terraform.yml". Dentro de esta vamos a visualizar el código y ver que es lo que hace.

```bash
name: S3 bucket creation

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: eu-west-1
    - name: terraform version
      run: terraform --version
      working-directory: ./terraform-app
    - name: init
      run: terraform init
      working-directory: ./terraform-app
    - name: plan
      run: terraform plan
      working-directory: ./terraform-app
    - name: apply
      run: terraform apply -auto-approve
      working-directory: ./terraform-app
    - name: check storage size
      run: sh "script_check.sh"
      working-directory: ./check_storage_size
    - name: dockerize
      run: cd agents &&  docker build -t carlosfeufernandez/terraform-app-carlosfeu:latest -f tf.Dockerfile .
    - name: Docker hub authentication
      run: docker login -u=${{ secrets.DOCKER_HUB_USERNAME }} -p=${{ secrets.DOCKER_HUB_PASSWORD }}
    - name: Push
      run: docker push carlosfeufernandez/terraform-app-carlosfeu:latest
    - name: Integration test
      run: docker run -d carlosfeufernandez/terraform-app-carlosfeu:latest
   
```
- El código consta de un Job de terraform del que parte de una imagen ubuntu. Al que le damos unos pasos para poder desplegarlo. Se configura conforme vamos a trabajar con terraform y la configuración necesaria de credenciales de AWS, que se van a hacer a través de "Secrets" para no mostrar las contraseñas en el propio código.
- El despliegue se inicia comprobando la versión instalada de Terraform. continua con el init y el apply que lo hace de manera automatizada. El siguiente paso es la comprobación a través de un script de que en caso de que dentro del Bucket S3 de AWS haya más de 20 Mib se vacie de manera automática. Si no es así, que se mantenga. Para finalizar creamos una imagen que será pusheada a DockerHub y que se correrá en un contenedor de Docker. El login de Docker se ha hecho también a través de "Secrets" como vamos a ver a continuación.
- Tenemos que cambiar el Dockerize, el push, e integration-test, por nuestra configuración. En caso de que no queramos ejecutarlo lo podemos comentar para que no haga esos pasos. Se han puesto para que veamos como se haría con "Secrets" lo de docker login y ver algo más de ejecución de código.

    ## Creación de Secrets en GitHub

    - Los secrets es la forma en GitHub de poner contraseñas en el código a través de variables de entorno. Se hace de la siguiente manera, dentro del repositorio tenemos que irnos a ***Settings*** dentro de este a su vez en el panel izquiero encontramos la pestaña llamada ***Secrets*** y en ***Actions*** veremos que arriba a la derecha hay un pop-up que dice ***New repository secret*** clickamos y donde pone ***Name**** ponemos "AWS_ACCESS_KEY_ID" y donde pone ***Secret**** ponemos el "AWS_ACCESS_KEY" que tenemos de nuestro usuario creado en AWS. De esta misma forma ponemos "AWS_SECRET_ACCESS_KEY" para el ***Name**** y el ***Secret**** para la contraseña. Asi configuramos nuestras credenciales del usuario de AWS.

    - Para el "docker login" hacemos lo mismo pero donde pone ***Name**** ponemos "DOCKER_HUB_USERNAME" y donde pone ***secret**** ponemos nuestro usuario de DockerHub y para la contraseña donde pone ***Name**** ponemos DOCKER_HUB_PASSWORD y en el ***secret**** nuestra contraseña de DockerHub.

- Una vez tengamos todo esto configurado podemos hacer el deploy con el Actions. Para ello dentro de nuestro repositorio vamos la pestaña donde pone Actions y dentro del último "workflow runs" en la parte derecha superior clickamos en "Re-run all jobs". Veremos como se nos crea nuestro Bucket S3 en AWS, pero no vamos a encontrar ningún archivo dentro ya que se habra ejecutado el script de vaciado de bucket, para hacer que no se ejecute y veamos como el archivo de verdad esta subido y creado deberemos comentar la parte donde ejecuta el "Run" de dicho script. es decir, este:

```bash
# - name: check storage size
# run: sh "script_check.sh"
# working-directory: ./check_storage_size
```
- De esta forma, se saltará el script y no ejecutará el vaciado.
- Para finalizar borraremos a mano el Bucket S3 para que a la hora de desplegar con Jenkins no de conflicto.

    ![gitactions](https://user-images.githubusercontent.com/102614480/200172470-ccf2d013-df6a-4383-8b7b-b7ecb3228cfe.png)

- Se ha intentado hacer que en el depliegue con GitActions pidiese aprobación manual a la hora de hacer el "Apply", pero desgraciadamente no ha sido posible ya que debemos contar con una licencia de GitActions Enterprise. De igual modo voy a mostrar como se debería haber hecho. Al igual que hemos metido el "Setup Terraform" o el "Configure AWS Credentials" tendriamos que meter este trozo de código:

```bash
steps:
  - uses: trstringer/manual-approval@v1
    with:
      secret: ${{ github.TOKEN }}
      approvers: "Tu usuario de GitHub"
```

# Despliegue en Jenkins

- Vamos a empezar con la configuración de Jenkins

    ## Configuración de Jenkins

    - Para configurar Jenkins lo primero que tenemos que ver es que tengamos los siguientes Plugins instalados:

    - `Docker Pipeline`, `AnsiColor`, `Build Timeout`, `Build Trigger Badge Plugin`, `Job DSL`, `Docker`, `SSH Agent Plugin`, `Git`, `Folders`, `Docker plugin`, `GitHub Plugin`, `Pipeline`, `Pipeline: AWS Steps`, `Timestamper`.

    - Previamente tenemos que tener configurada un "SSH username with private key" para que Jenkins conecte con nuestro repositorio de GitHub donde vamos a tener los archivos de configuración. Nos metemos en Manage Credentials y en "ID" la llamamos "ssh-github-key" y de nombre lo llamamos "jenkins" y en private key la clave privada creada en GitHub. Lo llamamos así porque es como lo tenemos configurado en el JOB DSL.

    - La contraseña que falta por configurar es la que Jenkins va a utilizar para conectar con los agentes. En ***Add Credentials*** ponemos como tipo "Username with Password" en usuario ponemos "jenkins" y en contraseña "jenkins" que así ha sido configurado en la imagen base.Dockefile. En ID ponemos "ssh-agents-key"

    - En el pipeline como variables de entorno hemos metido la contraseña de AWS, previamente instalada en un Plugin llamado AWS Steps. De esta forma Jenkins conecta con nuestro AWS para poder hacer el deploy. Se deben meter en "Manage Credentials" en tipo cogemos "AWS Credentials" y en ID ponemos aws-credentials que es como lo hemos configurado en el pipeline. y el Access key y el Secret Access Key de nuestro usuario de AWS.



- Cuando tengamos listo todos esos Plugins, el primer paso que tenemos que hacer es irnos a ***New Item*** y a ***Freestyle project** lo vamos a llamar "0.seed" y dentro vamos a configurar lo siguiente. Marcamos "Add timestamps to the Console Output" y si tenemos Ansicolor marcamos su console output también con xterm.

- En "Build Environment" marcamos ***Process Job DSLs*** y clickamos en "Use the provided DSL script" y dentro de DSL script metemos el codigo que está en el archivo llamado job.dsl, es decir, este:

```bash
multibranchPipelineJob('GitHubTerraform') {
    branchSources {
        git {
            id('1')
            remote('git@github.com:KeepCodingCloudDevops6/cicd-carlosfeu.git')
            credentialsId('ssh-github-key')
        }
    }
}
multibranchPipelineJob('CheckStorageSize') {
    branchSources {
        git {
            id('2')
            remote('git@github.com:KeepCodingCloudDevops6/cicd-carlosfeu.git')
            credentialsId('ssh-github-key')
        }
    }
    factory {
        workflowBranchProjectFactory {
            scriptPath('check_storage_size/Jenkinsfile.storage')
        }
    }
}
```
- Lo que vamos a hacer con esto es la creación automática de los "MultiBranch Pipeline", que vamos a tener que irnos a ***Manage Jenkins*** y en "In-process Script Approval" nos metemos y vamos a aprobar la configuración del Job DSl. Una vez aprobado nos metemos dento del 0.seed y le damos a Build Now. Veremos como nos autodescubre lo anterior descrito.

![ramagit](https://user-images.githubusercontent.com/102614480/200173444-dd590f55-ce3e-4756-bdea-aa75909cf97a.png)

![deploy-terraform](https://user-images.githubusercontent.com/102614480/200172544-12acced3-d6eb-4ae5-9dc2-7bef8c7df171.png)

- Vamos a crear un Multibranch Pipeline para el despliegue de la creación del Bucket S3 de AWS con terraform y el otro Multibranch Pipeline es para la comprobación periodica cada 10 min de que si el Bucket S3 supera los 20 Mib se vacie. 

    ![ramacheck](https://user-images.githubusercontent.com/102614480/200173421-7736f561-b481-4c25-b3e6-da54e042b7ec.png)
    
    - El Jenkisfle de este último Multibranch Pipeline se encuentra dentro de la carpeta llamada check_storage_size junto con el script de comprobación. Al tener un nombre diferente hemos tenido que configurar el PATH para que lo cogiese con ese nombre. El código es el siguiente:

```bash
    pipeline {
    agent {
        label('terraform')
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-credentials')
    }
    triggers {
        cron('*/10 * * * *')
    } 
    options { 
        disableConcurrentBuilds()
        timeout(time: 3, unit: 'MINUTES')
        timestamps()
    }
    stages {
        stage('Check storage size') {
            steps {
                dir('check_storage_size') {
                    sh 'sh script_check.sh'
                }
            }
        }            
    }
}
```


![checkstorage](https://user-images.githubusercontent.com/102614480/200172522-f896ad55-4d6d-42bc-8b69-12a4594e7eca.png)

- Vamos a configurar una nube de Docker, que una vez configurada le vamos a añadir un "Docker Agents Template" En label la vamos a llamar "Terraform" que es como lo hemos llamado en el Jenkinsfile, lo habilitamos en "Enabled". En Docker image ponemos "carlosfeufernandez/terraform-jenkins-agents" que es una imagen de docker que hereda de base.Dockerfile que tiene instalado SSH, Jenkins entre otras cosas necesrasias para el despliegue. Con esta imagen instalamos Terraform y AWS CLI para poder ejecutar todo lo que tenemos en el código. En "Remote file system root" ponemos /home/jenkins. en "Usage", Only build jobs... El método de conexion va a ser a través de SSH que conecte con los agentes. Con usuario previamente configurado llamado "jenkins" y contraseña "jenkins" en "Host Key" marcamos Non verifying... y para finalizar marcamos "Pull all images every time"

- Cuando se creen correran las ramas que haya en el repositorio de Jenkins, en caso de no ser así clikcamos en "Scan Multibranch Pipeline Now" y tiene que aparecer la rama "main". La main es la que hace el "continuous delivery" que tiene que ser aprobado por un administrador, y en el código, en el input vemos que con el "When" esto será "continuous deployment" cuando este en una rama distinta de main.

```bash
pipeline {
    agent {
        label('terraform')
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-credentials')
    }

    options { 
        disableConcurrentBuilds()
        ansiColor('xterm')
        timeout(time: 10, unit: 'MINUTES')
        timestamps()
    }
    stages {
        stage('Version') {
            steps {
                dir('terraform-app') {
                    sh 'terraform --version'
                }
            }
        }
        stage('Init') {
            steps {
                dir('terraform-app') {
                    sh 'terraform init'
                }
            }
        }
        stage('Plan') {
            steps {
                dir('terraform-app') {
                    sh 'terraform plan'
                }
            }
        }
        stage('Apply') {
             input {
                 message "Do you want to continue"
                 ok "Yes, continue the pipeline"
             }
             when {
                branch 'main'
             }
            steps {
                dir('terraform-app') {
                    sh 'terraform apply --auto-approve'
                }
            }
        }
    }
        post {
        failure {
            echo "Your pipeline has failed, contact with your administrator"
        }
        success {
            echo "The deployment was done successfully"
        }
        always {
            echo "I hope you like Jenkins"
        }
    }
}
```

- Con el "Docker Agents Template" hemos configurado la label terraform que es como se llama este pipeline. Que como vemos utilizamos comandos de terraform anteriormente instalado a través de la imagen configurada en el Agents Template.


## Lanzamiento de Jenkins

- Una vez todo lo anterior hecho, podemos lanzar el "Build now" para la creación del Bucket S3 de AWS y verificar que efectivamente se ha creado. Luego una vez desplegado podemos lanzar el del chequeo de almacenamiento y ver que es lo que hace. Si el contenido supera los 20 Mib como es este el caso, lo borrará.




