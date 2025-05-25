CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Erstelle die Datenbank nur, wenn sie noch nicht existiert
CREATE DATABASE product_prices_azure;
CREATE DATABASE product_prices_aws;
CREATE DATABASE product_prices_gcp;
CREATE DATABASE product_prices_hetzner;
CREATE DATABASE product_prices_alibaba_cloud;

CREATE USER api_user_product_prices WITH PASSWORD 'changeme';
-- Optional Rechte zuweisen:
GRANT ALL PRIVILEGES ON DATABASE product_prices_azure TO api_user_product_prices;
GRANT ALL PRIVILEGES ON DATABASE product_prices_aws TO api_user_product_prices;
GRANT ALL PRIVILEGES ON DATABASE product_prices_gcp TO api_user_product_prices;
GRANT ALL PRIVILEGES ON DATABASE product_prices_hetzner TO api_user_product_prices;
GRANT ALL PRIVILEGES ON DATABASE product_prices_alibaba_cloud TO api_user_product_prices;

-- Verbinde dich zur Datenbank
\connect product_prices_azure

-- Erstelle die Tabelle
CREATE TABLE IF NOT EXISTS "product_prices" (
    "uidVal" TEXT,
    "productId" TEXT,
    "productName" TEXT,
    "skuName" TEXT,
    "skuId" TEXT,
    "armSkuName" TEXT,
    "serviceName" TEXT,
    "serviceFamily" TEXT,
    "serviceId" TEXT,
    "armRegionName" TEXT,
    "location" TEXT,
    "tierMinimumUnits" DOUBLE PRECISION,
    "currencyCode" TEXT,
    "meterId" TEXT,
    "meterName" TEXT,
    "availabilityId" TEXT,
    "type" TEXT,
    "unitOfMeasure" TEXT,
    "reservationTerm" TEXT,
    "priceType" TEXT,
    "retailPrice" DOUBLE PRECISION,
    "unitPrice" DOUBLE PRECISION,
    "savingsPlan" JSONB,
    "isPrimaryMeterRegion" BOOLEAN,
    "effectiveStartDate" TEXT,
    "lastModified" TEXT,    
    "lastChanged" TIMESTAMPTZ
);

ALTER TABLE "product_prices"
ADD PRIMARY KEY ("uidVal");

-- Index auf uidVal (falls noch nicht vorhanden)
DO $$
BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM pg_indexes WHERE tablename = 'product_prices' AND indexname = 'idx_uidval'
   ) THEN
      CREATE INDEX idx_uidval ON "product_prices"("uidVal");
   END IF;
END
$$;

CREATE OR REPLACE FUNCTION set_last_changed()
RETURNS TRIGGER AS $$
BEGIN
    NEW."lastChanged" := now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM pg_trigger WHERE tgname = 'trg_set_last_changed'
   ) THEN
      CREATE TRIGGER trg_set_last_changed
      BEFORE INSERT OR UPDATE ON product_prices
      FOR EACH ROW
      EXECUTE FUNCTION set_last_changed();
   END IF;
END
$$;
