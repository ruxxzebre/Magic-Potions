# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Saturday.Repo.insert!(%Saturday.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Saturday.Repo
alias Saturday.Entries.Entry

range =
  Saturday.Schedule.generate_range_new()
  |> Enum.map(&(&1.date))

for _ <- 1..100 do
  %Entry{
    agent_name: Faker.Person.first_name(),
    agent_phone: Faker.Phone.EnUs.phone(),
    booking_date: Saturday.Schedule.date_to_spec(Enum.random(range)),
    misc: Faker.Internet.email()
  } |> Repo.insert!()
end
