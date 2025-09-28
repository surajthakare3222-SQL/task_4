create database audit;
use audit;
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    stock INT
);

-- Step 2: Create audit log table
CREATE TABLE products_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    action_type VARCHAR(20),     -- INSERT, UPDATE, DELETE
    old_value VARCHAR(255),      -- old data (for update/delete)
    new_value VARCHAR(255),      -- new data (for insert/update)
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Trigger for INSERT
DELIMITER $$
CREATE TRIGGER after_product_insert
AFTER INSERT ON products
FOR EACH ROW
BEGIN
    INSERT INTO products_audit(product_id, action_type, old_value, new_value)
    VALUES (NEW.product_id, 'INSERT', NULL,
            CONCAT('Name=', NEW.product_name, ', Price=', NEW.price, ', Stock=', NEW.stock));
END$$
DELIMITER ;

-- Step 4: Trigger for UPDATE
DELIMITER $$
CREATE TRIGGER after_product_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    INSERT INTO products_audit(product_id, action_type, old_value, new_value)
    VALUES (NEW.product_id, 'UPDATE',
            CONCAT('Name=', OLD.product_name, ', Price=', OLD.price, ', Stock=', OLD.stock),
            CONCAT('Name=', NEW.product_name, ', Price=', NEW.price, ', Stock=', NEW.stock));
END$$
DELIMITER ;

-- Step 5: Trigger for DELETE
DELIMITER $$
CREATE TRIGGER after_product_delete
AFTER DELETE ON products
FOR EACH ROW
BEGIN
    INSERT INTO products_audit(product_id, action_type, old_value, new_value)
    VALUES (OLD.product_id, 'DELETE',
            CONCAT('Name=', OLD.product_name, ', Price=', OLD.price, ', Stock=', OLD.stock), NULL);
END$$
DELIMITER ;
-- Insert product
INSERT INTO products (product_name, price, stock) VALUES ('Laptop', 55000, 10);

-- Update product
UPDATE products SET price = 60000, stock = 8 WHERE product_id = 1;

-- Delete product
DELETE FROM products WHERE product_id = 1;

-- View audit log
SELECT * FROM products_audit;
