-- Migration: Add product photo to vegetable_items
-- Date: 2026-09-02
-- Description:
--   Photo stored as base64 directly in the row (no "data:image/...;base64,"
--   prefix - the client adds that back when rendering). Render's filesystem
--   is ephemeral between deploys, so there's nowhere to persist an uploaded
--   file - storing it in Postgres is the pragmatic option without adding a
--   new storage provider. Images are resized/compressed client-side before
--   upload to keep rows small.

ALTER TABLE vegetable_items
ADD COLUMN IF NOT EXISTS image TEXT;
