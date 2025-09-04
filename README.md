# Maven Fuzzy Factory – SQL Marketing & Web Analytics

This project analyzes the web traffic, conversion funnel, and marketing performance of the Maven Fuzzy Factory e-commerce website using SQL.  
The dataset includes website sessions, pageviews, and customer orders, and the goal is to answer key business questions about traffic acquisition, conversion, and ROI.

---

## 📂 Project Structure
- **SQL Queries** → All queries are stored in this repository under `queries.sql`.
- **Database** → MySQL (tested on MySQL 8.0).
- **Data** → Provided in the Maven Fuzzy Factory case study (sessions, pageviews, orders tables).

---

## 📊 Analysis Covered

### 1. Traffic & Source Analysis
- Identify top traffic sources (UTM parameters: source, campaign, content).
- Track trends for gsearch (Google Search) and bsearch (Bing Search).
- Compare paid search performance by device type (desktop vs. mobile).

### 2. Website Performance
- Find most visited and most common entry pages.
- Calculate bounce rates by landing page.
- Measure conversion rates from sessions to orders.

### 3. A/B Testing
- Landing page test: `/home` vs `/lander-1` (bounce rates & conversion).
- Funnel analysis: `/products → /cart → /shipping → /billing → /thank-you`.
- Billing page test: `/billing` vs `/billing-2` (revenue per session).

### 4. Marketing ROI
- Evaluate cost per click (CPC), revenue per session, and ROI by campaign.
- Analyze incremental revenue from new pages.
- Compare brand vs. non-brand keyword campaigns.

### 5. Seasonality & Business Patterns
- Monthly and weekly trends in sessions and orders.
- Day-of-week and hour-of-day traffic analysis.

---

## 🛠️ Tools Used
- **SQL (MySQL 8.0)** → Data exploration & analysis
- **Excel / Tableau / Power BI (optional)** → Data visualization (not required but recommended)

---

## 🚀 Key Business Insights
- Identified **best performing traffic sources** driving conversions.
- Found **bottlenecks in the checkout funnel** (biggest drop-offs).
- Validated **A/B tests** showing lift in conversion from new landing pages.
- Provided **bid optimization insights** for paid search (mobile vs desktop).
- Revealed **seasonal and weekly traffic patterns** useful for forecasting.

### 🔑 Strategic Growth Insights
- 📈 Growth in **organic traffic**, reducing reliance on paid ads.  
- 🛒 Improved **conversion rates** after product page changes.  
- 📦 Diversification of sales across multiple products, lowering risk.  
- 📆 Evidence of **seasonality**, creating opportunities for campaign planning.  

---

## 📌 How to Use
1. Clone this repository.
2. Load the Maven Fuzzy Factory dataset into a MySQL database.
3. Run the queries in `queries.sql` step by step.
4. Use the results to build dashboards or reports.

---

## 📷 Example Output (Optional)
- Funnel drop-off visualization  
- Sessions vs. Orders trend by traffic source  
- Bounce rate comparison of landing pages  

---

## 👤 Author
- **Poornima V**  
- Aspiring Data Analyst | SQL | Data Visualization | Analytics  
