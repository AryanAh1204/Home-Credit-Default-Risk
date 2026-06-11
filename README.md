# Home-Credit-Default-Risk
End-to-end credit risk modeling on 307K loan applications — SQL analysis, Python EDA, XGBoost, Tableau

## Problem Statement
Predict loan default probability for 307K applicants (8.07% default rate)
to help lenders make better credit decisions.

## Data
- Source: Kaggle — Home Credit Default Risk
- 307,511 rows, loaded into PostgreSQL via DBeaver

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

**Overarching Pattern:**
Payment burden alone is a weak predictor. It only compounds risk
when interacted with demographic variables like education and age.
Feature engineering should prioritize interaction terms over
standalone burden.
