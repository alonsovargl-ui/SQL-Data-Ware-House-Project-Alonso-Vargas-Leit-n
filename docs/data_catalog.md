# Data Dictionary for Gold layer

## Overview 

The gold layer is a business-level data representation, structured to support analytical and reporting use cases. It consists of **dimemsion tables** and **fact tables** for specific business metrics.

###

---

### 1. gold.dim_customers

* **Purpose:** Stores customer details enriched with demographic and geographic data.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `customer_key` | `INT` | Surrogate key uniquely identifying each customer record in the dimension table. |
| `customer_id` | `INT` | Unique numerical identifier assigned to each customer. |
| `customer_number` | `NVARCHAR(50)` | Alphanumeric identifier representing the customer, used for tracking and referencing. |
| `first_name` | `NVARCHAR(50)` | The customer's first name, as recorded in the system. |
| `last_name` | `NVARCHAR(50)` | The customer's last name or family name. |
| `country` | `NVARCHAR(50)` | The country of residence for the customer (e.g., 'Australia'). |
| `marital_status` | `NVARCHAR(50)` | The marital status of the customer (e.g., 'Married', 'Single'). |
| `gender` | `NVARCHAR(50)` | The gender of the customer (e.g., 'Male', 'Female', 'n/a'). |
| `birthdate` | `DATE` | The birthdate of the customer, formated as YYYY-MM-DD (e.g., '1971-10-06')|
| `create_date` | `DATE` | The the date and time when the customer record was created in the system.|

---

---

### 2. gold.dim_products

* **Purpose:** Provides information about the products and their attributes.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `product_key` | `BIGINT` | Surrogate key uniquely identifying each product record in the dimension table. |
| `product_id` | `INT` | Unique numerical identifier assigned to each product. |
| `product_number` | `NVARCHAR(50)` | Alphanumeric identifier representing the product, used for tracking and referencing. |
| `product_name` | `NVARCHAR(100)` | Name or title of the product. |
| `category_id` | `NVARCHAR(50)` | Identifier for the product category. |
| `category` | `NVARCHAR(50)` | Category name to which the product belongs (e.g., Components, Bikes). |
| `subcategory` | `NVARCHAR(50)` | Subcategory name providing a finer classification (e.g., Road Frames, Road Bikes). |
| `maintenance` | `NVARCHAR(10)` | Indicates whether the product requires maintenance (e.g., Yes, No). |
| `product_cost` | `INT` | Cost associated with the product. |
| `product_line` | `NVARCHAR(50)` | Product line classification (e.g., Road, Mountain). |
| `product_start_date` | `DATE` | Date when the product became available or active. |


---

### 3. gold.fact_sales

* **Purpose:** Stores transactional sales data representing business events, metrics, and relationships to dimension tables.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `order_number` | `NVARCHAR(50)` | Unique alphanumeric identifier for each sales order. |
| `product_key` | `BIGINT` | Foreign key referencing the product in `gold.dim_products`. |
| `customer_key` | `BIGINT` | Foreign key referencing the customer in `gold.dim_customers`. |
| `order_date` | `DATE` | Date when the order was placed by the customer. |
| `shipping_date` | `DATE` | Date when the order was shipped to the customer. |
| `due_date` | `DATE` | Expected delivery or payment due date for the order. |
| `sales_amount` | `INT` | Total revenue generated from the sale item. |
| `quantity` | `INT` | Number of product units purchased. |
| `price` | `DECIMAL(18,2)` | Unit price of the product at the time of purchase. |
