-- =========================================
-- Website-Traffic-and-Orders-sql
-- =========================================

-- Analyzing top traffic sources

use mavenfuzzyfactory;
select 
  website_sessions.utm_content,
  count(distinct website_sessions.website_session_id) as sessions,
  count(distinct orders.order_id) as orders,
  count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as sessions_to_order
from website_sessions
  left join orders
    on orders.website_session_id = website_sessions.website_session_id
where website_sessions.website_session_id between 1000 and 2000
group by 1
order by 2 desc;

-- Finding top traffic sources
select
  utm_source,
  utm_campaign,
  http_referer,
  count(distinct website_session_id) as sessions
from website_sessions
where created_at < '2012-04-12'
group by 
  utm_source,
  utm_campaign,
  http_referer
order by sessions desc;

-- Traffic source conversion rates
select 
  count(distinct w.website_session_id) as sessions,
  count(distinct o.order_id) as orders,
  count(distinct o.order_id)/count(distinct w.website_session_id) as sessions_to_order_conversion
from website_sessions w
left join orders o
  on o.website_session_id = w.website_session_id
where w.created_at < '2012-04-14'
    and w.utm_source = 'gsearch'
    and w.utm_campaign = 'nonbrand';

-- Traffic source trending    
select 
   min(date(created_at)) as week_start_date,
   count(distinct website_session_id) as sessions
from website_sessions
where created_at < '2012-05-12'
  and utm_source = 'gsearch'
  and utm_campaign = 'nonbrand'
group by 
  year(created_at),
  week(created_at);
 
-- Bid optimization for paid traffic 
select 
  w.device_type as device_type,
  count(distinct w.website_session_id) as sessions,
  count(distinct o.order_id) as order_id,
  count(distinct o.order_id)/count(distinct w.website_session_id) as sessions_to_order_convert_rate
from website_sessions w
left join orders o 
  on o.website_session_id = w.website_session_id
where w.created_at < '2012-05-11'
  and utm_source = 'gsearch'
  and utm_campaign = 'nonbrand'
group by w.device_type;

-- Trending with granular segments
select 
  min(date(w.created_at)) as week_start_date,
  count(distinct case when device_type = 'desktop' then w.website_session_id else null end) as dtop_sessions,
  count(distinct case when device_type = 'mobile' then w.website_session_id else null end) as sessions
from website_sessions w
where w.created_at < '2012-06-09' 
  and w.created_at > '2012-04-15'
  and w.utm_source = 'gsearch'
  and w.utm_campaign = 'nonbrand'
group by year(w.created_at),
		week(w.created_at);

-- Finding top website pages
select 
  pageview_url,
  count(distinct website_session_id) as sessions
from website_pageviews
where created_at < '2012-06-09'
group by pageview_url
order by sessions desc;

-- Finding top entry pages
-- step 1 : find the first pageview for each session
-- step 2 : find the url that customer saw on that first pageview
use mavenfuzzyfactory;
create temporary table first_pv_per_session
select 
  website_session_id,
  min(website_pageview_id) as first_pv
from website_pageviews
where created_at < '2012-06-12'
group by 1
;
select 
  w.pageview_url as landing_page_url,
  count(distinct f.website_session_id) as sessions_hitting_this_page
from first_pv_per_session f
  left join website_pageviews w
    on w.website_session_id = f.website_session_id
group by 1
order by 2 desc
limit 1;

-- Calculating bounce rates
-- step 1: finding the first website_pageview_id for relevant sessions 
-- step 2: identifying the landing page of each session
-- step 3: counting pageviews for each sessions, to identify bounces 
-- step 4: summarizing by counting total sessions and bounced sessions 
 
create temporary table first_pageviews
select 
  website_session_id,
  min(website_pageview_id) as min_pageview_id
from website_pageviews
where created_at < '2012-06-14'
group by website_session_id;

create temporary table sessions_w_home_landing_page
select 
  f.website_session_id,
  w.pageview_url as landing_page
from first_pageviews f 
  left join website_pageviews w
    on w.website_pageview_id = f.min_pageview_id
