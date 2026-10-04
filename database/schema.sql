CREATE DATABASE IF NOT EXISTS smart_traffic_db;
USE smart_traffic_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('Admin','Operator','User') NOT NULL DEFAULT 'User'
);

CREATE TABLE IF NOT EXISTS accidents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_name VARCHAR(100) NOT NULL,
    contact VARCHAR(20) NOT NULL,
    location VARCHAR(255) NOT NULL,
    accident_type VARCHAR(100) NOT NULL,
    severity ENUM('Low','Medium','High','Critical') NOT NULL,
    description TEXT,
    status ENUM('Reported','Verified','Ambulance Assigned','Hospital Notified','Resolved')
        NOT NULL DEFAULT 'Reported',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS traffic (
    id INT AUTO_INCREMENT PRIMARY KEY,
    road_name VARCHAR(150) NOT NULL,
    area VARCHAR(120) NOT NULL,
    traffic_level ENUM('Low','Moderate','Heavy','Critical') NOT NULL,
    reason VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ambulances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_number VARCHAR(30) NOT NULL UNIQUE,
    driver_name VARCHAR(100) NOT NULL,
    contact VARCHAR(20) NOT NULL,
    status ENUM('Available','On Duty','Maintenance') NOT NULL DEFAULT 'Available',
    location VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS hospitals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    location VARCHAR(150) NOT NULL,
    contact VARCHAR(20) NOT NULL,
    available_beds INT NOT NULL DEFAULT 0,
    status ENUM('Available','Busy','Emergency Only') NOT NULL DEFAULT 'Available'
);

CREATE TABLE IF NOT EXISTS emergency_response (
    id INT AUTO_INCREMENT PRIMARY KEY,
    accident_id INT NOT NULL,
    ambulance_id INT,
    hospital_id INT,
    police_status VARCHAR(50) DEFAULT 'Pending',
    ambulance_status VARCHAR(50) DEFAULT 'Pending',
    hospital_status VARCHAR(50) DEFAULT 'Pending',
    response_status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (accident_id) REFERENCES accidents(id) ON DELETE CASCADE,
    FOREIGN KEY (ambulance_id) REFERENCES ambulances(id) ON DELETE SET NULL,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE SET NULL
);

INSERT IGNORE INTO ambulances (vehicle_number, driver_name, contact, status, location) VALUES
('MH-12-AMB-101', 'Raj Patil', '9876543210', 'Available', 'Shivajinagar'),
('MH-12-AMB-102', 'Amit Jadhav', '9876543211', 'On Duty', 'Swargate'),
('MH-14-AMB-201', 'Rohan More', '9876543212', 'Available', 'Pimpri');

INSERT IGNORE INTO hospitals (name, location, contact, available_beds, status) VALUES
('City Care Hospital', 'Shivajinagar', '020-24560001', 12, 'Available'),
('LifeLine Emergency Hospital', 'Swargate', '020-24560002', 5, 'Emergency Only'),
('Metro Multispeciality Hospital', 'Pimpri', '020-24560003', 18, 'Available');

INSERT IGNORE INTO traffic (road_name, area, traffic_level, reason) VALUES
('M.G. Road', 'Shivajinagar', 'Heavy', 'Peak hour traffic'),
('Station Road', 'Pune Station', 'Moderate', 'Road maintenance'),
('University Road', 'Aundh', 'Low', 'Normal traffic'),
('Nagar Road', 'Viman Nagar', 'Critical', 'Accident reported');

INSERT INTO accidents
(reporter_name, contact, location, accident_type, severity, description, status)
SELECT 'Demo User', '9876500000', 'Nagar Road, Viman Nagar', 'Vehicle Collision',
       'High', 'Two vehicle collision near junction.', 'Verified'
WHERE NOT EXISTS (SELECT 1 FROM accidents WHERE reporter_name='Demo User');

INSERT INTO accidents
(reporter_name, contact, location, accident_type, severity, description, status)
SELECT 'Emergency Caller', '9876500001', 'Station Road', 'Two-Wheeler Accident',
       'Critical', 'Emergency assistance required.', 'Ambulance Assigned'
WHERE NOT EXISTS (SELECT 1 FROM accidents WHERE reporter_name='Emergency Caller');
