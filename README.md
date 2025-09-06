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
![E-commerce Dashboard](https://raw.githubusercontent.com/Poornima044/Website-Traffic-and-Orders-sql/main/E-commerce%20Dashboard.png)


---

## 🛠️ Tools Used
- **SQL (MySQL 8.0)** → Data exploration & analysis  
- **Tableau** → Interactive dashboards & visual storytelling  
- **Excel / Power BI (optional)** → Additional visualization  

---

## 🧩 Example SQL Query
- Top traffic sources (sessions → orders conversion):
SELECT 
  ws.utm_source,
  ws.utm_campaign,
  COUNT(DISTINCT ws.website_session_id) AS sessions,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(1.0 * COUNT(DISTINCT o.order_id) / NULLIF(COUNT(DISTINCT ws.website_session_id),0), 4) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY ws.utm_source, ws.utm_campaign
ORDER BY sessions DESC
LIMIT 50;

- Bounce rate for landing page /home (sessions with only 1 pageview):
CREATE TEMPORARY TABLE first_pv AS
SELECT website_session_id, MIN(website_pageview_id) AS first_pv
FROM website_pageviews
GROUP BY website_session_id;

SELECT
  COUNT(DISTINCT CASE WHEN wp.pageview_url = '/home' THEN f.website_session_id END) AS total_home_sessions,
  COUNT(DISTINCT CASE WHEN wp.pageview_url = '/home' AND pv_counts.pageviews = 1 THEN f.website_session_id END) AS bounced_home_sessions,
  ROUND(1.0 * COUNT(DISTINCT CASE WHEN wp.pageview_url = '/home' AND pv_counts.pageviews = 1 THEN f.website_session_id END) / NULLIF(COUNT(DISTINCT CASE WHEN wp.pageview_url = '/home' THEN f.website_session_id END),0), 4) AS bounce_rate
FROM first_pv f
JOIN website_pageviews wp ON f.first_pv = wp.website_pageview_id
JOIN (
  SELECT website_session_id, COUNT(*) as pageviews
  FROM website_pageviews GROUP BY website_session_id
) pv_counts ON pv_counts.website_session_id = f.website_session_id;

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

