defmodule Saturday.ConfigStorage do
  def init_config_table() do
    name = :service_configurations
    :ets.new(name, [
      :named_table,
      read_concurrency: true
    ])
    name
  end

  def config_table_name(), do: :service_configurations

  def set_data(:ruleset, data) do
    :ets.insert(config_table_name(), {:ruleset, data})
  end

  def set_data(key, value) when is_atom(key) do
    # raise invalid_key_error()
    :ets.insert(config_table_name(), {key, value})
  end

  def get_data(:ruleset) do
    Keyword.get(:ets.lookup(config_table_name(), :ruleset), :ruleset, nil)
  end

  def get_data(key) when is_atom(key) do
    Keyword.get(:ets.lookup(config_table_name(), key), key, nil)
    # raise invalid_key_error()
  end

  def invalid_key_error(), do: "Invalid configuration key."
end
