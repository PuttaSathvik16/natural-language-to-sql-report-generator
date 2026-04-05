-- ================================================
-- Slack @databot SQL Query Assistant
-- Database Schema + Seed Data
-- ================================================

-- Create tables
CREATE TABLE customers (
  id bigserial PRIMARY KEY,
  name text,
  email text,
  region text,
  created_at date
);

CREATE TABLE products (
  id bigserial PRIMARY KEY,
  name text,
  category text,
  price float4
);

CREATE TABLE orders (
  id bigserial PRIMARY KEY,
  customer_id bigint REFERENCES customers(id),
  order_date date,
  total_amount float4,
  status text  -- values: pending, shipped, delivered, cancelled
);

-- ================================================
-- Seed data
-- ================================================

INSERT INTO customers (name, email, region, created_at) VALUES
('Alice Johnson', 'alice@example.com', 'North', '2024-01-15'),
('Bob Smith', 'bob@example.com', 'South', '2024-02-20'),
('Carol White', 'carol@example.com', 'East', '2024-03-10'),
('David Brown', 'david@example.com', 'West', '2024-01-28'),
('Eva Green', 'eva@example.com', 'North', '2024-04-05');

INSERT INTO products (name, category, price) VALUES
('Laptop Pro', 'Electronics', 1299.99),
('Wireless Mouse', 'Electronics', 29.99),
('Standing Desk', 'Furniture', 499.99),
('Monitor 4K', 'Electronics', 399.99),
('Office Chair', 'Furniture', 249.99);

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
(1, '2024-03-01', 1299.99, 'delivered'),
(2, '2024-03-15', 29.99, 'shipped'),
(3, '2024-04-01', 499.99, 'pending'),
(1, '2024-04-10', 399.99, 'delivered'),
(4, '2024-04-12', 249.99, 'shipped'),
(5, '2024-04-15', 1299.99, 'pending');
