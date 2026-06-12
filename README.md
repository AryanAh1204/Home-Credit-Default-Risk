# Home-Credit-Default-Risk
End-to-end credit risk modeling on 307K loan applications — SQL analysis, Python EDA, feature engineering, XGBoost, Tableau

## Problem Statement
Predict loan default probability for 307K applicants (8.07% default rate)
to help lenders make better credit decisions.

## Data
- Source: Kaggle — Home Credit Default Risk
- 307,511 rows, loaded into PostgreSQL via DBeaver

## Project Phases

| Phase | Status |
|---|---|
| 1. SQL Exploratory Analysis | ✅ Complete |
| 2. Python EDA | ✅ Complete |
| 3. Feature Engineering | ✅ Complete |
| 4. XGBoost Modeling | ✅ Complete |
| 5. Tableau Dashboard | ⏳ Pending |

---

## Phase 1: SQL Exploratory Analysis

### Queries Written
1. Overall default rate
2. Default rate by income type
3. Default rate by payment burden bucket (annuity/income ratio)
4. Default rate by income type × payment burden bucket
5. Working class — default rate by education level × payment burden
6. Commercial associate — default rate by education level × payment burden
7. Working class & commercial associate — income and employment comparison
8. Default rate by family member count
9. Default rate by age bucket × payment burden bucket
10. EXT_SOURCE_1, 2, 3 bucketed vs default rate

### Key Findings

**Finding 1 — Education dominates payment burden:**
Working class applicants with lower secondary education default at
17.65% even at high burden, while higher-educated applicants at
severe burden default at 6.83%. Education level is a stronger
predictor than payment burden.

**Finding 2 — Income buffers default risk more than job tenure:**
Commercial associates earn ~24% more than working class applicants
but have shorter employment histories. Yet commercial associates
with incomplete education and severe burden default at 6.35% vs
11.16% for working class — a 43% relative reduction driven by
income, not stability.

**Finding 3 — Age dominates payment burden:**
Young applicants at low burden (8.78%) carry higher default risk
than senior citizens under severe payment stress (5.99%). Default
rate decreases monotonically with age. Possible selection bias at
upper age range.

**Finding 4 — Family member count is not a strong predictor:**
No consistent relationship between family size and default rate.
Not a reliable standalone feature.

**Finding 5 — EXT_SOURCE scores are the strongest predictors:**
All three external credit scores (likely equivalent to CIBIL/FICO
scores) show monotonic decrease in default rate from Q1 to Q4 —
a 6x difference between lowest and highest quartile.

| Score | Q1 Default Rate | Q4 Default Rate | Ratio |
|-------|----------------|----------------|-------|
| EXT_SOURCE_1 | 16.04% | 2.83% | 5.7x |
| EXT_SOURCE_2 | 17.52% | 2.64% | 6.6x |
| EXT_SOURCE_3 | 19.11% | 3.23% | 5.9x |

**Overarching Pattern:**
Payment burden alone is a weak predictor. It only compounds risk
when interacted with demographic variables like education and age.
EXT_SOURCE scores dominate all other features.

---

## Phase 2: Python EDA

### Data Cleaning

| Decision | Rationale |
|---|---|
| Dropped 67 columns | Exceeded 40% null threshold → 73 columns retained |
| EXT_SOURCE_1 removed | 56% missing values — data availability issue, not signal issue |
| DAYS_EMPLOYED anomaly handled | Sentinel value 365243 replaced with NaN; flag column created |

**DAYS_EMPLOYED Anomaly:**
55,352 records contained the sentinel value 365243, identifying
pensioners and unemployed applicants. Binary flag DAYS_EMPLOYED_ANOMALY
created to preserve the signal.

| Group | Default Rate |
|---|---|
| Anomaly group (pensioners/unemployed) | 5.4% |
| Normal population | 8.66% |

### EDA Findings

