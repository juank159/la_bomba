-- ========================================
-- CREAR TABLAS FALTANTES EN SUPABASE
-- ========================================

-- Crear enum para temporary_products_status si no existe
DO $$ BEGIN
    CREATE TYPE temporary_products_status_enum AS ENUM (
        'pending_admin',
        'pending_supervisor',
        'completed',
        'cancelled'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Crear enum para notification_type si no existe
DO $$ BEGIN
    CREATE TYPE notification_type_enum AS ENUM (
        'product_update_pending',
        'product_update_completed',
        'temporary_product_pending_admin',
        'temporary_product_pending_supervisor',
        'temporary_product_completed',
        'temporary_product_cancelled',
        'order_created',
        'order_completed'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Tabla: temporary_products
CREATE TABLE IF NOT EXISTS temporary_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    barcode VARCHAR(255),
    "isActive" BOOLEAN DEFAULT true,
    precioa DECIMAL(10, 2),
    preciob DECIMAL(10, 2),
    precioc DECIMAL(10, 2),
    costo DECIMAL(10, 2),
    iva DECIMAL(5, 2),
    notes TEXT,
    product_id VARCHAR(255),
    status temporary_products_status_enum DEFAULT 'pending_admin',
    created_by UUID NOT NULL REFERENCES users(id),
    completed_by_admin UUID REFERENCES users(id),
    completed_by_admin_at TIMESTAMP,
    completed_by_supervisor UUID REFERENCES users(id),
    completed_by_supervisor_at TIMESTAMP,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: notifications
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type notification_type_enum NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    "isRead" BOOLEAN DEFAULT false,
    "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "productId" VARCHAR(255),
    "relatedTaskId" UUID,
    "temporaryProductId" UUID REFERENCES temporary_products(id),
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_temporary_products_status ON temporary_products(status);
CREATE INDEX IF NOT EXISTS idx_temporary_products_created_by ON temporary_products(created_by);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications("userId");
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications("isRead");
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications("createdAt");

-- Verificar que se crearon correctamente
SELECT 'temporary_products' as table_name, COUNT(*) as row_count FROM temporary_products
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications;

-- Mostrar estructura
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name IN ('temporary_products', 'notifications')
    AND table_schema = 'public'
ORDER BY table_name, ordinal_position;
