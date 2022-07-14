defmodule Chat.MainsTest do
  use Chat.DataCase

  alias Chat.Mains

  describe "main" do
    alias Chat.Mains.Main

    import Chat.MainsFixtures

    @invalid_attrs %{name: nil}

    test "list_main/0 returns all main" do
      main = main_fixture()
      assert Mains.list_main() == [main]
    end

    test "get_main!/1 returns the main with given id" do
      main = main_fixture()
      assert Mains.get_main!(main.id) == main
    end

    test "create_main/1 with valid data creates a main" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Main{} = main} = Mains.create_main(valid_attrs)
      assert main.name == "some name"
    end

    test "create_main/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Mains.create_main(@invalid_attrs)
    end

    test "update_main/2 with valid data updates the main" do
      main = main_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Main{} = main} = Mains.update_main(main, update_attrs)
      assert main.name == "some updated name"
    end

    test "update_main/2 with invalid data returns error changeset" do
      main = main_fixture()
      assert {:error, %Ecto.Changeset{}} = Mains.update_main(main, @invalid_attrs)
      assert main == Mains.get_main!(main.id)
    end

    test "delete_main/1 deletes the main" do
      main = main_fixture()
      assert {:ok, %Main{}} = Mains.delete_main(main)
      assert_raise Ecto.NoResultsError, fn -> Mains.get_main!(main.id) end
    end

    test "change_main/1 returns a main changeset" do
      main = main_fixture()
      assert %Ecto.Changeset{} = Mains.change_main(main)
    end
  end
end
