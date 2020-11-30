# E-commerce OpenSource Onebitcode =)

This is an OpenSource API for a Game E-commerce project.

It was first created with learning purposes, it's the code of the new Bootcamp from Onebitcode. But the idea behind this project is so bigger than us that we decided to open it for everyone.

It was designed thinking first in Game products, with digital delivery. But it's up to you to get this code and transform in anything you want.

I need to warning you, it still a working in progress. So, if you need a complete one, it's not ready yet.

## Stack

- Rails 6.0.3.3
- Postgres
- Devise Token Auth for authentication
- Jbuilder for rendering

## How to use it?

Basically we have some endpoints to be used by users with specifically permissions.

We have two profiles on app: `admin` and `client`.

**Admin** is the person responsible to manage everything. He can CRUD *Category*, *Product*, *System Requirement* and *License*.\
**Client** is the profile permitted to make and order.\
And we also have **unauthenticated** routes as Product lists and searching.

## Building application

Ok, so first you must have:

1. Postgres installed.

2. Ruby >= 2.5.0 installed (minimum required for Rails 6.0.3.3, version we're working with).

3. As we're on the beginning of project, don't forget to right configure your `datatabe.yml`.

4. And to *bundle* it with command:

```
bundle install
```
As soon as you have everything done you can follow


### 1. Task to build dev environment

You can optionally run this **task** to setup all you dev environment and create some test data.

```
rails dev:prime
```

### 2. Manually building everything

If you want to rock and create your dev environment and data, it's possible to go through the usual way

1. Create databases
```
rails db:create
```

2. Run migrations
```
rails db:migrate
```

3. Start the server
```
rails s
```

If you want to run tests: 
```
bundle exec rspec
```

## How can I use API?

Well, we here a file if you want to import on Postman

[Postman File](https://drive.google.com/file/d/1p0vJ7h5IlF3k_HcsnUq8TAihB_Y6uH0P/view?usp=sharing)


There is also a database model in PDF and in a Navicat file

[Here is the PDF](https://drive.google.com/file/d/1Vw8RvgfswVDQMF7IrI-psJ4s5X6_aqiR/view?usp=sharing)
[And here is the Navicat File](https://drive.google.com/file/d/1avsMHPC2_S2Fr3jmnVnfJvXhrkVevCQA/view?usp=sharing)


### Scopes

We have 3 base scopes: 
- **/auth** 
- **/admin**
- **/storefront**

And each scope has it's own versioning. For example, we have **/admin/v1**, **/auth/v1** and so on.\
At this moment **/admin/v1** is under development and **/auth/v1** is already completed. **/storefront** is a our next step to begin.


### Authentication

On **/auth/v1** we're using **Devise Token Auth** for authentication with **Token Refresh** technique.\
It is **stateless** and for login you need to send *user* and *password* and will receive headers you must send on your requests to the APIs and theses headers are:
- *access-token*
- *client*
- *expiry*
- *token-type*
- *uid*

On each request you made, *access-token* changes and you will receive a new one on response header to be sent on the next request. It is how **Token Refresh** works.

If you want to know more about **Devise Token Auth**, you can access [its repository](https://github.com/lynndylanhurley/devise_token_auth)

### API serialization

To serialize data, we're not using any JSON rendering standard. As this application has as purpose to work only with specific tools and not to be a **public API**, we don't saw any needing of adopt none of these. You can check structure we're using on `app/views`.
