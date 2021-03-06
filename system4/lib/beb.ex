# Panayiotis Panayiotou (pp3414) and Adrian Catana (ac7815)
defmodule Beb do
  def start do
    receive do
      { :bind, pl, app } ->
        wait_pls pl, app
    end
  end

  defp wait_pls pl, app do
    receive do
      { :bind_peers, peers } ->
        next pl, peers, app
    end
  end

  defp next pl, peers, app do
    receive do
      { :timeout } -> :noop
      { :pl_deliver, from } ->
        send app, { :beb_deliver, from }
        next pl, peers, app
      { :beb_broadcast } -> broadcast pl, peers, app
      # We might want to add a message here
    end
  end

  # Broadcast while still receiving messages
  # and checking for timeout
  defp broadcast pl, peers, app do
    Enum.each(peers, fn peer ->
      receive do
          { :timeout } -> exit(:normal)
          { :pl_deliver, from } ->
            send app, { :beb_deliver, from }
      after
        0 -> 0
      end

      send pl, { :pl_send, peer, pl }
    end)
    next pl, peers, app
  end
end
