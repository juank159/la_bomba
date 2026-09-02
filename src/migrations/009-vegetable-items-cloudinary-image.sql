-- Migration: Move vegetable_items photo storage to Cloudinary
-- Date: 2026-09-02
-- Description:
--   Replaces the base64-in-row "image" column with "image_url" +
--   "image_public_id": the photo now lives on Cloudinary (CDN, proper
--   image storage) and the row only keeps a reference to it. No real data
--   depended on the old column (it only ever held test rows, already
--   cleaned up), so it's dropped rather than migrated.

ALTER TABLE vegetable_items DROP COLUMN IF EXISTS image;

ALTER TABLE vegetable_items
ADD COLUMN IF NOT EXISTS image_url VARCHAR,
ADD COLUMN IF NOT EXISTS image_public_id VARCHAR;
