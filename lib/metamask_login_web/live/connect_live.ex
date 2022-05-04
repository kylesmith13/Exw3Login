defmodule MetamaskLoginWeb.ConnectLive do
  use MetamaskLoginWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, %{current_account: nil, signed_in: false})
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div>
        <.live_component module={MetamaskLoginWeb.LoginButton} id="asdf" current_account={@current_account} signed_in={@signed_in} />
      </div>
    """
  end

  def handle_event("js:mounted", %{"currentAccount" => current_account}, socket) do
    {:ok, signed_in} = Cachex.get(:login, "signed_in:#{current_account}")
    {:noreply, assign(socket, %{current_account: current_account, signed_in: signed_in})}
  end

  def handle_info({:sign_in}, socket) do
    {:noreply, assign(socket, :signed_in, true)}
  end

  def handle_info({:sign_out}, socket) do
    {:noreply, assign(socket, :signed_in, false)}
  end
end