where w.pageview_url = '/home';

create temporary table bounced_sessions
select 
  sessions_w_home_landing_page.website_session_id,
  sessions_w_home_landing_page.landing_page,
  count(website_pageviews.website_pageview_id) as count_of_page_viewed
from sessions_w_home_landing_page
left join website_pageviews
  on website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id
group by 
  sessions_w_home_landing_page.website_session_id,
  sessions_w_home_landing_page.landing_page
having count(website_pageviews.website_pageview_id) = 1;

SELECT 
    count(distinct sessions_w_home_landing_page.website_session_id) as sessions,
    count(distinct bounced_sessions.website_session_id) as bounced_session,
    COUNT(DISTINCT bounced_sessions.website_session_id) / COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS bounce_rate
FROM sessions_w_home_landing_page
LEFT JOIN bounced_sessions
    ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id;
    
-- Analyzing landing page tests
-- step 1 : find out when the new page /lander launched 
-- step 2 : finding the first website_pageview_id for relevant sessions
-- step 3 : identifying the landing page for each session
-- step 4 : counting pageviews for each session, to identify "bounces"
-- step 5 :  summarizing total sessions and bounced sessions, by landing page

select 
  min(created_at) as first_created_at,
  min(website_pageview_id) as first_pageview_id
from website_pageviews
where pageview_url = '/lander-1'
  and created_at is not null;

-- first_created_at = 2012-06-19 00:35:54
-- first_pageview_id = 23504

CREATE TEMPORARY TABLE first_test_pageviews AS
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at < '2012-07-28'      -- prescribed by the assignment
    AND website_pageviews.website_pageview_id > 23504   -- the min_pageview_id we found for the test
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
    website_pageviews.website_session_id;

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page AS
SELECT 
    first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
LEFT JOIN website_pageviews
    ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions AS
SELECT
    s.website_session_id,
    s.landing_page,
    COUNT(wp.website_pageview_id) AS pageviews_count
FROM nonbrand_test_sessions_w_landing_page s
LEFT JOIN website_pageviews wp
    ON wp.website_session_id = s.website_session_id
GROUP BY s.website_session_id, s.landing_page
HAVING COUNT(wp.website_pageview_id) = 1;

SELECT 
    s.landing_page,
    COUNT(DISTINCT s.website_session_id) AS total_sessions,
    COUNT(DISTINCT b.website_session_id) AS bounced_sessions,
    ROUND(
        100.0 * COUNT(DISTINCT b.website_session_id) 
        / COUNT(DISTINCT s.website_session_id), 2
    ) AS bounce_rate_percent
FROM nonbrand_test_sessions_w_landing_page s
LEFT JOIN nonbrand_test_bounced_sessions b
    ON s.website_session_id = b.website_session_id
GROUP BY s.landing_page;

-- Landing page trend analysis
-- Step 1: Identify first pageview of each session (only paid search nonbrand)
-- Step 2: Attach landing page URL for those first pageviews
-- Step 3: Count pageviews per session (to detect bounces)
-- Step 4: Summarize weekly sessions & bounce rate

CREATE TEMPORARY TABLE first_pageview AS
SELECT
    ws.website_session_id,
    MIN(wp.website_pageview_id) AS first_pageview_id,
    ws.created_at
FROM website_sessions ws
JOIN website_pageviews wp
    ON ws.website_session_id = wp.website_session_id
WHERE ws.utm_source = 'gsearch'
  AND ws.utm_campaign = 'nonbrand'
  AND ws.created_at >= '2012-06-01'
GROUP BY ws.website_session_id, ws.created_at;

CREATE TEMPORARY TABLE sessions_with_landing_page AS
SELECT
    f.website_session_id,
    f.created_at,
    wp.pageview_url AS landing_page
FROM first_pageview f
JOIN website_pageviews wp
    ON f.first_pageview_id = wp.website_pageview_id
WHERE wp.pageview_url IN ('/home', '/lander-1');

CREATE TEMPORARY TABLE sessions_with_counts AS
SELECT
    s.website_session_id,
    s.landing_page,
    s.created_at,
    COUNT(wp.website_pageview_id) AS pageviews_count
