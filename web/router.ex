defmodule PhoenixChina.Router do
  use PhoenixChina.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", PhoenixChina do
    pipe_through [:browser, :browser_session]

    get "/", PageController, :index
    get "/signup", UserController, :new
    post "/signup", UserController, :create
    get "/signin", SessionController, :new
    post "/signin", SessionController, :create
    get "/signout", SessionController, :delete

    get "/room", PageController, :room

    resources "/posts", PostController do
       resources "/comments", CommentController, except: [:index]
       post "/collects", PostCollectController, :create
       delete "/collects", PostCollectController, :cancel

       post "/praises", PostPraiseController, :create
       delete "/praises", PostPraiseController, :cancel
    end


    resources "/comments", CommentController, only: [] do
      post "/praises", CommentPraiseController, :create
      delete "/praises", CommentPraiseController, :cancel
    end

  end

  scope "/users", PhoenixChina do
     pipe_through [:browser, :browser_session]

     get "/:nickname", UserController, :show
     get "/:nickname/avatar", UserController, :avatar
     get "/:nickname/posts", PostController, :user_posts
     get "/:nickname/comments", UserController, :comments
     get "/:nickname/collects", UserController, :collects
     get "/:nickname/follower", UserController, :follower
     get "/:nickname/followed", UserController, :followed

     get "/password/forget", UserController, :password_forget
     post "/password/forget", UserController, :post_password_forget

     get "/password/reset", UserController, :password_reset
     put "/password/reset", UserController, :put_password_reset

     post "/:nickname/follows", UserFollowController, :create
     delete "/:nickname/follows", UserFollowController, :cancel
  end

  scope "/settings", PhoenixChina do
    pipe_through [:browser, :browser_session]

    get "/profile", UserController, :profile
    put "/profile", UserController, :put_profile

    get "/account", UserController, :account
    put "/account", UserController, :put_account
  end

  scope "/auth", PhoenixChina do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", PhoenixChina do
    pipe_through :api

    post "/upload", API.V1.UploadController, :create
  end
end
