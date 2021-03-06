# Phoenix Framework - API only Phoenix boilerplate.

## What's in it ?

- Full Graphql support using [`absinthe`](https://absinthe-graphql.org/)
- Authentication using [`Guardian`](https://github.com/ueberauth/guardian)  
- S3 uploads and fetching and thumbailing images using arc,arc_ecto, ex_aws and ex_aws_s3.  

### Todo
- Add tests
- At present there are 3 models/schemas in this bolerplate. Users, Posts, and Chats. Graphql resolvers needs some refinements. Basically I need to setup assocations a bit better so that I can just preload these easily.
- Possibly integrate dataloader queries too. 
- Improve the way thumbnailing is done. Maybe check ImageProxy library for that ?  

### To start your Phoenix server:

- Run `docker-compose build` and `docker-compose run`

* Access graphql playround at [`localhost:4000/graphiql`](http://localhost:4000/graphiql) from your browser to see the graphql playground in action
* Access Phoenix live dashboard at [`localhost:4000/dashboard`](http://localhost:4000/dashboard)


* To run in production? Please [check the official deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