FROM sessions_with_landing_page s
JOIN website_pageviews wp
    ON s.website_session_id = wp.website_session_id
GROUP BY s.website_session_id, s.landing_page, s.created_at;

SELECT
    -- Use MIN(created_at) for each week to get the actual Monday as week_start_date
    STR_TO_DATE(CONCAT(YEARWEEK(MIN(s.created_at), 3), ' Monday'), '%X%V %W') AS week_start_date,
    COUNT(DISTINCT s.website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN sc.pageviews_count = 1 THEN sc.website_session_id END) AS bounced_sessions,
    ROUND(
        COUNT(DISTINCT CASE WHEN sc.pageviews_count = 1 THEN sc.website_session_id END) 
        / COUNT(DISTINCT s.website_session_id), 4
    ) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN s.landing_page = '/home' THEN s.website_session_id END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN s.landing_page = '/lander-1' THEN s.website_session_id END) AS lander_sessions
FROM sessions_with_landing_page s
JOIN sessions_with_counts sc
    ON s.website_session_id = sc.website_session_id
GROUP BY YEARWEEK(s.created_at, 3)
ORDER BY week_start_date
LIMIT 0, 1000;

-- Building conversion funnels
-- Step 1: Select all pageviews for relevant sessions
SELECT
    s.website_session_id,
    wp.pageview_url,
    wp.created_at
FROM website_sessions s
JOIN website_pageviews wp
    ON s.website_session_id = wp.website_session_id
WHERE s.created_at >= '2012-08-05'
  AND s.utm_source = 'gsearch'
  AND s.utm_campaign = 'nonbrand';
  
  -- Step 2: Identify each pageview as a funnel step
  SELECT
    website_session_id,
    MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS product_made_it,
    MAX(CASE WHEN pageview_url = '/the-mrfuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_made_it,
    MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_made_it,
    MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_made_it,
    MAX(CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_made_it,
    MAX(CASE WHEN pageview_url = '/thank-you' THEN 1 ELSE 0 END) AS thankyou_made_it
FROM website_pageviews
GROUP BY website_session_id;

-- 	Step 3: Create a session-level conversion funnel view
-- Step 1: Create temporary table with session-level funnel flags
CREATE TEMPORARY TABLE session_level_made_it_flags AS
SELECT
    website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM (
    -- Step 2: Flag each pageview within session
    SELECT
        ws.website_session_id,
        CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
        CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
        CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
        CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
        CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
        CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
    FROM website_sessions ws
    LEFT JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    WHERE ws.utm_source = 'gsearch'
      AND ws.utm_campaign = 'nonbrand'
      AND ws.created_at > '2012-08-05'
      AND ws.created_at < '2012-09-05'
) page_flags
GROUP BY website_session_id;

-- Step 4: Aggregate the conversion rates
SELECT
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id END) / COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id END) / COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id END) / COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id END) / COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id END) / COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id END) / COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id END) AS billing_click_rt
FROM session_level_made_it_flags;

-- Analyzing conversion funnel tests
-- Step 1: Find the first date /billing-2 appeared
SELECT
    MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2';

-- Step 2: Capture sessions that saw either /billing or /billing-2 after that date
CREATE TEMPORARY TABLE billing_sessions AS
SELECT
    wp.website_session_id,
    wp.pageview_url AS billing_version_seen
FROM website_pageviews wp
JOIN website_sessions ws
    ON wp.website_session_id = ws.website_session_id
WHERE wp.pageview_url IN ('/billing', '/billing-2')
  AND wp.created_at > (
        SELECT MIN(created_at)
        FROM website_pageviews
        WHERE pageview_url = '/billing-2'
  );

