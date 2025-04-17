
view: supercell_short_analysis {
  derived_table: {
    sql: with orders as (
          select distinct
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
          and to_date(purchase.order_date) >= dateadd('week', -4, date_trunc('week', current_date))
      )
      select (to_char(date_trunc('week', order_date), 'YYYY-MM-DD')) as order_week, method, card_type, country_name,
      count(distinct order_id) as all_orders, sum(has_completed_payment) as has_completed_payment, sum(payment_attempts) as payment_attempts,
      sum(payment_transaction_count) as payment_transaction_count, sum(payment_transaction_count_approved) as payment_transaction_count_approved,
      sum(payment_transaction_count_declined) as payment_transaction_count_declined, round((sum(has_completed_payment) / count(distinct order_id)) * 100, 2) as approval_rate,
      count(distinct email) as unique_emails
      from orders
      group by 1, 2, 3, 4
      order by 1 desc ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: order_week {
    type: string
    sql: ${TABLE}."ORDER_WEEK" ;;
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

  dimension: all_orders {
    type: number
    sql: ${TABLE}."ALL_ORDERS" ;;
  }

  dimension: has_completed_payment {
    type: number
    sql: ${TABLE}."HAS_COMPLETED_PAYMENT" ;;
  }

  dimension: payment_attempts {
    type: number
    sql: ${TABLE}."PAYMENT_ATTEMPTS" ;;
  }

  dimension: payment_transaction_count {
    type: number
    sql: ${TABLE}."PAYMENT_TRANSACTION_COUNT" ;;
  }

  dimension: payment_transaction_count_approved {
    type: number
    sql: ${TABLE}."PAYMENT_TRANSACTION_COUNT_APPROVED" ;;
  }

  dimension: payment_transaction_count_declined {
    type: number
    sql: ${TABLE}."PAYMENT_TRANSACTION_COUNT_DECLINED" ;;
  }

  dimension: approval_rate {
    type: number
    sql: ${TABLE}."APPROVAL_RATE" ;;
  }

  dimension: unique_emails {
    type: number
    sql: ${TABLE}."UNIQUE_EMAILS" ;;
  }

  set: detail {
    fields: [
        order_week,
	method,
	card_type,
	country_name,
	all_orders,
	has_completed_payment,
	payment_attempts,
	payment_transaction_count,
	payment_transaction_count_approved,
	payment_transaction_count_declined,
	approval_rate,
	unique_emails
    ]
  }
}
