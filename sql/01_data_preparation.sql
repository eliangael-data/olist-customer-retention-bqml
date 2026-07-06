-- =========================================================================
-- Script 01: Limpieza de datos y Feature Engineering (Modelo RFM)
-- Descripción: Consolida el historial transaccional en una tabla a nivel cliente.
-- =========================================================================

CREATE OR REPLACE TABLE `clean-carrier-500004-h7.olist_ecommerce.master_clientes` AS
WITH OrderData AS (
    -- Paso 1: Uno las tablas base y filtro solo transacciones concretadas
    SELECT 
        o.order_id,
        c.customer_unique_id, 
        o.order_purchase_timestamp,
        p.total_payment
    FROM `clean-carrier-500004-h7.olist_ecommerce.orders` o
    JOIN `clean-carrier-500004-h7.olist_ecommerce.customers` c 
        ON o.customer_id = c.customer_id
    LEFT JOIN (
        -- Sumarizo pagos por orden (manejo de múltiples métodos de pago)
        SELECT order_id, SUM(payment_value) as total_payment
        FROM `clean-carrier-500004-h7.olist_ecommerce.payments`
        GROUP BY order_id
    ) p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
),

CustomerMetrics AS (
    -- Paso 2: Agrupo a nivel de cliente físico para calcular métricas RFM
    SELECT 
        customer_unique_id,
        MAX(order_purchase_timestamp) AS ultima_compra,
        COUNT(DISTINCT order_id) AS cantidad_compras,
        -- Limpieza: Manejo de nulos y estandarización de decimales
        ROUND(COALESCE(SUM(total_payment), 0), 2) AS total_gastado
    FROM OrderData
    GROUP BY customer_unique_id
)

-- Paso 3: Generación del dataset final con variables predictoras y objetivo
SELECT 
    customer_unique_id,
    DATE_DIFF(DATE('2018-10-01'), DATE(ultima_compra), DAY) AS recencia_dias, 
    cantidad_compras AS frecuencia,
    total_gastado AS valor_monetario,
    -- Target del modelo: 1 si recompró, 0 si fue compra única
    IF(cantidad_compras > 1, 1, 0) AS volvio_a_comprar 
FROM CustomerMetrics
-- Descarto anomalías y clientes sin gasto registrado
WHERE total_gastado > 0;
