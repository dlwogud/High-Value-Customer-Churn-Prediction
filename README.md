# 📊 High-Value Customer Churn Prediction (Instacart)

## 1. 📌 Project Overview

본 프로젝트는 이커머스 환경에서 **고가치 고객의 이탈(Churn)을 예측**하는 것을 목표로 한다.
특히 단순 전체 고객이 아닌, **기업 입장에서 중요한 고가치 고객군에 집중**하여 이탈을 조기에 탐지하는 것을 목적으로 한다.

---

## 2. 📂 Dataset

* Dataset: Instacart Online Grocery Basket Analysis
* Source: Kaggle
* Data Type: 주문 로그 기반 이커머스 데이터

### 🔎 데이터 선택 이유

본 데이터셋은 약 **2년치 데이터**로 구성되어 있어 기간이 짧다는 한계가 존재한다.
그러나 다음과 같은 이유로 해당 데이터를 선택하였다:

* 고객별 **연속적인 주문 이력(sequence data)** 존재
* 주문 간격(`days_since_prior_order`)을 활용한 **행동 기반 분석 가능**
* 고가치 고객의 **구매 패턴 및 재구매 주기 분석에 적합**
* 실제 이커머스 서비스와 유사한 **로그 구조 데이터**

즉, 절대적인 기간보다 **구매 밀도와 패턴 분석이 가능하다는 점**을 더 중요하게 고려하였다.

---

## 3. 🎯 Problem Definition

> "고가치 고객은 언제 이탈하는가?"

일반적인 churn 정의는 고정된 기간(예: 30일, 90일)을 기준으로 설정되는 경우가 많다.
하지만 이는 고객별 구매 패턴을 반영하지 못하는 한계가 있다.

따라서 본 프로젝트에서는
👉 **데이터 기반으로 churn 기준을 정의하는 접근 방식**을 사용하였다.

---

## 4. 👑 High-Value Customer Definition

고가치 고객은 다음과 같이 정의하였다:

* 기준: **총 주문 횟수 (total_orders)**
* 방법: 전체 고객 중 **상위 20% (80% 분위수 이상)**

```sql
APPROX_QUANTILES(total_orders, 100)[OFFSET(80)]
```

📌 이유:

* 구매 금액 정보가 없기 때문에 **행동 기반 지표(주문 횟수)** 사용
* 이커머스에서 **재구매 빈도는 고객 가치의 핵심 지표**

---

## 5. 🔍 Churn Definition (핵심)

### 📊 접근 방법

고정 기간이 아닌,
👉 **고가치 고객군의 실제 구매 간격 분포 기반으로 정의**

---

### 📈 구매 간격 분위수 분석 결과

| 분위수 | 값 (일) |
| --- | ----- |
| q80 | 10일   |
| q90 | 15일   |
| q95 | 21일   |

---

### 🎯 최종 churn 기준

👉 **15일 초과 미구매 → churn**

```sql
CASE 
  WHEN days_since_prior_order > 15 THEN 1
  ELSE 0
END
```

📌 이유:

* q80 → 너무 민감 (false positive 증가)
* q95 → 너무 느슨 (이탈 탐지 늦음)
* q90 → **가장 균형 잡힌 기준**

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

## 8. 📈 Churn Distribution

| churn  | 비율     |
| ------ | ------ |
| 0 (유지) | 81.35% |
| 1 (이탈) | 18.65% |

📌 특징:

* 클래스 불균형이 심하지 않음
* 모델 학습에 적합한 분포

---

## 9. 🧠 Key Insight

* 고가치 고객은 평균적으로 **2~3주 내 재구매**
* 일정 기간 미구매 시 **이탈 가능성 급격히 증가**
* 고정 기간 기준보다 **데이터 기반 churn 정의가 더 타당**

---

💡 Conclusion

본 프로젝트는 단순 churn 예측을 넘어서,
👉 **고객 행동 데이터 기반의 이탈 정의 방식**을 제안하였다.

특히 고가치 고객을 대상으로 한 분석을 통해
👉 실제 비즈니스 의사결정에 활용 가능한 인사이트를 도출하였다.