-- Step 3: Check if those sessions ended up on the order thank-you page
CREATE TEMPORARY TABLE billing_orders AS
SELECT
    bs.billing_version_seen,
    bs.website_session_id,
    MAX(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS order_made
FROM billing_sessions bs
LEFT JOIN website_pageviews wp
    ON bs.website_session_id = wp.website_session_id
GROUP BY bs.billing_version_seen, bs.website_session_id;

-- Step 4: Aggregate to compare conversion rates
SELECT
    billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(order_made) AS orders,
    ROUND(SUM(order_made) * 1.0 / COUNT(DISTINCT website_session_id), 4) AS billing_to_order_rt
FROM billing_orders
GROUP BY billing_version_seen;

-- Trended performance data
-- Gsearch monthly sessions & orders
SELECT 
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY yr, mo;

-- Split Gsearch by brand vs nonbrand
SELECT 
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    ws.utm_campaign,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at), ws.utm_campaign
ORDER BY yr, mo, ws.utm_campaign;

-- Gsearch nonbrand split by device type
SELECT 
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch'
  AND ws.utm_campaign = 'nonbrand'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at), ws.device_type
ORDER BY yr, mo, ws.device_type;

-- Compare Gsearch vs other channels
SELECT 
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at), ws.utm_source
ORDER BY yr, mo, ws.utm_source;

-- Session → order conversion rate, by month
SELECT 
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY yr, mo;

-- Estimate revenue lift from Gsearch lander test (Jun 19 – Jul 28)
-- Step 1: calculate conversion rates pre/post lander test
SELECT
    ws.landing_page,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch'
  AND ws.utm_campaign = 'nonbrand'
  AND ws.created_at BETWEEN '2012-06-19' AND '2012-07-28'
GROUP BY ws.landing_page;

-- Step 2: Get sessions after Jul 28 (the “post-test” period)
SELECT 
    COUNT(DISTINCT website_session_id) AS sessions_posttest
FROM website_sessions
WHERE utm_source = 'gsearch'
  AND utm_campaign = 'nonbrand'
  AND created_at > '2012-07-28';

-- Step 3: Calculate incremental orders
WITH landing_pages AS (
    SELECT
        ws.website_session_id,
        MIN(wp.pageview_url) AS landing_page
    FROM website_sessions ws
    JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    WHERE ws.utm_source = 'gsearch'
      AND ws.utm_campaign = 'nonbrand'
      AND ws.created_at BETWEEN '2012-06-19' AND '2012-07-28'
    GROUP BY ws.website_session_id
),
cvr AS (
    SELECT
        lp.landing_page,
        COUNT(DISTINCT lp.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders,
        1.0 * COUNT(DISTINCT o.order_id) / COUNT(DISTINCT lp.website_session_id) AS conversion_rate
    FROM landing_pages lp
    LEFT JOIN orders o
        ON lp.website_session_id = o.website_session_id
    GROUP BY lp.landing_page
),
posttest_sessions AS (
    SELECT  
        COUNT(DISTINCT website_session_id) AS sessions_posttest
    FROM website_sessions
    WHERE utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
      AND created_at > '2012-07-28'
),
aov AS (
    SELECT AVG(price_usd) AS avg_order_value
    FROM orders
)
SELECT
    (cvr_lander1.conversion_rate - cvr_home.conversion_rate) AS lift,
    p.sessions_posttest,
    ROUND(p.sessions_posttest * (cvr_lander1.conversion_rate - cvr_home.conversion_rate), 0) AS incremental_orders,
    ROUND(p.sessions_posttest * (cvr_lander1.conversion_rate - cvr_home.conversion_rate) * a.avg_order_value, 2) AS incremental_revenue
FROM posttest_sessions p
CROSS JOIN aov a
JOIN (
    SELECT conversion_rate FROM cvr WHERE landing_page = '/lander-1'
) cvr_lander1
JOIN (
    SELECT conversion_rate FROM cvr WHERE landing_page = '/home'
) cvr_home;

-- step 4: Convert to revenue
SELECT AVG(price_usd) AS avg_order_value
FROM orders;

-- Full funnel performance for 2 landers (Jun 19 – Jul 28)
WITH landing_pages AS (
    SELECT
        ws.website_session_id,
        MIN(wp.pageview_url) AS landing_page
    FROM website_sessions ws
    JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    WHERE ws.utm_source = 'gsearch'
      AND ws.utm_campaign = 'nonbrand'
      AND ws.created_at BETWEEN '2012-06-19' AND '2012-07-28'
    GROUP BY ws.website_session_id
)
SELECT
    lp.landing_page,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/products' THEN lp.website_session_id END) AS to_products,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN lp.website_session_id END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/cart' THEN lp.website_session_id END) AS to_cart,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/shipping' THEN lp.website_session_id END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/billing' THEN lp.website_session_id END) AS to_billing,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN lp.website_session_id END) AS to_thankyou
