-- This is an empty migration.
-- Service constraints

ALTER TABLE "Service"
ADD CONSTRAINT "Service_price_non_negative"
CHECK ("price" >= 0);

ALTER TABLE "Service"
ADD CONSTRAINT "Service_duration_positive"
CHECK ("durationMinutes" IS NULL OR "durationMinutes" > 0);

ALTER TABLE "Service"
ADD CONSTRAINT "Service_slot_interval_positive"
CHECK ("slotIntervalMinutes" IS NULL OR "slotIntervalMinutes" > 0);

ALTER TABLE "Service"
ADD CONSTRAINT "Service_capacity_positive"
CHECK ("capacity" IS NULL OR "capacity" > 0);


-- Business default constraints

ALTER TABLE "Business"
ADD CONSTRAINT "Business_default_duration_positive"
CHECK ("defaultDurationMinutes" > 0);

ALTER TABLE "Business"
ADD CONSTRAINT "Business_default_slot_interval_positive"
CHECK ("defaultSlotIntervalMinutes" > 0);

ALTER TABLE "Business"
ADD CONSTRAINT "Business_default_capacity_positive"
CHECK ("defaultCapacity" > 0);