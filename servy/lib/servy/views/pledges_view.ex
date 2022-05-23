defmodule Servy.PledgeView do
  require EEx

  @templates_path Path.expand("../../../templates", __DIR__)

  EEx.function_from_file(
    :def,
    :create_pledge,
    Path.join(@templates_path, "create_pledge.eex"),
    []
  )

  EEx.function_from_file(
    :def,
    :recent_pledges,
    Path.join(@templates_path, "recent_pledges.eex"),
    [
      :recent_pledges
    ]
  )
end
