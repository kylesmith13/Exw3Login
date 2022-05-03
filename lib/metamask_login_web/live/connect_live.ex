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

  def handle_event("connect", %{"sig" => sig}, %{assigns: %{current_account: current_account}} = socket) do
    cached_message = MetamaskLogin.Encoding.decode_sent_message(current_account)
    case ExWeb3EcRecover.recover_personal_signature(cached_message, sig) do
      {:error, :recovery_failure} ->
        # show some kind of error message
        Cachex.put(:login, "signed_in:#{current_account}", false)
        {:noreply, assign(socket, :signed_in, false)}
      key ->
        if key == current_account do
          # log someone in
          IO.inspect(key)
          Cachex.put(:login, "signed_in:#{current_account}", true)
          socket = assign(socket, :signed_in, true)
          {:noreply, socket}
        else
          Cachex.put(:login, "signed_in:#{current_account}", false)
          {:noreply, assign(socket, :signed_in, false)}
        end
    end
  end


  def handle_event("sign_out", _value, %{assigns: %{current_account: current_account}} = socket) do
    Cachex.put(:login, "signed_in:#{current_account}", false)
    {:noreply, assign(socket, %{signed_in: false})}
  end

  defp connect(), do: JS.dispatch("js:connect")
  defp sign_in(%{current_account: account} = _assigns) do
    code = Enum.random(1_000..9_999)
    encoded_message = MetamaskLogin.Encoding.cache_sent_message(account, code)
    IO.inspect(encoded_message)
    JS.dispatch("js:sign_in", detail: encoded_message)
  end
end