FROM landing_pages lp
LEFT JOIN website_pageviews wp
    ON lp.website_session_id = wp.website_session_id
GROUP BY lp.landing_page;

-- Billing page test impact (Sep 10 – Nov 10)
SELECT
    wp.pageview_url AS billing_version_seen,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    SUM(o.price_usd) AS revenue,
    SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions ws
LEFT JOIN website_pageviews wp
    ON ws.website_session_id = wp.website_session_id
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE wp.pageview_url IN ('/billing', '/billing-2')
  AND ws.created_at BETWEEN '2012-09-10' AND '2012-11-10'
GROUP BY wp.pageview_url;

-- Analyzing channel portfolios
SELECT
    MIN(DATE(ws.created_at)) AS week_start_date,
    COUNT(DISTINCT CASE 
        WHEN ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand' 
        THEN ws.website_session_id END) AS gsearch_sessions,
    COUNT(DISTINCT CASE 
        WHEN ws.utm_source = 'bsearch' AND ws.utm_campaign = 'nonbrand' 
        THEN ws.website_session_id END) AS bsearch_sessions
FROM website_sessions ws
WHERE ws.created_at >= '2012-08-22'
GROUP BY YEARWEEK(ws.created_at, 1)
ORDER BY week_start_date;

-- Comparing channel characteristics 
SELECT
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' 
                        THEN ws.website_session_id END) AS mobile_sessions,
    ROUND(
        COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' 
                            THEN ws.website_session_id END) * 1.0 
        / COUNT(DISTINCT ws.website_session_id),
        4
    ) AS pct_mobile
FROM website_sessions ws
WHERE ws.created_at >= '2012-08-22'
  AND ws.utm_campaign = 'nonbrand'
  AND ws.utm_source IN ('gsearch', 'bsearch')
GROUP BY ws.utm_source
ORDER BY ws.utm_source;

-- Cross-channel bid optimization
SELECT
    s.device_type,
    s.utm_source,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id)            AS orders,
    ROUND(COUNT(DISTINCT o.order_id) / COUNT(DISTINCT s.website_session_id), 4) AS conv_rate
FROM website_sessions AS s
LEFT JOIN orders AS o
       ON o.website_session_id = s.website_session_id
WHERE s.created_at >= '2012-08-22'
  AND s.created_at <  '2012-09-19'     -- exclude the special campaign period
  AND s.utm_source IN ('gsearch','bsearch')
  AND s.utm_campaign = 'nonbrand'
GROUP BY s.device_type, s.utm_source
ORDER BY s.device_type, s.utm_source;

-- Analysing channel portfolio trends
-- Weekly session volume for gsearch vs bsearch (nonbrand),
-- broken down by device, since 2012-11-04.
-- Includes bsearch as a % of gsearch.

SELECT
    MIN(DATE(s.created_at)) AS week_start_date,
    
    -- Desktop
    COUNT(DISTINCT CASE WHEN s.device_type = 'desktop' AND s.utm_source = 'gsearch' THEN s.website_session_id END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN s.device_type = 'desktop' AND s.utm_source = 'bsearch' THEN s.website_session_id END) AS b_dtop_sessions,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.device_type = 'desktop' AND s.utm_source = 'bsearch' THEN s.website_session_id END) * 1.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN s.device_type = 'desktop' AND s.utm_source = 'gsearch' THEN s.website_session_id END),0),
    2) AS b_pct_of_g_dtop,

    -- Mobile
    COUNT(DISTINCT CASE WHEN s.device_type = 'mobile' AND s.utm_source = 'gsearch' THEN s.website_session_id END) AS g_mob_sessions,
    COUNT(DISTINCT CASE WHEN s.device_type = 'mobile' AND s.utm_source = 'bsearch' THEN s.website_session_id END) AS b_mob_sessions,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.device_type = 'mobile' AND s.utm_source = 'bsearch' THEN s.website_session_id END) * 1.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN s.device_type = 'mobile' AND s.utm_source = 'gsearch' THEN s.website_session_id END),0),
    2) AS b_pct_of_g_mob

