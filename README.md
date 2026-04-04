# 📊 High-Frequency Customer Repurchase Delay Prediction

## 1. 📌 Project Overview

본 프로젝트는 이커머스 환경에서 **고빈도 고객의 재구매 지연 위험(Repurchase Delay Risk)**을 예측하는 것을 목표로 한다.

특히 단순 전체 고객이 아닌, **기업 입장에서 중요한 핵심 재구매 고객군**을 대상으로,
재구매가 지연되는 시점을 조기에 탐지하는 데 초점을 맞추었다.

---

## 2. 📂 Dataset

* Dataset: Instacart Online Grocery Basket Analysis
* Source: Kaggle
* Data Type: 주문 로그 기반 이커머스 데이터

### 🔎 데이터 선택 이유

본 데이터셋은 약 **2년치 데이터**로 구성되어 있어 기간이 제한적이라는 한계가 존재한다.
그러나 다음과 같은 이유로 해당 데이터를 선택하였다:

* 고객별 **연속적인 주문 이력(sequence data)** 존재
* 주문 간격(`days_since_prior_order`)을 활용한 **행동 기반 분석 가능**
* 실제 이커머스 서비스와 유사한 **로그 구조 데이터**

따라서 본 프로젝트에서는 절대적인 기간보다
👉 **구매 패턴과 재구매 행동을 분석할 수 있다는 점**을 더 중요하게 고려하였다.

---

## 3. 🎯 Problem Definition

> **고빈도 고객은 언제 재구매 지연 위험 상태에 진입하는가?**

기존의 churn 정의는 일정 기간(예: 30일, 90일)을 기준으로 설정되는 경우가 많다.
그러나 이러한 방식은 고객별 구매 패턴을 충분히 반영하지 못하는 한계가 있다.

이에 본 프로젝트에서는
👉 **데이터 기반으로 재구매 지연 위험을 정의하는 접근 방식**을 사용하였다.

---

## 4. 👥 High-Frequency Customer Definition

Instacart 데이터셋에는 구매 금액 정보가 포함되어 있지 않기 때문에,
고객 가치를 직접적으로 정의하는 데 한계가 존재한다.

따라서 본 연구에서는 고객의 **구매 활동성(Activity Level)**을 기반으로
다음과 같이 고빈도 고객을 정의하였다:

* 기준: **총 주문 횟수 (total_orders)**
* 방법: 전체 고객 중 **상위 20% (80% 분위수 이상)**

```sql
APPROX_QUANTILES(total_orders, 100)[OFFSET(80)]
```

📌 해석:
고빈도 고객은 단기간에 많은 주문을 수행하는 고객으로,
👉 **높은 재구매 가능성과 유지 가치가 기대되는 핵심 고객군**으로 볼 수 있다.

---

## 5. 🔍 Repurchase Delay Risk Definition (핵심)

### 📊 접근 방식

고정된 기간을 일괄적으로 적용하는 대신,
👉 **고빈도 고객군의 실제 구매 간격 분포를 기반으로 기준 설정**

---

### 📈 구매 간격 분위수 분석 결과

| 분위수 | 값 (일) |
| --- | ----- |
| q80 | 10일   |
| q90 | 15일   |
| q95 | 21일   |

---

### 🎯 최종 기준 정의

👉 **15일 초과 미구매 → 재구매 지연 위험 상태**

```sql
CASE 
  WHEN days_since_prior_order > 15 THEN 1
  ELSE 0
END
```

📌 해석:

* 대부분의 고빈도 고객은 **15일 이내 재구매**
* 이를 초과하는 경우
  👉 **일반적인 행동 패턴에서 벗어난 상태 (Risk 상태)**

---

## 6. ⚙️ Feature Engineering

고객 행동 기반 Feature를 생성하였다:

* `total_orders`: 총 주문 횟수
* `avg_days_between_orders`: 평균 구매 간격
* `max_order_number`: 마지막 주문 순서

📌 주의:

* 동일 날짜 주문으로 인해 평균 간격이 왜곡될 수 있어
  **NULL 및 0 값 처리 후 계산**

---

## 7. 📊 Data Pipeline (SQL 기반)

```text
orders
   ↓
user_order_features
   ↓
high_value_customers
   ↓
high_value_orders
   ↓
churn_labels_hv
   ↓
model_base_hv
```

👉 모든 전처리는 **BigQuery(SQL)** 기반으로 수행

---

## 8. 📈 Risk Distribution

| 상태     | 비율     |
| ------ | ------ |
| 정상 (0) | 81.35% |
| 위험 (1) | 18.65% |

📌 특징:

* 클래스 불균형이 심하지 않음
* 모델 학습에 적합한 분포

---

## 9. 🧠 Key Insight

* 고빈도 고객은 평균적으로 **2~3주 이내 재구매**
* 일정 기간 미구매 시
  👉 **재구매 지연 위험 급격히 증가**
* 고정 기간보다
  👉 **데이터 기반 기준이 더 현실적**

---


## 10. 💡 Conclusion

본 프로젝트는 단순 churn 예측을 넘어서,
👉 **고객 행동 데이터를 기반으로 재구매 지연 위험을 정의하는 방법**을 제안하였다.

특히 고빈도 고객을 중심으로 분석함으로써,
👉 실제 비즈니스 환경에서 활용 가능한 인사이트를 도출하였다.
