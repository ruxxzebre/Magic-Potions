defmodule Saturday.Entries.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :agent_name, :string
    field :agent_phone, :string
    field :booking_date, :string
    field :misc, :string

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:booking_date, :agent_name, :agent_phone, :misc])
    |> validate_required([:booking_date, :agent_name, :agent_phone, :misc])
  end
end
