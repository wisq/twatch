defmodule Twatch.Actions do
  alias Twatch.Actions.{Login, Category, Stream}

  def ensure_logged_in(creds), do: fn -> Login.ensure_logged_in(creds) end
  def pick_first_stream, do: fn -> Category.pick_first_stream() end
  def ensure_category(name), do: fn -> Stream.ensure_category(name) end
  def ensure_not_hosting, do: fn -> Stream.ensure_not_hosting() end
end
