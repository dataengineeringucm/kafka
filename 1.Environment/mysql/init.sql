CREATE DATABASE IF NOT EXISTS db;

USE db;

-- Unable to load authentication plugin 'caching_sha2_password'
ALTER USER 'user'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'user'@'%';