defmodule MetamaskLogin.Encoding do
  def cache_sent_message(account, code) do
    encoded_message = encoded_sign_in_message_with_code(code)
    Cachex.put(:login, "code:#{account}", encoded_message)
    encoded_message
  end

  def decode_sent_message(account) do
    MetamaskLogin.Encoding.fetch_sent_code(account)
    |> Base.decode16!()
  end

  def fetch_sent_code(account) do
    Cachex.get!(:login, "code:#{account}")
  end

  def encoded_sign_in_message_with_code(code) do
    Base.encode16("#{decoded_sign_in_message()}. (Code: #{code})", case: :upper)
  end

  def decoded_sign_in_message() do
    Base.decode16!(Application.get_env(:metamask_login, :sign_message), case: :upper)
  end
end
