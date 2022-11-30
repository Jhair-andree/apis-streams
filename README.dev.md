# Instruciones para desarrolladores

- Hacemos un clonado del respositorio.

```bash
https://github.com/KeepCodingCloudDevops6/cicd-carlosfeu.git
```
- Lo primero que debemos hacer para poder lanzar el despliegue en local es tener creado un usuario IAM para usar terraform. 
- Abrimos la consola de AWS y entramos a IAM, una vez dentro hacemos click en ***User*** y su vez en ***Add users***. Ponemos el nombre de usuario que queramos y en ***Select AWS credential type*** marcamos ***Access key - Programatic access***. El siguiente paso es darle las políticas que queramos en este caso en ***Attach existing policies directly*** vamos a darle el de ***AdministratorAccess*** y le damos a continuar, en el apartado de ***Add tags*** lo dejamos en blanco y pinchamos en next. Para finalizar le damos a ***Create user***, nos dará tanto el ***Access key ID*** como el ***Secret access key***. Es importante que nos descargemos el .pem que nos da y lo guardemos a buen recaudo. Ya que es la unica forma que vamos a tener de poder utilizar este usuario creado.

- Vamos a instalar el AWS CLI que nos va a hacer falta más adelante. Siguiendo los siguientes comandos:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip -u awscliv2.zip && sudo ./aws/install
```
- Vamos a configurar el ***aws configure*** de la siguiente forma:

```bash
aws configure
```
- En caso de que queramos consultar estas credenciales porque ya las tengamos configuradas y queramos ver si son correctas, tenemos que ver 2 archivos que son los siguientes a través de estos comandos.

```bash
cat ~/.aws/credentials && cat ~/.aws/config
```

- Cuando nos empiece a pedir parámetros lo vamos metiendo. El "AWS Access Key ID" es el que nos ha dado el usuario de terraform al igual que el "AWS Secret Access Key", en "Default region name" ponemos nuestra reegion, en este caso ***eu-west-1*** y en el "Default output format" ponemos ***json***.

- Tenemos que cambiar tanto en el "Dockerice, el push, e integration-test" el usuario que hay por el nuestro para que nos haga a nuestro repo la creación de la imagen y todo lo que viene despues, en caso de querer omitir este paso al lanzar el "sudo make al" lo quitamos del all para que se ejecute solo lo que queramos. Al igual que en el "clean" en el "docker rmi" ponemos nuestro nombre de la imagen por si ya la tenemos creada que la borre.

Lo siguiente que vamos a configurar va a ser el login de docker, ya que para no tener contraseñas en el código, lo más sencillo es congifurarlo al igual que hemos hecho con AWS. La forma de hacerlo es la siguiente. Lanzamos el comando ```docker login``` desde el terminal y metemos nuestro usuario de DockerHub y nuestra contraseña. Nos dará un "Login Succeed" haciendonos ver si nos hemos equivocado al introducir las credenciales.

- Una vez configurado todos estos pasos, vamos a lanzar el make que para ello en el terminal dentro del directorio donde se encuentre el archivo "Makefile" vamos a ejecutar el siguiente comando, Lo vamos a ejecutar con sudo para que no nos de ningún fallo por falta de permisos. Al hacerlo con sudo nos pedirá nuestra contraseña y la ponemos.

```bash
sudo make
```
- Al finalizar el despliegue podemos ver con se nos ha desplegado nuestro deploy.
- El destroy lo tenemos que hacer con el "sudo make destroy" ya que no está incluido en el ALL



