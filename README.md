# Maven Fuzzy Factory – SQL Marketing & Web Analytics

This project analyzes the web traffic, conversion funnel, and marketing performance of the Maven Fuzzy Factory e-commerce website using SQL.  
The dataset includes website sessions, pageviews, and customer orders, and the goal is to answer key business questions about traffic acquisition, conversion, and ROI.

---

## 📂 Project Structure
- **SQL Queries** → All queries are stored in this repository under `queries.sql`.
- **Database** → MySQL (tested on MySQL 8.0).
- **Data** → Provided in the Maven Fuzzy Factory case study (sessions, pageviews, orders tables).
- **Tableau Dashboard** → `Ecommerce_Dashboard.png` (screenshot) and `Ecommerce_Dashboard.twbx` (interactive file).

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

## 📈 Tableau Dashboard – E-commerce Sales & Profit Analysis (2012–2015)

In addition to SQL analysis, I built a **Tableau dashboard** to visualize e-commerce performance.  

### Dashboard Features:
- **Monthly Profit Trends** → Profit fluctuations across months.  
- **Top Products by Revenue** → Identifies best-selling products.  
- **Yearly Revenue Growth (2012–2015)** → Revenue patterns over time.  
- **Orders by Number of Items** → Customer purchasing behavior.  
- **Interactive Filters** → Year and Product selection for deeper analysis.  

### Key Insights:
- Revenue peaked in **2014** before a decline in 2015.  
- **Product 1** dominates revenue contribution.  
- Most customers purchase **single-item orders**.  
- December shows peak profits (seasonality effect).  

📷 **Dashboard Preview**  
[E-commerce Dashboard.png]

---

## 🛠️ Tools Used
- **SQL (MySQL 8.0)** → Data exploration & analysis  
- **Tableau** → Interactive dashboards & visual storytelling  
- **Excel / Power BI (optional)** → Additional visualization  

---

## 🚀 Key Business Insights
- Identified **best performing traffic sources** driving conversions.  
- Found **bottlenecks in the checkout funnel** (biggest drop-offs).  
- Validated **A/B tests** showing lift in conversion from new landing pages.  
- Provided **bid optimization insights** for paid search (mobile vs desktop).  
- Revealed **seasonal and weekly traffic patterns** useful for forecasting.  

---

## 📌 How to Use
1. Clone this repository.  
2. Load the Maven Fuzzy Factory dataset into a MySQL database.  
3. Run the queries in `queries.sql` step by step.  
4. Open `Ecommerce_Dashboard.twbx` in Tableau to explore the dashboard.  
5. Use insights for building reports and presentations.  

---

## 👤 Author
- **Poornima V**  
- Aspiring Data Analyst | SQL | Tableau | Power BI | Analytics  

