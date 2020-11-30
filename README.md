# E-commerce OpenSource Onebitcode =)

This is an OpenSource API for a Game E-commerce project.

It was first created with learning purposes, it's the code of the new Bootcamp from Onebitcode. But the idea behind this project is so bigger than us that we decided to open it for everyone.

It was designed thinking first in Game products, with digital delivery. But it's up to you to get this code and transform in anything you want.

I need to warning you, it still a working in progress. So, if we need a complete one, it's not ready yet.

## How to use it?

Basically we have some endpoints to be used by users with specifically permissions.

We have two profiles on app: `admin` and `client`.

**Admin** is the person responsible to manage everything. He can CRUD *Category*, *Product*, *System Requirement* and *License*.
**Client** is the profile permitted to make and order.
And we also have **unauthenticated** routes as Product lists and searching.


## Building application

Ok, so first you must have:

1. Postgres installed

2. Ruby >= 2.5.0 installed (minimum required for Rails 6.0.3.3, version we're working with)

3. As we're on the beginning of project, don't forget to right configure your `datatabe.yml`

As soon as you have everything done:

1. Bundle application
```
bundle install
```

2. Create databases
```
rails db:create
```

3. Run migrations
```
rails db:migrate
```

4. Start the server
```
rails s
```

If you want to run tests: 
```
bundle exec rspec
```


## And how can I use API?

Well, we here a file if you want to import on Postman

[And this one for Postman](https://drive.google.com/file/d/1p0vJ7h5IlF3k_HcsnUq8TAihB_Y6uH0P/view?usp=sharing)


There is also a database model in PDF and in a Navicat file

[And here is the PDF](https://drive.google.com/file/d/1Vw8RvgfswVDQMF7IrI-psJ4s5X6_aqiR/view?usp=sharing)
[And here is the Navicat File](https://drive.google.com/file/d/1avsMHPC2_S2Fr3jmnVnfJvXhrkVevCQA/view?usp=sharing)
