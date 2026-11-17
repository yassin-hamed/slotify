/*
  Warnings:

  - A unique constraint covering the columns `[id,businessId]` on the table `Service` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW');

-- CreateEnum
CREATE TYPE "BookingSource" AS ENUM ('CUSTOMER', 'BUSINESS_OWNER');

-- CreateEnum
CREATE TYPE "BookingHistoryActorType" AS ENUM ('CUSTOMER', 'BUSINESS_OWNER', 'SYSTEM');

-- CreateEnum
CREATE TYPE "BookingHistoryAction" AS ENUM ('CREATED', 'RESCHEDULED', 'CANCELLED', 'COMPLETED', 'NO_SHOW');

-- DropIndex
DROP INDEX "Service_businessId_name_idx";

-- CreateTable
CREATE TABLE "Booking" (
    "id" TEXT NOT NULL,
    "bookingNumber" TEXT NOT NULL,
    "customerName" TEXT NOT NULL,
    "customerEmail" TEXT NOT NULL,
    "customerPhone" TEXT NOT NULL,
    "businessId" TEXT NOT NULL,
    "serviceId" TEXT NOT NULL,
    "serviceNameSnapshot" TEXT NOT NULL,
    "servicePriceSnapshot" DECIMAL(10,2) NOT NULL,
    "serviceDurationSnapshot" INTEGER NOT NULL,
    "currencySnapshot" TEXT NOT NULL,
    "startAt" TIMESTAMPTZ(3) NOT NULL,
    "endAt" TIMESTAMPTZ(3) NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'CONFIRMED',
    "cancellationReason" TEXT,
    "cancelledAt" TIMESTAMPTZ(3),
    "source" "BookingSource" NOT NULL DEFAULT 'CUSTOMER',
    "createdByUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Booking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingHistory" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "action" "BookingHistoryAction" NOT NULL,
    "actorType" "BookingHistoryActorType" NOT NULL,
    "actorUserId" TEXT,
    "previousStartAt" TIMESTAMPTZ(3),
    "previousEndAt" TIMESTAMPTZ(3),
    "newStartAt" TIMESTAMPTZ(3),
    "newEndAt" TIMESTAMPTZ(3),
    "previousStatus" "BookingStatus",
    "newStatus" "BookingStatus",
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BookingHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingAccessOtp" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "codeHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMPTZ(3) NOT NULL,
    "consumedAt" TIMESTAMPTZ(3),
    "invalidatedAt" TIMESTAMPTZ(3),
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BookingAccessOtp_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Booking_bookingNumber_key" ON "Booking"("bookingNumber");

-- CreateIndex
CREATE INDEX "Booking_businessId_startAt_idx" ON "Booking"("businessId", "startAt");

-- CreateIndex
CREATE INDEX "Booking_serviceId_startAt_idx" ON "Booking"("serviceId", "startAt");

-- CreateIndex
CREATE INDEX "Booking_customerEmail_idx" ON "Booking"("customerEmail");

-- CreateIndex
CREATE INDEX "Booking_status_startAt_idx" ON "Booking"("status", "startAt");

-- CreateIndex
CREATE INDEX "BookingHistory_bookingId_createdAt_idx" ON "BookingHistory"("bookingId", "createdAt");

-- CreateIndex
CREATE INDEX "BookingHistory_actorUserId_idx" ON "BookingHistory"("actorUserId");

-- CreateIndex
CREATE INDEX "BookingAccessOtp_bookingId_createdAt_idx" ON "BookingAccessOtp"("bookingId", "createdAt");

-- CreateIndex
CREATE INDEX "BookingAccessOtp_expiresAt_idx" ON "BookingAccessOtp"("expiresAt");

-- CreateIndex
CREATE INDEX "Service_businessId_name_idx" ON "Service"("businessId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "Service_id_businessId_key" ON "Service"("id", "businessId");

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "Business"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_serviceId_businessId_fkey" FOREIGN KEY ("serviceId", "businessId") REFERENCES "Service"("id", "businessId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingHistory" ADD CONSTRAINT "BookingHistory_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingHistory" ADD CONSTRAINT "BookingHistory_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingAccessOtp" ADD CONSTRAINT "BookingAccessOtp_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Booking constraints

ALTER TABLE "Booking"
ADD CONSTRAINT "Booking_valid_time_range"
CHECK ("endAt" > "startAt");

ALTER TABLE "Booking"
ADD CONSTRAINT "Booking_non_negative_price"
CHECK ("servicePriceSnapshot" >= 0);

ALTER TABLE "Booking"
ADD CONSTRAINT "Booking_positive_duration"
CHECK ("serviceDurationSnapshot" > 0);

ALTER TABLE "Booking"
ADD CONSTRAINT "Booking_cancellation_consistency"
CHECK (
    (
        "status" = 'CANCELLED'
        AND "cancelledAt" IS NOT NULL
    )
    OR
    (
        "status" <> 'CANCELLED'
        AND "cancelledAt" IS NULL
    )
);

ALTER TABLE "Booking"
ADD CONSTRAINT "Booking_source_creator_consistency"
CHECK (
    (
        "source" = 'CUSTOMER'
        AND "createdByUserId" IS NULL
    )
    OR
    (
        "source" = 'BUSINESS_OWNER'
        AND "createdByUserId" IS NOT NULL
    )
);

-- Booking history constraints

ALTER TABLE "BookingHistory"
ADD CONSTRAINT "BookingHistory_actor_consistency"
CHECK (
    (
        "actorType" = 'BUSINESS_OWNER'
        AND "actorUserId" IS NOT NULL
    )
    OR
    (
        "actorType" IN ('CUSTOMER', 'SYSTEM')
        AND "actorUserId" IS NULL
    )
);

ALTER TABLE "BookingHistory"
ADD CONSTRAINT "BookingHistory_previous_time_range"
CHECK (
    (
        "previousStartAt" IS NULL
        AND "previousEndAt" IS NULL
    )
    OR
    (
        "previousStartAt" IS NOT NULL
        AND "previousEndAt" IS NOT NULL
        AND "previousEndAt" > "previousStartAt"
    )
);

ALTER TABLE "BookingHistory"
ADD CONSTRAINT "BookingHistory_new_time_range"
CHECK (
    (
        "newStartAt" IS NULL
        AND "newEndAt" IS NULL
    )
    OR
    (
        "newStartAt" IS NOT NULL
        AND "newEndAt" IS NOT NULL
        AND "newEndAt" > "newStartAt"
    )
);

-- OTP constraints

ALTER TABLE "BookingAccessOtp"
ADD CONSTRAINT "BookingAccessOtp_non_negative_attempts"
CHECK ("attempts" >= 0);

ALTER TABLE "BookingAccessOtp"
ADD CONSTRAINT "BookingAccessOtp_valid_expiry"
CHECK ("expiresAt" > "createdAt");

ALTER TABLE "BookingAccessOtp"
ADD CONSTRAINT "BookingAccessOtp_single_terminal_state"
CHECK (
    NOT (
        "consumedAt" IS NOT NULL
        AND "invalidatedAt" IS NOT NULL
    )
);