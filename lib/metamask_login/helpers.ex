defmodule MetamaskLogin.Helpers do
  @moduledoc """
  File for general helpers. Break into other files if functions in here become more specific
  """
  def login_message(), do: "Welcome to Elixir Metamask Login! Click sign to sign in."

  def shortened_address(address) do
    h = String.slice(address, 0, 4)
    t = String.slice(address, -4, 4)
    "#{h}...#{t}"
  end
end
