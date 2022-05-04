defmodule MetamaskLoginWeb.LoginButton do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias MetamaskLogin.Encoding
  alias MetamaskLogin.Helpers
  alias MetamaskLogin.Caching

  def render(assigns) do
    ~H"""
      <div id="metamask-container" phx-hook="Metamask">
        <%= cond do %>
          <% is_nil(@current_account) -> %>
            <button id="connect-button" phx-click={connect()} phx-target={@myself}> Connect Wallet </button>
          <% @signed_in -> %>
            <button id="sign out" phx-click="sign_out" phx-target={@myself}>Log Out <%= Helpers.shortened_address(@current_account) %></button>
          <% true -> %>
            <div phx-click={sign_in(assigns)} phx-target="#metamask-container">Web3 Login
            </div>
        <% end %>
      </div>
    """
  end

  def handle_event(
        "connect",
        %{"sig" => sig},
        %{assigns: %{current_account: current_account}} = socket
      ) do
    cached_code = Caching.fetch_sent_code(current_account)
    message = "#{Helpers.login_message()}. (Code: #{cached_code})"

    case ExWeb3EcRecover.recover_personal_signature(message, sig) do
      {:error, :recovery_failure} ->
        # show some kind of error message
        Cachex.put(:login, "signed_in:#{current_account}", false)
        {:noreply, assign(socket, :signed_in, false)}

      key ->
        if key == current_account do
          # log someone in
          Cachex.put(:login, "signed_in:#{current_account}", true)
          send(self(), {:sign_in})
          {:noreply, assign(socket, :signed_in, true)}
        else
          # log someone out
          Cachex.put(:login, "signed_in:#{current_account}", false)
          send(self(), {:sign_out})
          {:noreply, assign(socket, :signed_in, false)}
        end
    end
  end

  def handle_event("sign_out", _value, %{assigns: %{current_account: current_account}} = socket) do
    Cachex.put(:login, "signed_in:#{current_account}", false)
    send(self(), {:sign_out})
    {:noreply, socket}
  end

  defp connect(), do: JS.dispatch("js:connect")

  defp sign_in(%{current_account: account} = _assigns) do
    code = Enum.random(1_000..9_999)
    Caching.cache_sent_code(account, code)
    JS.dispatch("js:sign_in", detail: Encoding.encode_sign_in_message_with_code(code))
  end
end
