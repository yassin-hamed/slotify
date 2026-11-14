/*
  Warnings:

  - You are about to drop the column `userId` on the `Business` table. All the data in the column will be lost.
  - Added the required column `ownerId` to the `Business` table without a default value. This is not possible if the table is not empty.
  - Made the column `timezone` on table `Business` required. This step will fail if there are existing NULL values in that column.

*/
-- DropForeignKey
ALTER TABLE "Business" DROP CONSTRAINT "Business_userId_fkey";

-- DropIndex
DROP INDEX "Business_name_slug_description_phone_email_address_idx";

-- AlterTable
ALTER TABLE "Business" DROP COLUMN "userId",
ADD COLUMN     "ownerId" TEXT NOT NULL,
ALTER COLUMN "timezone" SET NOT NULL,
ALTER COLUMN "timezone" SET DEFAULT 'Africa/Cairo';

-- CreateIndex
CREATE INDEX "Business_name_idx" ON "Business"("name");

-- CreateIndex
CREATE INDEX "Business_phone_idx" ON "Business"("phone");

-- CreateIndex
CREATE INDEX "Business_ownerId_idx" ON "Business"("ownerId");

-- AddForeignKey
ALTER TABLE "Business" ADD CONSTRAINT "Business_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
