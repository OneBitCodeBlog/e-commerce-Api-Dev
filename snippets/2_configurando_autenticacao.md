# Configurando a Autenticação

## 1. Introdução

Nesta aula vamos configurar a autenticação do Devise. Aqui vamos utilizar uma técnica de login que utiliza usuário e senha para retornar um token para o usuário. A cada request que o usuário envia, ele vai receberá a resposta e um novo token para utilizar no próximo request.

[MOSTRAR UM DESENHO COM O *TOKEN REFRESH*]

Então, caso o usuário tente enviar uma request com um token "velho", ele será impedido. Para isso, nós vamos utilizar o **Devise** junto com a o **Devise Token Auth**, uma gem que já cuida disso.



## 2. Conteúdo

1- Vamos começar limpando o `Gemfile`, removendo os comentários que tem lá. Nosso `Gemfile` ficará assim:

```ruby
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'rails', '~> 6.0.3', '>= 6.0.3.3'

# Basic
gem 'bootsnap', '>= 1.4.2', require: false
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

> Apenas removemos o monte de comentário que havia lá e estamos organizando



2- Vamos começar instalando o Devise e o Devise Token Auth. 

*[Adicione no `Gemfile`]*

```ruby
...
gem 'puma', '~> 4.1'

# Auth
gem 'devise_token_auth', '~> 1.1.4'

...
```



3- Agora podemos instalar.

*[Execute no terminal]*

```shell
bundle install
```

Quando executarmos este comando, teremos um problema porque esta versão do Devise Token Auth utiliza o Sprockets versão `3.7.1`. E quando instalamos o Rails 6, o Sprockets instalado foi o `4.0.2`. Então precisamos executar um update para que deixe compatível de forma que atenda tanto o Rails quanto o Devise Token Auth.

*[Execute no terminal]*

```shell
bundle update
```



4- Agora vamos inicializar no nosso projeto

*[Execute no terminal]*

```shell
rails g devise:install
rails g devise_token_auth:install User api/v1/auth
```

> Este comando segue uma sintaxe onde colocamos como atributo o model que queremos utilizar para gerenciar e o caminho da rota. No caso, queremos o model `User` e o caminho `api/v1/auth`.

Com este comando ele adiciona um `include` no **ApplicationController**, que nós vamos remover.

*[Remova a linha 02 de `app/controllers/application_controller.rb`]*

```ruby
include DeviseTokenAuth::Concerns::SetUserByToken
```



5- Ele gerou diversos arquivos. Agora vamos configurar alguns deles começando pelo arquivo de incialização do **Devise Token Auth**. Primeiro vamos habilitar a troca de token a cada request descomentando a seguinte linha:

*[Descomentar a linha 08 do arquivo `config/initializers/devise_token_auth.rb`]*

```ruby
config.change_headers_on_each_request = true
```

Agora vamos configurar para o token expirar a cada 1 semana

*[Descomentar a linha 12 e alterar o valor para 1 semana]*

```ruby
config.token_lifespan = 1.week
```

E por fim vamos alterar a configuração para request em massa. Esta configuração existe para definir um tempo máximo em que um token pode ser utilizado novamente, isso se deve porque podem haver casos onde vários requests precisam ser enviados de uma só vez.

*[Descomentar a linha 27]*

```ruby
config.batch_request_buffer_throttle = 5.seconds
```



6- Na migration do criada, nós vamo remover os campos de `nickname` de `image`.

*[Remova as linhas 33 e 34 do arquivo `db/migrate/<timespamp>_devise_token_auth_create_users.rb`]*

```ruby
t.string :nickname
t.string :image 
```

> O campo `nickname` a gente não vai utilizar e o `image` vamos utilizar através do Active Storage

E agora podemos executar a migration

*[Execute no terminal]*

```shell
rails db:migrate
```





7- Agora vamos criar a base de diretórios para os controllers do nosso app. Lembrando que teremos tanto API Admin quanto uma para a própria loja. Então, basicamente criaremos aqui dois escopos de API isolados, uma para a loja e outro para a área Admin, cada um com sua própria API e versões.

*[Execute no terminal]*

```shell
rails g controller admin/v1/api_controller
rails g controller storefront/v1/api_controller
```



8- Estas duas APIs vão utilizar o método de autenticação do Devise Token Auth. Porém, vamos mapeá-lo para dentro da versão de cada API, para que possamos deixar em aberto a possibilidade de outras autenticações em versões futuras. Como as duas vão compartilhar a autenticação, vamos criar um **concern** para ele.

*[Execute no terminal]*

```shell
touch app/controllers/concerns/devise_token_authenticatable.rb
```

E dentro deste arquivo, vamos configurar a inclusão do DeviseTokenAuth e chamar o método de autenticação

*[Adicione em `app/controllers/concerns/devise_token_authenticatable.rb]*

