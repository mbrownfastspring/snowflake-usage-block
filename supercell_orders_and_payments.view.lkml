
view: supercell_orders_and_payments {
  derived_table: {
    sql: select distinct
              purchase.order_id,
              purchase.order_date,
              purchase_contact.email,
              payment_transaction.method,
              payment_transaction.card_type,
              purchase_address.country_name,
              case when purchase.lifecycle = 'Completed' then 1 else 0 end as has_completed_payment,
              max(payment_transaction.attempt_number) over (partition by purchase.order_id) as payment_attempts,
              count(
                  distinct case
                      when
                          (
                              (
                                  (
                                      case
                                          when payment_transaction.attempt_number = '1'
                                          then 'Initial'
                                          when payment_transaction.attempt_number = '2'
                                          then 'Retry'
                                          else 'Unknown'
                                      end
                                  )
                              )
                              = 'Initial'
                          )
                      then payment_transaction.payment_id
                      else null
                  end
              ) over (partition by purchase.order_id) as payment_transaction_count,
              case when payment_transaction.lifecycle = 'Completed' then 1 else 0 end as payment_transaction_count_approved,
              case when payment_transaction.lifecycle = 'Failed' then 1 else 0 end as payment_transaction_count_declined,
          from dbt.orders_mart as purchase
          join dbt.companies_mart as seller on purchase.owner_membership_id = seller.membership_id
          join dbt.contacts_mart as purchase_contact on purchase.receiver_contact_id = purchase_contact.contact_id
          join dbt.payments_mart as payment_transaction on purchase.order_id = payment_transaction.order_id
          join dbt.addresses_mart as purchase_address on purchase.receiver_address_id = purchase_address.address_id
          where seller.company_id = 'supercell'
          and to_date(purchase.order_date) >= dateadd('week', -4, date_trunc('week', current_date)) ;;
  }

  dimension_group: order_date {
    type: time
    timeframes: [week, month, quarter, year]
    sql: ${TABLE}."ORDER_DATE" ;;
  }

  dimension: method {
    type: string
    sql: ${TABLE}."METHOD" ;;
  }

  dimension: card_type {
    type: string
    sql: ${TABLE}."CARD_TYPE" ;;
  }

  dimension: country_name {
    type: string
    sql: ${TABLE}."COUNTRY_NAME" ;;
  }

  measure: has_completed_payment {
    type: sum
    sql: ${TABLE}."HAS_COMPLETED_PAYMENT" ;;
  }

  measure: payment_attempts {
    type: sum
    sql: ${TABLE}."PAYMENT_ATTEMPTS" ;;
  }

  measure: payment_transaction_count {
    type: sum
    sql: ${TABLE}."PAYMENT_TRANSACTION_COUNT" ;;
  }

  measure: payment_transaction_count_approved {
    type: sum
    sql: ${TABLE}."PAYMENT_TRANSACTION_COUNT_APPROVED" ;;
  }

  measure: payment_transaction_count_declined {
    type: sum
    sql: ${TABLE}."PAYMENT_TRANSACTION_COUNT_DECLINED" ;;
  }

  measure: unique_emails {
    type: count_distinct
    sql: ${TABLE}."EMAIL" ;;
  }

  set: detail {
    fields: [
  method,
  card_type,
  country_name,
  has_completed_payment,
  payment_attempts,
  payment_transaction_count,
  payment_transaction_count_approved,
  payment_transaction_count_declined,
  unique_emails
    ]
  }
}
