defprotocol Animal do
  @fallback_to_any true
  def warn(arg, arg2)
  def greet(arg)
  def speak(arg)
end

defimpl Animal, for: Any do
  def greet(_), do: ""
  def warn(_, _), do: ""
  def speak(_), do: ""

  def kind(animal) do
    animal.__struct__
    |> Module.split()
    |> List.last()
    |> String.downcase()
  end

  def describe(animal) do
    "YOO IMMA GOOD #{Animal.kind(animal)} named by #{animal.name}!"
  end
end

# * defimpl is not required to be inside Dog module
defimpl Animal, for: Dog do
  def warn(dog, arg) do
    IO.puts("Warning, #{dog.name}! It is #{arg}!!!")
  end

  def greet(_) do
    IO.puts("Greetings!")
  end

  def speak(_) do
    IO.puts("Imma speaking!!!")
  end
end

defmodule Dog do
  defdelegate(kind(arg), to: Animal.Any)
  defdelegate(describe(arg), to: Animal.Any)

  @enforce_keys [:name]
  alias __MODULE__
  defstruct name: ""

  def new(name), do: %Dog{name: name}
end
