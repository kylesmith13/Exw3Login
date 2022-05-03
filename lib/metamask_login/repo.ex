defmodule MetamaskLogin.Repo do
  use Ecto.Repo,
    otp_app: :metamask_login,
    adapter: Ecto.Adapters.Postgres
end
