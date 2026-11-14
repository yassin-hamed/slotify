-- CreateEnum
CREATE TYPE "Weekday" AS ENUM ('SATURDAY', 'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY');

-- CreateEnum
CREATE TYPE "AvailabilityExceptionType" AS ENUM ('CLOSED', 'CUSTOM_HOURS');

-- CreateEnum
CREATE TYPE "AvailabilityChangeMode" AS ENUM ('PLANNED', 'EMERGENCY');

-- CreateTable
CREATE TABLE "BusinessWorkingDay" (
    "id" TEXT NOT NULL,
    "weekday" "Weekday" NOT NULL,
    "businessId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BusinessWorkingDay_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BusinessWorkingPeriod" (
    "id" TEXT NOT NULL,
    "startTime" TIME(0) NOT NULL,
    "endTime" TIME(0) NOT NULL,
    "endsNextDay" BOOLEAN NOT NULL DEFAULT false,
    "workingDayId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BusinessWorkingPeriod_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BusinessAvailabilityException" (
    "id" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "type" "AvailabilityExceptionType" NOT NULL,
    "changeMode" "AvailabilityChangeMode" NOT NULL,
    "reason" TEXT,
    "businessId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BusinessAvailabilityException_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BusinessExceptionPeriod" (
    "id" TEXT NOT NULL,
    "startTime" TIME(0) NOT NULL,
    "endTime" TIME(0) NOT NULL,
    "endsNextDay" BOOLEAN NOT NULL DEFAULT false,
    "exceptionId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BusinessExceptionPeriod_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "BusinessWorkingDay_businessId_weekday_key" ON "BusinessWorkingDay"("businessId", "weekday");

-- CreateIndex
CREATE INDEX "BusinessWorkingPeriod_workingDayId_idx" ON "BusinessWorkingPeriod"("workingDayId");

-- CreateIndex
CREATE UNIQUE INDEX "BusinessAvailabilityException_businessId_date_key" ON "BusinessAvailabilityException"("businessId", "date");

-- CreateIndex
CREATE INDEX "BusinessExceptionPeriod_exceptionId_idx" ON "BusinessExceptionPeriod"("exceptionId");

-- AddForeignKey
ALTER TABLE "BusinessWorkingDay" ADD CONSTRAINT "BusinessWorkingDay_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "Business"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BusinessWorkingPeriod" ADD CONSTRAINT "BusinessWorkingPeriod_workingDayId_fkey" FOREIGN KEY ("workingDayId") REFERENCES "BusinessWorkingDay"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BusinessAvailabilityException" ADD CONSTRAINT "BusinessAvailabilityException_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "Business"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BusinessExceptionPeriod" ADD CONSTRAINT "BusinessExceptionPeriod_exceptionId_fkey" FOREIGN KEY ("exceptionId") REFERENCES "BusinessAvailabilityException"("id") ON DELETE CASCADE ON UPDATE CASCADE;