**EXT_SOURCE_2 and EXT_SOURCE_3 Distributions:**
Both scores show the same directional pattern: non-defaulters cluster
at high values; defaulters spread across the low-to-mid range.
Low inter-correlation between the two — independent predictive signal.
Both retained as separate features.

**Age:**
Default rate decreases monotonically across age decades — youngest
applicants riskiest, oldest safest. Confirms SQL Finding 3 in pandas.

**Occupation Type:**
Default rate ranges from 4.8% (Accountants) to 17% (Low-skill Laborers)
— a 3.5x spread. Both groups have large sample sizes; skill level
tracks default risk closely.

**Correlation Matrix:**
TARGET shows weak linear correlation with all features — expected,
since predictive signal lives in interactions, not single-feature
linear relationships (justifies tree-based model over linear).
AMT_CREDIT and AMT_ANNUITY strongly correlated (0.77) — addressed
via the CREDIT_TERM ratio.

---

## Phase 3: Feature Engineering

| Feature | Definition | Rationale |
|---|---|---|
| EXT_SOURCE_MEAN | mean of EXT_SOURCE_2, 3 (NaN-aware) | Robust creditworthiness signal; preserved score for 61,165 rows (20% of data) that naive arithmetic would have nulled |
| CREDIT_TERM | AMT_ANNUITY / AMT_CREDIT | Repayment burden as a single ratio; resolves the 0.77 credit-annuity collinearity |
| EXT_SOURCE_MEAN × CREDIT_TERM | interaction | Strongest predictor × repayment stress |
| EXT_SOURCE_MEAN × AMT_INCOME_TOTAL | interaction | Tests whether a low score matters less for high earners (SQL Finding 2) |
| EXT_SOURCE_MEAN × AGE_YEARS | interaction | Tests score effect across age (SQL Finding 3) |

Original columns retained — pruning deferred to feature importance,
not correlation (valid for tree models).

**Note on EXT_SOURCE_MEAN:** Used `.mean(axis=1)` over naive
arithmetic to skip NaNs. Naive method → 61,395 nulls;
`.mean(axis=1)` → 230 nulls. 61,165 rows (20% of data) retained
their external-score signal — significant given EXT_SOURCE is the
strongest predictor family.

---

## Phase 4: Modeling

**Model:** XGBoost Classifier

### Setup
- Split: 80/20 train/test, stratified on TARGET (preserves 8.07% default rate)
- Categoricals: one-hot encoded with `dummy_na=True` (missingness kept as signal)
- Imbalance: `scale_pos_weight` ≈ 11.4 to counter the 92/8 class skew
- Metric: ROC-AUC (accuracy is misleading under imbalance)

### Parameters
n_estimators=200, max_depth=4, learning_rate=0.1, random_state=42
Shallow trees (depth 4) sufficient — interactions were pre-engineered,
so the model needs less depth to capture them.

### Results

| Metric | Value |
|---|---|
| Test AUC (single split) | 0.762 |
| **CV AUC (5-fold stratified)** | **0.757 ± 0.006** |

Low std (0.006) across folds confirms the score is stable, not a
favorable split. Reported number is the cross-validated 0.757.

### Top Features (by importance)

| Rank | Feature | Importance |
|---|---|---|
| 1 | EXT_SOURCE_MEAN (engineered) | 0.155 |
| 2 | NAME_EDUCATION_TYPE_Higher education | 0.038 |

The engineered EXT_SOURCE_MEAN is the single strongest predictor —
closing the loop from SQL (Finding 5) through EDA, feature
engineering, and the model. The #2 feature validates SQL Finding 1
(education). The model's top features mirror the SQL findings in order.

---

## Phase 5: Dashboard *(upcoming)*

Tableau dashboard covering:
- Default probability by applicant segment
- Feature importance visualization
- Risk band distribution

---

## Tech Stack
- SQL — PostgreSQL, DBeaver
- Python — pandas, seaborn, matplotlib, scikit-learn, XGBoost
- Visualization — Tableau
- Version control — Git / GitHub

---

## Author
Aryan Ahlawat
