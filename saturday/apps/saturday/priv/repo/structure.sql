CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" INTEGER PRIMARY KEY, "inserted_at" TEXT_DATETIME);
CREATE TABLE IF NOT EXISTS "entries" ("id" INTEGER PRIMARY KEY, "booking_date" DATE, "agent_name" TEXT, "agent_phone" TEXT, "created_at" DATE, "misc" TEXT, "inserted_at" TEXT_DATETIME NOT NULL, "updated_at" TEXT_DATETIME NOT NULL);
CREATE TABLE IF NOT EXISTS "vehicles" ("id" INTEGER PRIMARY KEY, "make" TEXT, "model" TEXT, "color" TEXT, "inserted_at" TEXT_DATETIME NOT NULL, "updated_at" TEXT_DATETIME NOT NULL);
INSERT INTO schema_migrations VALUES(20220726212222,'2022-07-26T21:22:29');
INSERT INTO schema_migrations VALUES(20220728104458,'2022-07-29T18:00:00');
