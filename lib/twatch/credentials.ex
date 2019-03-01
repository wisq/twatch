defmodule Twatch.Credentials do
  @enforce_keys [:username, :password]
  defstruct(
    username: nil,
    password: nil
  )
end

defimpl Inspect, for: Twatch.Credentials do
  import Inspect.Algebra

  def inspect(cred, opts) do
    concat(["#Credentials<", to_doc(cred.username, opts), ">"])
  end
end
