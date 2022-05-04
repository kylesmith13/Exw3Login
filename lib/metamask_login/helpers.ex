defmodule MetamaskLogin.Helpers do
  def login_message(), do: "Welcome to Elixir Metamask Login! Click sign to sign in."

  def shortened_address(address) do
    h = String.slice(address, 0, 4)
    t = String.slice(address, -4, 4)
    "#{h}...#{t}"
  end
end

# We have a flow ->
# send encoded message to user, cache code for later
# go get code to check thing
