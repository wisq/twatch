defmodule Twatch.Config do
  @enforce_keys [:start_url, :page_handlers]
  defstruct(
    start_url: nil,
    page_handlers: []
  )
end
