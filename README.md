# Predicción de Recompra (Customer Lifetime Value) con BigQuery ML

## Resumen del Proyecto
Este proyecto de Machine Learning, ejecutado enteramente en **SQL puro** mediante **Google BigQuery ML**, tiene como objetivo predecir la probabilidad de que un cliente de e-commerce vuelva a realizar una compra. 

Se utilizó el dataset público de **Olist** (e-commerce brasileño), procesando más de 100,000 registros transaccionales distribuidos en un esquema relacional complejo.

## Stack Tecnológico
* **Base de Datos y Procesamiento:** Google BigQuery (SQL)
* **Machine Learning:** BigQuery ML (Regresión Logística Binaria)
* **Visualización:** Power BI / DAX 

## Arquitectura de Datos y Feature Engineering
Para entrenar el modelo, se construyó una **Tabla Maestra** consolidando datos de las tablas `orders`, `customers` y `payments`. 
Se aplicaron reglas de negocio estrictas:
1. **Filtro de transacciones reales:** Solo se consideraron órdenes con estado `delivered` para asegurar que el ciclo de vida del cliente haya iniciado efectivamente.
2. **Limpieza de datos:** Se manejaron valores nulos (`COALESCE`) originados por desajustes relacionales y se estandarizaron los tipos de datos monetarios (`ROUND`).
3. **Modelo RFM:** Se calcularon métricas históricas por cliente: *Recencia* (días desde la última compra), *Frecuencia* (cantidad total de órdenes) y *Valor Monetario* (gasto total).

## El Modelo de Machine Learning
Se implementó un modelo de clasificación binaria (`logistic_reg`) para predecir si un cliente es un comprador único (`0`) o recurrente (`1`).

**Desafío Técnico Resuelto: Desbalance de Clases**
Al evaluar las primeras iteraciones, se detectó la "Trampa de la Exactitud" (*Accuracy Paradox*): dado que ~97% de los clientes compraron una sola vez, el modelo predecía 0 para todos. Esto se solucionó aplicando el parámetro `auto_class_weights=TRUE` nativo de BQML, forzando al algoritmo a penalizar los falsos negativos y balancear el aprendizaje.

## Hallazgos Comerciales Clave (Insights)
Al evaluar las probabilidades de predicción generadas por la IA contra la realidad histórica, se descubrió un comportamiento crítico del consumidor:
> **El sesgo de la compra excepcional:** El modelo asignó probabilidades de retención superiores al 90% a los clientes con los tickets más altos (ej. > 13,000 BRL). Sin embargo, el análisis reveló que la tasa de retorno real de estos usuarios era nula. En este e-commerce, **un ticket extremadamente alto corresponde a compras excepcionales (bienes durables), no a lealtad del cliente**. La verdadera retención se encuentra en tickets medios recurrentes.

## Estructura del Repositorio
* `/sql/01_data_preparation.sql`: Limpieza y consolidación de la tabla maestra RFM.
* `/sql/02_model_training.sql`: Entrenamiento del modelo logístico manejando el desbalance de clases.
* `/sql/03_model_prediction.sql`: Extracción de las probabilidades exactas de recompra.

<img width="1102" height="620" alt="dashboard_olist png" src="https://github.com/user-attachments/assets/ac87fe29-a440-45ab-bfb9-91f4811a8f57" />

