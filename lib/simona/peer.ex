defmodule Simona.Peer do
  @moduledoc """
  based https://github.com/rosettacash/bitcoin-elixir/blob/develop/lib/bitcoin/node/network/peer.ex
  """
  alias Simona.Discoverer
  alias Simona.Message
  alias Simona.NetworkAddress
  alias Simona.Util
  use GenServer

  @default_listen_port 8333
  @default_services <<1, 0, 0, 0, 0, 0, 0, 0>>
  @protocol_version 70002
  @user_agent "/simona:0.0.0/"

  @default_config %{
    listen_ip: {0,0,0,0},
    listen_port: @default_listen_port,
    max_connections: 8,
    user_agent: @user_agent,
    data_directory: Path.expand("~/.simona/bsv"),
    services: @default_services
  }

  @version_fields %{
    height: 1,
    nonce: Util.nonce64(),
    relay: true,
    services: @default_services,
    timestamp: Util.timestamp(),
    version: @protocol_version,
    user_agent: @user_agent
  }

  @protocol_version 70002





  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    ip = Discoverer.get_rand_peer()

    state = %{ip: ip, port: @default_port}

    send(self(), :connect)
    {:ok, state}
  end

  def handle_info(:connect, %{ip: ip, port: port}=state) do
    case :gen_tcp.connect(ip, port, [:binary, active: true]) do
      {:ok, socket} ->
        send(self(), :handshake)
        {:ok, state |> Map.put(:socket, socket)}
      {:error, :etimeout} ->
        state |> disconnect(:connection_timeout)
      {:error, _} ->
        state |> disconnect(:connection_error)
    end
  end

  def handle_info(:handshake, state) do
    node_config = @default_config

    pkt = %Message.Version{
      address_of_receiving_node: %NetworkAddress{
        address: state.ip,
        port: state.port,
        },
      address_of_sending_node: %NetworkAddress{
        address: node_config.listen_ip,
        port: node_config.listen_port,
        services: node_config.services,
        },
    }
    |> Map.merge(@version_fields)
    |> Message.serialize()

    :ok = state.socket |> :gen_tcp.send(pkt)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg, label: "msg: ")
    {:noreply, state}
  end

end
