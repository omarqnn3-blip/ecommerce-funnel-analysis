# E-commerce Funnel & Conversion Analysis

Event-level analysis of an online store's purchase funnel in **BigQuery**: built to find where shoppers drop off, which traffic sources bring real buyers, and where the business should spend next.

**Author:** Omar Quinn, Data & BI Analyst
**Tools:** BigQuery · SQL
**Window:** trailing 30 days · 4,291 visitors

---

## The business problem

The store had rich event data, page views, add-to-cart, checkout, payment, and purchase, but no clear answer to four questions:

1. Where are users dropping off in the funnel?
2. Is the checkout / payment flow the bottleneck?
3. Which marketing channels drive high-converting traffic?
4. How should marketing and UX priorities change based on the data?

## Methodology

Five SQL modules (`sql/funnel_analysis.sql`):

1. **Funnel stages**: distinct users at each stage.
2. **Conversion rates**: step-by-step and overall view-to-purchase.
3. **Funnel by traffic source**: views, carts, purchases, and conversion by channel.
4. **Time in funnel**: average minutes from first view to cart and to purchase.
5. **Revenue funnel**: total revenue, AOV, revenue per buyer, revenue per visitor.

## Key findings

| Metric | Value |
| --- | --- |
| Overall conversion (view → purchase) | **16.52%** |
| View → cart | 31.18% |
| Cart → checkout | 71.30% |
| Checkout → payment | 80.71% |
| Payment → purchase | **92.08%** |
| Average order value | **$107.46** |
| Revenue per visitor | $17.76 |
| Avg. total journey time | 24.56 min |

**Channel quality (purchase conversion):** Email **33.85%** · Paid ads 21.00% · Organic 17.07% · Social **6.66%**.

## Core insight

**The checkout flow is not the problem.** Late-stage conversion is strong, 80.7% checkout-to-payment and 92.1% payment-to-purchase. The real opportunity is **traffic quality**: social drives ~29% of traffic but the lowest conversion, while email is the highest-converting channel by far.

## Recommendations

1. **Protect the checkout flow**: it already performs; limit changes to small A/B tests.
2. **Reduce social over-investment** as a direct-sales channel; shift toward retargeting and email capture.
3. **Double down on email**: highest-converting channel, with popups, abandoned-cart, and lifecycle flows.
4. **Set CAC limits** against the $107.46 AOV and $17.76 revenue per visitor.
5. **Optimize before checkout**: the biggest gains are getting qualified users from view → cart, not rebuilding payment.

## Repo structure

```
ecommerce-funnel-analysis/
├── sql/     funnel_analysis.sql        # 5 BigQuery modules
├── data/    *.csv                      # query outputs + raw user_events
└── charts/  01–03 .png                 # funnel, channel conversion, volume vs quality
```

---

*Part of my analytics portfolio. See the full case study on my portfolio site.*