FROM website_sessions s
WHERE s.created_at >= '2012-11-04'
  AND s.utm_campaign = 'nonbrand'
  AND s.utm_source IN ('gsearch','bsearch')
GROUP BY YEARWEEK(s.created_at)  -- groups data week by week
ORDER BY week_start_date;

-- Analyzing direct traffic
-- Monthly sessions for organic search, direct type-in, and paid brand search,
-- plus each of those as a % of paid search nonbrand.

SELECT
    YEAR(s.created_at) AS yr,
    MONTH(s.created_at) AS mo,

    -- Paid search nonbrand baseline
    COUNT(DISTINCT CASE WHEN s.utm_source IN ('gsearch','bsearch')
                         AND s.utm_campaign = 'nonbrand'
                        THEN s.website_session_id END) AS nonbrand,

    -- Paid search brand
    COUNT(DISTINCT CASE WHEN s.utm_source IN ('gsearch','bsearch')
                         AND s.utm_campaign = 'brand'
                        THEN s.website_session_id END) AS brand,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.utm_source IN ('gsearch','bsearch')
                             AND s.utm_campaign = 'brand'
                            THEN s.website_session_id END) * 1.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN s.utm_source IN ('gsearch','bsearch')
                                     AND s.utm_campaign = 'nonbrand'
                                    THEN s.website_session_id END),0),
    2) AS brand_pct_of_nonbrand,

    -- Direct type-in
    COUNT(DISTINCT CASE WHEN s.utm_source IS NULL
                         AND s.utm_campaign IS NULL
                         AND s.http_referer IS NULL
                        THEN s.website_session_id END) AS direct,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.utm_source IS NULL
                             AND s.utm_campaign IS NULL
                             AND s.http_referer IS NULL
                            THEN s.website_session_id END) * 1.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN s.utm_source IN ('gsearch','bsearch')
                                     AND s.utm_campaign = 'nonbrand'
                                    THEN s.website_session_id END),0),
    2) AS direct_pct_of_nonbrand,

    -- Organic search
    COUNT(DISTINCT CASE WHEN s.utm_source IS NULL
                         AND s.http_referer IS NOT NULL
                        THEN s.website_session_id END) AS organic,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.utm_source IS NULL
                             AND s.http_referer IS NOT NULL
                            THEN s.website_session_id END) * 1.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN s.utm_source IN ('gsearch','bsearch')
                                     AND s.utm_campaign = 'nonbrand'
                                    THEN s.website_session_id END),0),
    2) AS organic_pct_of_nonbrand

FROM website_sessions s
GROUP BY YEAR(s.created_at), MONTH(s.created_at)
ORDER BY yr, mo;
 
-- Seasonality Analysis for 2012
-- Monthly and Weekly session + order volume

-- Monthly Trends
SELECT
    YEAR(s.created_at) AS yr,
    MONTH(s.created_at) AS mo,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions s
LEFT JOIN orders o
       ON o.website_session_id = s.website_session_id
WHERE YEAR(s.created_at) = 2012
GROUP BY YEAR(s.created_at), MONTH(s.created_at)
ORDER BY yr, mo;


-- Weekly Trends
SELECT
    YEAR(s.created_at) AS yr,
    WEEK(s.created_at) AS wk,
    MIN(DATE(s.created_at)) AS week_start_date,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions s
LEFT JOIN orders o
       ON o.website_session_id = s.website_session_id
WHERE YEAR(s.created_at) = 2012
GROUP BY YEAR(s.created_at), WEEK(s.created_at)
ORDER BY yr, wk;