```ruby
module DeviseTokenAuthenticatable
  extend ActiveSupport::Concern

  included do
    include DeviseTokenAuth::Concerns::SetUserByToken
    before_action :authenticate_user!
  end
end
```

> Para definir um **concern** do Rails, precisamos criar um módulo e extender o **ActiveSupport::Concern**. Depois disso, utilizamos o método `included`, que será chamado quando o concern for incluído dentro de uma classe. No caso, queremos que este *concern* seja capaz de importar um recurso do **DeviseTokenAuth** e chamar o método de autenticação



9- Com o concern pronto, podemos importá-lo nas nossas duas classes base do `admin` e do `storefront`.

*[Adicione em `app/controllers/admin/v1/api_controller.rb`]*

```ruby
module Admin::V1
  class ApiController < ApplicationController
    include DeviseTokenAuthenticatable
  end
end
```

*[Adicione em `app/controllers/storefront/v1/api_controller.rb`]*

```ruby
class Storefront::V1
  class ApiController < ApplicationController
    include DeviseTokenAuthenticatable
  end
end
```



10- Agora vamos editar as nossas rotas e incluir os escopos para as futuras rotas que criaremos tanto para **Admin** quanto para o **Storefront**

*[Deixe o arquivo `config/routes.rb` com o seguinte conteúdo]*

```ruby
Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth/v1/user'
  
  namespace :admin do
    namespace :v1 do
    end
  end

  namespace :storefront do
    namespace :v1 do
    end
  end
end
```

> Repare que estamos definindo um escopo isolado também para a autenticação. Como queremos que haja somente um login tanto para **Admin** quanto para **Storefront**, o design dos enpoints soa melhor deixando a autenticação como um recurso REST separado



11- Agora, como parte final, vamos criar uma rota de exemplo em Admin só pra ver se estamos funcionando bem.

Primeiro vamos criar um controller **HomeController** com um action `index` e depois uma rota associá-lo

*[Execute no terminal]*

```shell
rails g controller admin/v1/home index
```

No controller criado, vamos adicionar um render JSON para teste

*[Adicione em `app/controllers/admin/v1/home_controller.rb`]*

```ruby
module Admin::V1
  class HomeController < ApiController
    def index
      render json: { message: "Success" }
    end
  end
end
```

A rota que foi criada, nós vamos alterar para ficar dentro do namespace **Admin** que já criamos. Então vamos remover o que ele gerou e adicionar o seguinte

*[Adicione em `config/routes.rb`]*

```ruby
...

namespace :admin do
  namespace :v1 do
    resources :home, only: :index
  end
end
  
...
```



12- Agora vamos testar nossas rotas

*[Realizar o seguinte teste nos Endpoints]*

1. Enviar request para `localhost:3000/admin/v1/home`
2. Fazer o cadastro em `localhost:3000/auth/v1/users`
3. Fazer o login em `localhost:3000/auth/v1/users/sign_in`
4. Pegar os itens do HEADER
5. Enviar request para com os dados HEADER `localhost:3000/admin/v1/home`



13- Sabendo que estamos com tudo funcionando, podemos remover este controler de teste que criamos

*[Remova o arquivo `app/controllers/admin/v1/home_controller.rb`]*

*[Remova a linha 06 do arquivo `config/routes.rb`]*

```ruby
resources :home, only: :index
```



**BRANCH:** *config_auth*