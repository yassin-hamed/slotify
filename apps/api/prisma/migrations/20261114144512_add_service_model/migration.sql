/*
  Warnings:

  - You are about to drop the column `deleted` on the `User` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Business" ADD COLUMN     "currency" TEXT NOT NULL DEFAULT 'EGP',
ADD COLUMN     "defaultCapacity" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "defaultDurationMinutes" INTEGER NOT NULL DEFAULT 30,
ADD COLUMN     "defaultSlotIntervalMinutes" INTEGER NOT NULL DEFAULT 30,
ADD COLUMN     "deletedAt" TIMESTAMP(3),
ADD COLUMN     "disabled" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "tagline" TEXT;

-- AlterTable
ALTER TABLE "User" DROP COLUMN "deleted";

-- CreateTable
CREATE TABLE "Service" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "imageUrl" TEXT,
    "price" DECIMAL(10,2) NOT NULL,
    "durationMinutes" INTEGER,
    "slotIntervalMinutes" INTEGER,
    "capacity" INTEGER,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "businessId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Service_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Service_businessId_name_idx" ON "Service"("businessId", "name");

-- AddForeignKey
ALTER TABLE "Service" ADD CONSTRAINT "Service_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "Business"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
