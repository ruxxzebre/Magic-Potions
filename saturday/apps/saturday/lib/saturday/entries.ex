defmodule Saturday.Entries do
  @moduledoc """
  The Entries context.
  """

  import Ecto.Query, warn: false
  alias Saturday.Repo

  alias Saturday.Entries.Entry

  @doc """
  Returns the list of entries.

  ## Examples

      iex> list_entries()
      [%Entry{}, ...]

  """
  def list_entries do
    Repo.all(Entry)
  end

  def string_to_map(string) do
    if !String.contains?(string, ":") do
      %{}
    else
      string
      |> String.split(",")
      |> Enum.map(&String.split(&1, ":"))
      |> Enum.reduce(%{}, &(Map.put(&2,
        Enum.at(&1, 0) |> String.trim(),
        Enum.at(&1, 1) |> String.trim()
      )))
    end
  end

  def list_entries(:format_fields) do
    Repo.all(Entry)
    |> Enum.map(fn entry ->
      entry
      |> Map.update!(:booking_date, fn date ->
        date = Saturday.Schedule.date_from_spec(date)
        Saturday.Schedule.format_date!(date, with_time: true)
      end)
      |> Map.update!(:inserted_at, &Saturday.Schedule.format_date!/1)
      |> Map.put(:email, string_to_map(entry.misc) |> Map.get("email", entry.misc))
    end)
  end

  def list_entries(:only_dates, opts \\ []) do
    query = from(
      e in Entry,
      select: e.booking_date
    )

    # Map.get(string_to_map(entry.misc), "email", entry.misc)
    list = Repo.all(query)
    cond do
      :parse_spec in opts ->
        list
        |> Enum.map(&Saturday.Schedule.date_from_spec/1)
      true -> list
    end
  end

  @doc """
  Gets a single entry.

  Raises `Ecto.NoResultsError` if the Entry does not exist.

  ## Examples

      iex> get_entry!(123)
      %Entry{}

      iex> get_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_entry!(id), do: Repo.get!(Entry, id)

  def booked?(date) do
    Repo.get_by(Entry, booking_date: date) != nil
  end

  @doc """
  Creates a entry.

  ## Examples

      iex> create_entry(%{field: value})
      {:ok, %Entry{}}

      iex> create_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry(attrs \\ %{}) do
    %Entry{}
    |> Entry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a entry.

  ## Examples

      iex> update_entry(entry, %{field: new_value})
      {:ok, %Entry{}}

      iex> update_entry(entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry(%Entry{} = entry, attrs) do
    entry
    |> Entry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a entry.

  ## Examples

      iex> delete_entry(entry)
      {:ok, %Entry{}}

      iex> delete_entry(entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry(%Entry{} = entry) do
    Repo.delete(entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry changes.

  ## Examples

      iex> change_entry(entry)
      %Ecto.Changeset{data: %Entry{}}

  """
  def change_entry(%Entry{} = entry, attrs \\ %{}) do
    Entry.changeset(entry, attrs)
  end
end
