defmodule Twatch.Actions do
  alias Twatch.Actions.{Login, Category, Stream, Image}

  def ensure_logged_in(creds), do: fn -> Login.ensure_logged_in(creds) end
  def pick_stream(range), do: fn -> Category.pick_stream(range) end
  def ensure_category(name), do: fn -> Stream.ensure_category(name) end
  def ensure_not_hosting, do: fn -> Stream.ensure_not_hosting() end
  def ensure_mature_accepted, do: fn -> Stream.ensure_mature_accepted() end

  def ensure_image_changing do
    {:ok, path} = Briefly.create(directory: true)
    fn ->
      Image.ensure_image_changing(path)
    end
  end
end
