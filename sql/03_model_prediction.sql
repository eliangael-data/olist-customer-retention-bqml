-- =========================================================================
-- Script 03: Predicción e Inferencia de Probabilidades
-- Descripción: Extrae el porcentaje exacto de probabilidad para Power BI.
-- =========================================================================

SELECT 
  customer_unique_id,
  recencia_dias,
  valor_monetario,
  volvio_a_comprar AS realidad_historica,
  -- Extraigo y formateo la probabilidad matemática calculada por la IA
  ROUND((SELECT prob FROM UNNEST(predicted_volvio_a_comprar_probs) WHERE label = 1) * 100, 2) AS probabilidad_recompra_porcentaje
FROM ML.PREDICT(
  MODEL `clean-carrier-500004-h7.olist_ecommerce.modelo_recompra`,
  (SELECT * FROM `clean-carrier-500004-h7.olist_ecommerce.master_clientes`)
)
-- Ordeno para identificar los casos con mayor probabilidad predictiva
ORDER BY probabilidad_recompra_porcentaje DESC;
