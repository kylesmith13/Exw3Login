defmodule MetamaskLogin.Encoding do
  def cache_sent_code(account, code) do
    Cachex.put(:login, "code:#{account}", code)
  end

  def fetch_sent_code(account) do
    Cachex.get!(:login, "code:#{account}")
  end

  def encode_sign_in_message_with_code(code) do
    Base.encode16("#{login_message()}. (Code: #{code})")
  end

  def login_message(), do: "Welcome to Elixir Metamask Login! Click sign to sign in."
end

# We have a flow ->
# send encoded message to user, cache code for later
# go get code to check thing
