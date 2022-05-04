defmodule MetamaskLogin.Encoding do
  alias MetamaskLogin.Helpers

  def encode_sign_in_message_with_code(code) do
    Base.encode16("#{Helpers.login_message()}. (Code: #{code})")
  end
end
