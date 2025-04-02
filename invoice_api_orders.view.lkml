
view: invoice_api_orders {
  derived_table: {
    sql: SELECT ID, ORIGIN_SITE, STOREFRONT, CURRENCY, ORDER_TYPE, LIFECYCLE, SOURCE_KEY, MODE, OBJECT_NAME, INVOICES FROM ACQUISITION_TRANSACTION WHERE INVOICES LIKE CONCAT('%', ID, '%') ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: id {
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension: origin_site {
    type: string
    sql: ${TABLE}."ORIGIN_SITE" ;;
  }

  dimension: storefront {
    type: string
    sql: ${TABLE}."STOREFRONT" ;;
  }

  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
  }

  dimension: order_type {
    type: string
    sql: ${TABLE}."ORDER_TYPE" ;;
  }

  dimension: lifecycle {
    type: string
    sql: ${TABLE}."LIFECYCLE" ;;
  }

  dimension: source_key {
    type: string
    sql: ${TABLE}."SOURCE_KEY" ;;
  }

  dimension: mode {
    type: string
    sql: ${TABLE}."MODE" ;;
  }

  dimension: object_name {
    type: string
    sql: ${TABLE}."OBJECT_NAME" ;;
  }

  dimension: invoices {
    type: string
    sql: ${TABLE}."INVOICES" ;;
  }

  set: detail {
    fields: [
        id,
	origin_site,
	storefront,
	currency,
	order_type,
	lifecycle,
	source_key,
	mode,
	object_name,
	invoices
    ]
  }
}
