defmodule MetamaskLoginWeb.ConnectLive do
  use MetamaskLoginWeb, :live_view
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    socket = assign(socket, %{current_account: nil, signed_in: false})
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div id="metamask-button" phx-hook="Metamask">
        <%= cond do %>
          <% is_nil(@current_account) -> %>
            <button id="connect-button" phx-click={connect()}> Connect to Metamask </button>
          <% @signed_in -> %>
            <p> YOU DID IT </p>
            <button id="sign out" phx-click="sign_out">Sign Out</button>
          <% true -> %>
            <button id="connect-button" phx-click={sign_in(assigns)}>Sign In</button>
        <% end %>
      </div>
    """
  end

  def handle_event("js:mounted", %{"currentAccount" => current_account}, socket) do
    {:ok, signed_in} = Cachex.get(:login, "signed_in:#{current_account}")
    {:noreply, assign(socket, %{current_account: current_account, signed_in: signed_in})}
  end

  def handle_event("connect", %{"sig" => sig, "currentAccount" => current_account}, socket) do
    {:ok, cached_code} = MetamaskLogin.Encoding.fetch_sent_code(current_account)
    case ExWeb3EcRecover.recover_personal_signature(cached_code, sig) do
      {:error, :recovery_failure} ->
        # show some kind of error message
        Cachex.put(:login, "signed_in:#{current_account}", false)
        {:noreply, socket}
      key ->
        # log someone in
        Cachex.put(:login, "signed_in:#{current_account}", true)
        socket = assign(socket, :signed_in, true)
        {:noreply, socket}
    end
  end


  def handle_event("sign_out", _value, %{assigns: %{current_account: current_account}} = socket) do
    Cachex.put(:login, "signed_in:#{current_account}", false)
    {:noreply, assign(socket, %{signed_in: false})}
  end

  defp connect(), do: JS.dispatch("js:connect")
  defp sign_in(%{current_account: account} = assigns) do
    code = Enum.random(1_000..9_999)
    MetamaskLogin.Encoding.cache_sent_code(account, code)
    JS.dispatch("js:sign_in", detail: MetamaskLogin.Encoding.encoded_sign_in_message_with_code(code))
  end
end
