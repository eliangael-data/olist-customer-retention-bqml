-- =========================================================================
-- Script 02: Entrenamiento del Modelo Predictivo (BQML)
-- Descripción: Regresión logística para clasificación binaria de retención.
-- =========================================================================

CREATE OR REPLACE MODEL `clean-carrier-500004-h7.olist_ecommerce.modelo_recompra`
OPTIONS(
  model_type='logistic_reg',
  input_label_cols=['volvio_a_comprar'],
  -- Habilito el balanceo automático de clases para mitigar el 
  -- desbalance inherente (97% unificadores vs 3% recurrentes)
  auto_class_weights=TRUE 
) AS
SELECT 
  recencia_dias,
  valor_monetario,
  volvio_a_comprar
FROM `clean-carrier-500004-h7.olist_ecommerce.master_clientes`;

-- Consulta opcional para evaluar métricas de rendimiento (Precision/Recall)
-- SELECT * FROM ML.EVALUATE(MODEL `clean-carrier-500004-h7.olist_ecommerce.modelo_recompra`);
