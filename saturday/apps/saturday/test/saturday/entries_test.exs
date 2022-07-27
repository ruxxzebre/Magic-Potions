defmodule Saturday.EntriesTest do
  use Saturday.DataCase

  alias Saturday.Entries

  describe "entries" do
    alias Saturday.Entries.Entry

    import Saturday.EntriesFixtures

    @invalid_attrs %{
      agent_name: nil,
      agent_phone: nil,
      booking_date: nil,
      created_at: nil,
      misc: nil
    }

    test "list_entries/0 returns all entries" do
      entry = entry_fixture()
      assert Entries.list_entries() == [entry]
    end

    test "get_entry!/1 returns the entry with given id" do
      entry = entry_fixture()
      assert Entries.get_entry!(entry.id) == entry
    end

    test "create_entry/1 with valid data creates a entry" do
      valid_attrs = %{
        agent_name: "some agent_name",
        agent_phone: "some agent_phone",
        booking_date: ~D[2022-07-25],
        created_at: ~D[2022-07-25],
        misc: "some misc"
      }

      assert {:ok, %Entry{} = entry} = Entries.create_entry(valid_attrs)
      assert entry.agent_name == "some agent_name"
      assert entry.agent_phone == "some agent_phone"
      assert entry.booking_date == ~D[2022-07-25]
      assert entry.created_at == ~D[2022-07-25]
      assert entry.misc == "some misc"
    end

    test "create_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Entries.create_entry(@invalid_attrs)
    end

    test "update_entry/2 with valid data updates the entry" do
      entry = entry_fixture()

      update_attrs = %{
        agent_name: "some updated agent_name",
        agent_phone: "some updated agent_phone",
        booking_date: ~D[2022-07-26],
        created_at: ~D[2022-07-26],
        misc: "some updated misc"
      }

      assert {:ok, %Entry{} = entry} = Entries.update_entry(entry, update_attrs)
      assert entry.agent_name == "some updated agent_name"
      assert entry.agent_phone == "some updated agent_phone"
      assert entry.booking_date == ~D[2022-07-26]
      assert entry.created_at == ~D[2022-07-26]
      assert entry.misc == "some updated misc"
    end

    test "update_entry/2 with invalid data returns error changeset" do
      entry = entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Entries.update_entry(entry, @invalid_attrs)
      assert entry == Entries.get_entry!(entry.id)
    end

    test "delete_entry/1 deletes the entry" do
      entry = entry_fixture()
      assert {:ok, %Entry{}} = Entries.delete_entry(entry)
      assert_raise Ecto.NoResultsError, fn -> Entries.get_entry!(entry.id) end
    end

    test "change_entry/1 returns a entry changeset" do
      entry = entry_fixture()
      assert %Ecto.Changeset{} = Entries.change_entry(entry)
    end
  end
end
