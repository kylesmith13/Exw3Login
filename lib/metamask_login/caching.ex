defmodule MetamaskLogin.Caching do
  @moduledoc """
  Caching helper functions
  """
  def cache_sent_code(account, code) do
    Cachex.put(:login, "code:#{account}", code)
  end

  def fetch_sent_code(account) do
    Cachex.get!(:login, "code:#{account}")
  end
end
