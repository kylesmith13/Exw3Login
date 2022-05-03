defmodule MetamaskLogin.Encoding do
  def cache_sent_code(account, code) do
    Cachex.put(:login, "code:#{account}", encoded_sign_in_message_with_code(code))
  end

  def fetch_sent_code(account) do
    Cachex.get(:login, "code:#{account}")
  end

  def encoded_sign_in_message_with_code(code) do
    encoded_with_message = Base.encode16("#{decoded_sign_in_message()}. (Code: #{code})")
  end

  def decoded_sign_in_message() do
    Base.decode16!(Application.get_env(:metamask_login, :sign_message), case: :lower)
  end
end