-- Analyzing business patterns
-- Average website session volume by hour of day and day of week
-- Date range: 2012-09-15 to 2012-11-15

SELECT
    hr,
    ROUND(AVG(CASE WHEN day_of_week = 2 THEN sessions END), 1) AS mon, -- Monday
    ROUND(AVG(CASE WHEN day_of_week = 3 THEN sessions END), 1) AS tue, -- Tuesday
    ROUND(AVG(CASE WHEN day_of_week = 4 THEN sessions END), 1) AS wed, -- Wednesday
    ROUND(AVG(CASE WHEN day_of_week = 5 THEN sessions END), 1) AS thu, -- Thursday
    ROUND(AVG(CASE WHEN day_of_week = 6 THEN sessions END), 1) AS fri, -- Friday
    ROUND(AVG(CASE WHEN day_of_week = 7 THEN sessions END), 1) AS sat, -- Saturday
    ROUND(AVG(CASE WHEN day_of_week = 1 THEN sessions END), 1) AS sun  -- Sunday
FROM (
    SELECT
        DATE(created_at) AS date,
        HOUR(created_at) AS hr,
        DAYOFWEEK(created_at) AS day_of_week,
        COUNT(DISTINCT website_session_id) AS sessions
    FROM website_sessions
    WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
    GROUP BY DATE(created_at), HOUR(created_at), DAYOFWEEK(created_at)
) AS daily_sessions
GROUP BY hr
ORDER BY hr;


-- Volume Growth – Sessions & Orders by Quarter
SELECT
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o 
    ON ws.website_session_id = o.website_session_id
GROUP BY yr, qtr
ORDER BY yr, qtr;


-- Efficiency Improvements – Conversion & Revenue
SELECT
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(DISTINCT o.order_id) * 1.0 / COUNT(DISTINCT ws.website_session_id) AS session_to_order_rate,
    SUM(o.price_usd) * 1.0 / COUNT(DISTINCT o.order_id) AS revenue_per_order,
    SUM(o.price_usd) * 1.0 / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY yr, qtr
ORDER BY yr, qtr;

-- Growth of Specific Channels
SELECT
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN o.order_id END) AS gsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN o.order_id END) AS bsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id END) AS brand_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN o.order_id END) AS direct_type_in_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN o.order_id END) AS organic_search_orders
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY yr, qtr
ORDER BY yr, qtr;

-- Conversion Rate Trends by Channel
SELECT
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(DISTINCT o.order_id) * 1.0 / COUNT(DISTINCT ws.website_session_id) AS overall_conversion,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN o.order_id END) * 1.0 /
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id END) AS gsearch_conversion,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN o.order_id END) * 1.0 /
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN ws.website_session_id END) AS bsearch_conversion
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY yr, qtr
ORDER BY yr, qtr;

-- Revenue & Margin by Product
SELECT
    YEAR(o.created_at) AS yr,
    MONTH(o.created_at) AS mo,
    oi.product_id,
    SUM(oi.price_usd) AS total_revenue,
    SUM(oi.price_usd - oi.cogs_usd) AS margin,
    COUNT(DISTINCT o.order_id) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY yr, mo, product_id
ORDER BY yr, mo, product_id;

-- New Products Impact – Sessions to /products
SELECT
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/products' THEN ws.website_session_id END) AS product_sessions,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/products' AND o.order_id IS NOT NULL THEN ws.website_session_id END) * 1.0 /
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/products' THEN ws.website_session_id END) AS conversion_from_products
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
LEFT JOIN website_pageviews wp ON ws.website_session_id = wp.website_session_id
GROUP BY yr, mo
ORDER BY yr, mo;

-- Product Cross-Selling (after Dec 5, 2014)
SELECT
    YEAR(o.created_at) AS yr,
    MONTH(o.created_at) AS mo,
    oi.product_id,
    COUNT(DISTINCT o.order_id) AS sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.created_at >= '2014-12-05'
GROUP BY yr, mo, product_id
ORDER BY yr, mo, product_id;













