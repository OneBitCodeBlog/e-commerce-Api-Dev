# Iniciando o Projeto

Nesta aula vamos dar os primeiros passos para iniciar o nosso projeto.

1- Estamos utilizando o gerenciador de versões ASDF. Optamos por seguir por ele por ter plugins que conseguem gerenciar versões de diversas linguagens utilizando plugins. Para instalar, basta ir a este link:

https://asdf-vm.com/#/core-manage-asdf-vm



2- Antes de começarmos a instalação do Ruby e do Rails, vamos precisa instalar o pacote de desenvolvimento do OpenSSL.

- Se vc for usuário de distros derivadas do Debian, execute:

```shell
sudo apt install libssl-dev
```

- Se for de alguma distro derivada do RedHat:

```shell
yum install openssl-devel
```



3- Agora vamos adicionar o plugin do ASDF para Ruby. Para isso, execute no seu terminal:

```shell
asdf plugin add ruby
```



4- Após o plugin ser adicionado, vamos instalar a versão 2.7.1 do Ruby. Execute no terminal:

```shell
asdf install ruby 2.7.1
```



5- No meu caso, vou deixar o Ruby 2.7.1 como padrão com o comando:

```
asdf global ruby 2.7.1
```



6- Após isso, podemos instalar o Rails

```shell
gem install rails -v '6.0.3.3'
```

> A versão mais atual que temos do Rails no momento da gravação deste vídeo é a 6.0.3.3



7- Antes de inicializarmos o app, precisamos instalar uma biblioteca que o drive do Postgres utiliza.

- Se for usuário de distros derivadas do Ubuntu, execute:

```shell
sudo apt install libpq-dev
```

- Se for derivada Redhat, execute:

```shell
yum install postgresql-devel
```



8- Após a instalação, podemos iniciar nossa api

```shell
rails new ecommerce-api --api -d postgresql -T
```



9- Vamos fazer uma pequena alteração no nosso database.yml para poder utilizar as configs do Postgres. No meu caso, os usuários e senha do meu banco local é 'postgres'. Então vou deixar todo o conteúdo dele deste jeito:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  user: <seu usuário>
  password: <sua senha>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: ecommerce_api_development

test:
  <<: *default
  database: ecommerce_api_test

production:
  <<: *default
  database: ecommerce_api_production
  username: ecommerce_api
  password: <%= ENV['ECOMMERCE_API_DATABASE_PASSWORD'] %>
```



10- Com o Rails inicializado, podemos entrar no diretório e criar o banco

```
cd ecommerce-api
rails db:create
```



11- Também vou configurar a versão local do Ruby para 2.7.1.

```
asdf local ruby 2.7.1
```

> É imporante lembrar que esta configuração só é válida para o ASDF, não tem nenhuma ligação com o Rails em sí. Quando queremos travar uma versão para um projeto Rails, ela é feita no **Gemfile**.
>
> Repare que no **Gemfile** há uma linha `ruby '2.7.1'` que é justamente pra isso.



12- Agora podemos iniciar o servidor

```
rails s
```



13- Agora basta irmos na nossa ferramenta de request e testar a URL raiz

> Não precisa estranhar que na resposta do Request vai aparecer a página HTML do Rails. Por mais que a gente tenha configurado para o modo API, o Welcome do Rails retorna sempre HTML





**BRANCH:** *master*