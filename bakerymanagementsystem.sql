-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 31, 2021 at 12:20 AM
-- Server version: 10.4.21-MariaDB
-- PHP Version: 7.3.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bakery2`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `acceptRequest` (IN `adminName` VARCHAR(50), IN `adminPass` VARCHAR(30), IN `prodID` VARCHAR(10))  BEGIN 
UPDATE inventoryproducts 
SET quantity = quantity-100 
WHERE inventoryID = getInventoryID(adminName,adminPass) 
AND productID = prodID 
AND quantity > 0;

Update stockproducts SET quantity = quantity + 100 WHERE productID = prodID AND branchID = (SELECT branchID from requests WHERE productID = prodID); 

DELETE FROM requests WHERE productID = prodID; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addInvID_branch` (IN `adminName` VARCHAR(50), IN `adminPass` VARCHAR(30))  BEGIN 
DECLARE bID INT; 
SET bID = (SELECT MAX(branchID) FROM branch);

UPDATE branch SET inventoryID = (getInventoryID(adminName, adminPass))
WHERE branchID = bID; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addLocationID_managerID_branch` ()  BEGIN 
DECLARE locID INT; 
DECLARE branID INT; 
DECLARE mngrID INT;
SET locID = (SELECT MAX(locationID) FROM location); 
SET branID = (SELECT MAX(branchID) FROM branch); 
SET mngrID = (SELECT MAX(managerID) FROM manager);
UPDATE branch SET locationID = locID, managerID = mngrID WHERE branchID = branID; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addProductID_InvProducts` (IN `productQuantity` INT(5), IN `adminName` VARCHAR(50), IN `adminPass` VARCHAR(30))  BEGIN 
DECLARE prodID INT; 
SET prodID = (SELECT MAX(productID) FROM product); 
INSERT INTO inventoryproducts VALUES (getInventoryID(adminName, adminPass), `prodID`, `productQuantity`, NULL, NULL);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addToCart` (IN `u_email` VARCHAR(50), IN `u_pass` VARCHAR(30), IN `prodID` INT(10))  BEGIN
DECLARE customID INT(10);
DECLARE productPrice INT(10);
DECLARE prodName VARCHAR(50);
SET customID = getCustomerID(u_email, u_pass);
SET productPrice = (SELECT price FROM product WHERE productID = prodID);
SET prodName = (SELECT name FROM product WHERE productID = prodID);
INSERT INTO cart(cusID, prodID, productName, price) VALUES (customID, prodID, prodName, productPrice);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addToOrder` (IN `c_email` VARCHAR(50), IN `c_pass` VARCHAR(30))  BEGIN
DECLARE totalProd INT(10);
DECLARE customID INT(10);
DECLARE totalAmount INT(10);

SET totalProd = (SELECT COUNT(price) FROM cart);
SET customID = getCustomerID(c_email, c_pass);
SET totalAmount = (SELECT SUM(price) FROM cart);
INSERT INTO customerorder(`numberOfItems`, `amount`, `cusID`) VALUES (totalProd, totalAmount, customID);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addToOrderProducts` ()  BEGIN
INSERT INTO orderproducts(`productID`) (SELECT prodID FROM cart);

UPDATE orderproducts SET orderID = (SELECT MAX(orderID) FROM customerorder) WHERE orderID IS NULL;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_to_stock` (IN `bID` INT(10), IN `prodID` INT(10))  BEGIN 
UPDATE stockproducts 
SET quantity = quantity+100 
WHERE stockID = branchID 
AND productID = prodID 
AND quantity < 20; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `changeMain_role` (IN `mngrID` INT(10))  BEGIN 
DECLARE m_name VARCHAR(50); 
DECLARE m_number VARCHAR(13); 
DECLARE m_service VARCHAR(10); 
DECLARE m_salary INT(6); 
DECLARE m_username VARCHAR(50); 
DECLARE m_password VARCHAR(30);
DECLARE max_adminID INT(10);
SET m_name = (SELECT name FROM manager WHERE managerID = mngrID); 
SET m_number = (SELECT contactNum FROM manager WHERE managerID = mngrID); 
SET m_service = (SELECT lengthOfService FROM manager WHERE managerID = mngrID); 
SET m_salary = (SELECT salary FROM manager WHERE managerID = mngrID); 
SET m_username = (SELECT username FROM managerlogin WHERE managerID = mngrID); 
SET m_password = (SELECT password FROM managerlogin WHERE managerID = mngrID); 

INSERT INTO admin(`name`,`contactNum`,`lengthOfService`,`salary`) VALUES (m_name,m_number,m_service,m_salary); 
DELETE FROM manager WHERE managerID = mngrID; 

SET max_adminID = (SELECT MAX(adminID) FROM adminlogin);

UPDATE adminlogin SET username = m_username, password = m_password WHERE adminID = max_adminID; 
DELETE FROM managerlogin WHERE managerID = mngrID; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `declineRequest` (IN `reqID` INT(10))  BEGIN 
DELETE FROM requests WHERE requestID = reqID; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteBranch` (IN `branID` INT(10))  BEGIN 
DELETE FROM branch 
WHERE branchID = branID; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteCategory` (IN `categID` INT(10))  BEGIN DELETE FROM category
WHERE categoryID = categID; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteEmployee` (IN `employeeID` INT(10))  BEGIN DELETE FROM empinfo 
WHERE empID = employeeID; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteProduct` (IN `prodID` INT(10))  BEGIN DELETE FROM product
WHERE productID = prodID; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteVehicle` (IN `vehID` INT(10))  BEGIN 
DELETE FROM vehicle 
WHERE vehicleID = vehID; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `displayOrderHistory` (IN `c_email` VARCHAR(50), IN `c_pass` VARCHAR(50))  BEGIN
DECLARE customID INT(10);
SET customID = getCustomerID(c_email, c_pass);
SELECT date, name, price 
FROM customerorder JOIN orderproducts USING(orderID) JOIN product USING(productID) 
WHERE cusID = customID; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getOrderedProduct` ()  BEGIN
SELECT productID
FROM orderproducts op JOIN orderbranch ob USING(orderID)
JOIN bakerystock bs USING(branchID)
JOIN stockproducts sp USING(stockID)
WHERE op.productID = sp.productID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spotlightProduct` ()  BEGIN 
SELECT name FROM product 
WHERE productID = (SELECT MAX(productID) FROM maxsales_view); 
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getCustomerID` (`u_email` VARCHAR(50), `u_password` VARCHAR(30)) RETURNS INT(10) BEGIN 
DECLARE customerID INT; 
SET customerID = (SELECT cusID FROM customer c WHERE c.email = u_email AND c.password = u_password); RETURN customerID; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getInventoryID` (`adminName` VARCHAR(50), `adminPass` VARCHAR(30)) RETURNS INT(10) BEGIN
DECLARE invID INT;
SET invID = (SELECT inventoryID 
FROM adminlogin a JOIN productioncenter USING (adminID) JOIN inventory USING (productionCenterID) 
WHERE a.username = adminName AND a.password = adminPass);
RETURN invID;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getLastOrderID` () RETURNS INT(10) BEGIN 
DECLARE ordID INT; 
SET ordID = (SELECT MAX(orderID) 
FROM customerorder); 
RETURN ordID; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getOrderBranch` (`oID` INT(10), `customerID` INT(10)) RETURNS INT(10) BEGIN
DECLARE cityName VARCHAR(30);
DECLARE bID INT;

SET cityName = (SELECT city
FROM customerorder co JOIN customer c USING (cusID) JOIN address USING (addressID) 
WHERE co.orderID = oID AND c.cusID = customerID);

SET bID = (SELECT MAX(branchID) FROM branch JOIN location l USING (locationID) WHERE l.city = cityName);

RETURN bID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `address`
--

CREATE TABLE `address` (
  `addressID` int(10) NOT NULL,
  `street` varchar(30) DEFAULT NULL,
  `area` varchar(30) DEFAULT NULL,
  `city` varchar(30) NOT NULL,
  `zipCode` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `address`
--

INSERT INTO `address` (`addressID`, `street`, `area`, `city`, `zipCode`) VALUES
(1, '17', 'I-14', 'Islamabad', 44000),
(2, 'B-53', 'Sarina Tower', 'Karachi', 75100),
(3, 'B-385', 'Federal B Area', 'Karachi', 75600),
(4, '8', 'Davis Road', 'Lahore', 54200),
(5, '14', 'Hassan Ali Lane', 'Karachi', 75150),
(6, '19', 'Defense Colony', 'Peshawar', 25000),
(7, '26', 'Westridge', 'Rawalpindi', 46060),
(8, 'Block-6', 'Shahrah-e-Faisal', 'Karachi', 75100),
(9, '6', 'Bahria Town Phase 4', 'Islamabad', 44000),
(10, '43', 'Multan Road', 'Lahore', 54000),
(11, '21', 'Hitec City', 'Hyderabad', 71000),
(12, '14/400', 'Tajpura', 'Sialkot', 51040),
(13, 'Monroe Street', 'Stadium Road', 'Sheikhupura', 39350),
(14, '401', 'I.I.Chundrigar Road', 'Karachi', 75000),
(15, '4', 'Heavy Factory Area', 'Khushab', 41000),
(16, 'Chak #203', 'Sheikhupura Road', 'Faisalabad', 38070),
(17, '105', 'Mir Khalil-ur-Rahman Road', 'Quetta', 87300),
(18, '90-SD House', 'Zafar Shaheed Road', 'Lahore', 41500),
(19, '63', 'Sultanabad Colony Gulgasht', 'Multan', 59300),
(20, 'Gulzar Chambers 21', 'West Wharf Road,', 'Karachi', 75200),
(21, '2', 'Nowshera Road', 'Gujranwala', 50250),
(22, '38', 'Nishtar Road', 'Lahore', 41000),
(23, '13', 'National Park Road', 'Rawalpindi', 46100),
(24, '5', 'Circular Road', 'Rawalpindi', 46000),
(25, 'Peshawar Road', 'Kohinoor Mills', 'Rawalpindi', 46000),
(26, '66-B', 'Chandni Shopping Mall', 'Hyderabad', 71200),
(27, 'Ratta Mansion 69-W', 'Blue Area', 'Islamabad', 44000),
(28, '41-F', 'Shah Ruken-e-Alam Colony', 'Multan', 59000),
(29, 'Daska Road', 'Pakki Kotli', 'Sialkot', 51000),
(30, '61', 'I-8', 'Islamabad', 44000),
(31, '38', 'University Road', 'Peshawar', 25120),
(32, '59', 'Adamjee Road', 'Rawalpindi', 46000),
(33, '11', 'Shahrah-e-Iqbal', 'Quetta', 87000),
(34, 'Zakaria Lane', 'Jodia Bazar', 'Karachi', 75200),
(35, 'Block-6', 'Jinnah Avenue', 'Islamabad', 44000),
(36, '37', 'Mangla Road', 'Tehsil Dina Mangla', 49430),
(37, '853', 'Davis Forest', 'Gwadar', 46000),
(38, '109', 'Shergarh-Chunian Road', 'Deo Sial', 30010),
(39, '1', 'Ayoub Gate', 'Sukkur', 65200),
(40, '187', 'Munir Shaheed Colony', 'Kasur', 55050),
(41, '6-A', 'Gulberg II', 'Lahore', 41200),
(42, 'D-97', 'S.I.T.E.', 'Karachi', 75700),
(43, '67', 'Iqbal Stadium', 'Faisalabad', 38000),
(44, '33', 'F-10', 'Islamabad', 46000),
(45, 'Saqib Plaza', 'Bank Road', 'Rawalpindi', 46100),
(46, '45', 'Defense Road Fateh Garh', 'Sialkot', 51250),
(47, '9', 'Station Road', 'Shikarpur', 78100),
(48, '2/229-B', 'Pechs', 'Karachi', 75000),
(49, '37-B', 'Khyber Bazaar', 'Peshawar', 25000),
(50, 'Block A', 'Korang Town', 'Islamabad', 46000),
(51, 'Block-1', 'F.B Area', 'Karimabad', 15700),
(52, '54', 'Baldia Town', 'Sahiwal', 57000),
(53, '29', 'Feroze Pur Road', 'Lahore', 41000),
(54, 'B-212', 'Mohni Bazar', 'Nawabshah', 67450),
(55, '213-2-C1', 'Township Lahore', 'Lahore', 41050),
(56, '206-C', 'Garden West', 'Karachi', 75450),
(57, '21/2', 'N.B. Teh.Distt.', 'Sargodha', 40100),
(58, '521', 'Sir Shah Suleman Road', 'Karachi', 75000),
(59, 'Hill View Lane', 'Adyalla Road', 'Rawalpindi', 67450),
(60, 'Civil Line', 'Munir Chowk', 'Gujranwala', 50250),
(61, '55', 'Mano-Chak', 'Gujrat', 67450),
(62, '7', 'Race Course Road', 'Rawalpindi', 46050),
(63, '25', 'Dallowali, Cantt.', 'Sialkot', 51000),
(64, '421', 'Jinnah Road', 'Quetta', 87400),
(65, 'Meerani Street', 'Muhalla Karma Bagh', 'Larkana', 77150),
(66, '12', 'F-7/2', 'Islamabad', 44100),
(67, '73', 'Railway Road', 'Multan', 59450),
(68, '17-C', '12th Commercial Street,Phase I', 'Karachi', 75150),
(69, '5-A', 'F-7/4', 'Islamabad', 44000),
(70, '342', 'Sarfraz Colony', 'Faisalabad', 38000),
(71, 'A-4', 'S.I.T.E.', 'Kotri', 76000),
(72, '18', 'CBR Town', 'Islamabad', 44100),
(73, '26', 'Officers Colony', 'Wah Cantt.', 46550),
(74, '83', 'Babar Block New Garden Town', 'Lahore', 41000),
(75, '16-D', 'Safdar Mansion, Blue Area', 'Islamabad', 44000),
(76, 'Q-74', 'Estate Avenue', 'Karachi', 75000),
(77, '1015-E', 'Sargodha Road', 'Faisalabad', 38000),
(78, 'D/103', 'Ghani Chowrangi', 'Karachi', 75000),
(79, '2', 'F-8/1', 'Islamabad', 44000),
(80, '38', 'Empress Road', 'Lahore', 41000),
(81, 'G-6', 'Montgomery Road', 'Lahore', 41050),
(82, '72', 'I-8/3', 'Islamabad', 44000),
(83, '10', 'Committee Chowk', 'Rawalpindi', 46000),
(84, '32', 'Sector E-1, Phase I', 'Hayatabad', 25100),
(85, '3', 'Amir Manzil, Ratan Talao', 'Karachi', 75000),
(86, '30', 'Dar-ul-Ihsan Town', 'Faisalabad', 38100),
(87, 'Alamgir Street', 'Chubarji', 'Lahore', 41000),
(88, '9', 'Dil Mohammad Road', 'Lahore', 41000),
(89, '4', 'Jhelum Road', 'Chakwal', 48800),
(90, '28-B', 'West Blue Area', 'Islamabad', 44000),
(91, 'cannoli street', 'Chauka Avenue', 'Islamabad', 44090),
(92, 'theeta street', 'Snake Lane', 'Wah Cantt', 47000),
(93, '33', 'westridge-3', 'Rawalpindi', 46060),
(94, '8', 'misrial Road', 'Rawalpindi', 46060),
(95, 'Indus Loop', 'Kashmir Highway', 'Islamabad', 69696),
(96, '420', 'peshawar', 'also peshawar', 98745),
(97, '78', 'Somewhere', 'Idk', 78965),
(98, '456', 'westridge-3', 'Rawalpindi', 46060),
(99, '1', 'I-14', 'Islamabad', 45202),
(100, '33', 'westridge-3', 'Rawalpindi', 46060),
(101, '1', '2', '3', 12354),
(102, '33', 'westridge', 'rawalpindi', 78965),
(103, '7', 'misrial road', 'rawalpindi', 45632),
(104, '4', 'saddar', 'karachi', 45632),
(105, '7', 'I-14', 'Islamabad', 78965),
(106, '4', 'saddar', 'Karachi', 45632),
(107, '4', 'I-14', 'Islamabad', 45632),
(108, '1', 'saddar', 'Karachi', 78965),
(109, '78', 'I-14', 'Islamabad', 78965);

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `adminID` int(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `contactNum` varchar(13) NOT NULL,
  `lengthOfService` int(3) NOT NULL,
  `salary` int(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`adminID`, `name`, `contactNum`, `lengthOfService`, `salary`) VALUES
(1, 'Syeda Fatima', '0334-8604860', 5, 13206000),
(2, 'Hafsa Malik', '0332-2032002', 6, 13321200),
(3, 'Khubaib Ahmad', '0333-3366910', 6, 13212000),
(4, 'Sadia Rehman', '0332-1010111', 2, 7206000);

--
-- Triggers `admin`
--
DELIMITER $$
CREATE TRIGGER `addAdminID_adlog` AFTER INSERT ON `admin` FOR EACH ROW INSERT INTO adminlogin(adminID) VALUES (new.adminID)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `adminlogin`
--

CREATE TABLE `adminlogin` (
  `adminID` int(10) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `adminlogin`
--

INSERT INTO `adminlogin` (`adminID`, `username`, `password`) VALUES
(1, 'timasyed', 'krunkerpro4860'),
(2, 'hafsa.malik', 'hamstertunn'),
(4, 'sadia.rehman', 'scissors420');

-- --------------------------------------------------------

--
-- Table structure for table `bakerystock`
--

CREATE TABLE `bakerystock` (
  `stockID` int(10) NOT NULL,
  `branchID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `bakerystock`
--

INSERT INTO `bakerystock` (`stockID`, `branchID`) VALUES
(2, 2);

-- --------------------------------------------------------

--
-- Table structure for table `branch`
--

CREATE TABLE `branch` (
  `branchID` int(10) NOT NULL,
  `capacity` int(10) NOT NULL,
  `establishDate` date DEFAULT NULL,
  `locationID` int(10) DEFAULT NULL,
  `managerID` int(10) DEFAULT NULL,
  `inventoryID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `branch`
--

INSERT INTO `branch` (`branchID`, `capacity`, `establishDate`, `locationID`, `managerID`, `inventoryID`) VALUES
(2, 15, '2006-03-22', 3, 3, 3),
(4, 15, '2021-12-29', 1, 1, 2),
(5, 15, '2021-12-29', 8, 5, 1);

--
-- Triggers `branch`
--
DELIMITER $$
CREATE TRIGGER `autoDate_branch_bms` BEFORE INSERT ON `branch` FOR EACH ROW SET NEW.establishDate = IFNULL(NEW.establishDate, date(NOW()))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `cusID` int(10) DEFAULT NULL,
  `prodID` int(10) DEFAULT NULL,
  `productName` varchar(50) NOT NULL,
  `price` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `categoryID` int(10) NOT NULL,
  `name` varchar(30) NOT NULL,
  `categoryItems` int(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`categoryID`, `name`, `categoryItems`) VALUES
(1, 'Bread', 12),
(2, 'Biscuits', 12),
(3, 'Cake', 12),
(4, 'Donut', 12),
(6, 'pizza', 12),
(7, 'Salads', 12);

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `cusID` int(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `contactNum` varchar(14) NOT NULL,
  `addressID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`cusID`, `name`, `email`, `password`, `contactNum`, `addressID`) VALUES
(1, 'Daneesh ', 'daneeshtheeta@gmail.com', 'dtheeta1122', '0300-9876544', 9),
(2, 'Hamna Raowoof', 'boardtapper@canoli.com', 'tapper4.0', '0336-4323344', 85),
(3, 'Alina Nasir', 'alinanasir@gmail.com', 'aleleleleina', '0300-9876544', 12),
(4, 'Mushtafa', 'codingmastur@coursera.com', 'ssssss7', '0336-4323344', 23),
(5, 'Ayesha Malik', 'ayesha.malikmalik98@gmail.com', 'lol', '+923155105847', 93),
(6, 'Hafsa Malik', 'hafsamalik322@gmail.com', 'meow', '03009562773', 98);

--
-- Triggers `customer`
--
DELIMITER $$
CREATE TRIGGER `setAddressID_customer` BEFORE INSERT ON `customer` FOR EACH ROW SET NEW.addressID = IFNULL(NEW.addressID, (SELECT MAX(addressID) FROM address))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customerorder`
--

CREATE TABLE `customerorder` (
  `orderID` int(10) NOT NULL,
  `date` date DEFAULT NULL,
  `numberOfItems` int(3) NOT NULL,
  `amount` int(6) NOT NULL,
  `cusID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `customerorder`
--

INSERT INTO `customerorder` (`orderID`, `date`, `numberOfItems`, `amount`, `cusID`) VALUES
(1, '2021-12-02', 3, 5000, 1),
(2, '2021-11-24', 1, 1200, 2),
(3, '2021-12-26', 1, 1000, 4),
(5, '2021-12-28', 1, 100, 6),
(6, '2021-12-28', 6, 3900, 6),
(7, '2021-12-28', 1, 100, 6),
(18, '2021-12-29', 1, 300, 6);

--
-- Triggers `customerorder`
--
DELIMITER $$
CREATE TRIGGER `setOrderBranch` AFTER INSERT ON `customerorder` FOR EACH ROW INSERT INTO orderbranch(orderID, branchID) VALUES(new.orderID, getOrderBranch(new.orderID, new.cusID))
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `setOrderDate_cusorder` BEFORE INSERT ON `customerorder` FOR EACH ROW SET NEW.date = IFNULL(NEW.date, date(NOW()))
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `subtract_from_stock` AFTER INSERT ON `customerorder` FOR EACH ROW BEGIN DECLARE ordID INT; 
SET ordID = getLastOrderID(); 
UPDATE stockproducts 
SET quantity = quantity -1 
WHERE productID IN (SELECT productID FROM orderproducts WHERE orderID = ordID) 
AND quantity > 0; 
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `empbranch`
--

CREATE TABLE `empbranch` (
  `empID` int(10) NOT NULL,
  `branchID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `empinfo`
--

CREATE TABLE `empinfo` (
  `empID` int(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `phoneNum` varchar(13) NOT NULL,
  `addressID` int(10) DEFAULT NULL,
  `hireDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `empinfo`
--

INSERT INTO `empinfo` (`empID`, `name`, `phoneNum`, `addressID`, `hireDate`) VALUES
(1, 'Tristan Figueroa', '051-5516107', 9, '2017-08-08'),
(2, 'Davin Chan', '042-6361315', 19, '2017-12-23'),
(3, 'Kellen Sixton', '0221-2765521', 22, '2018-01-01'),
(4, 'Julio Hardin', '042-7214768', 24, '2018-01-02'),
(5, 'Jaylynn Vargas', '0344-3081694', 23, '2018-02-07'),
(6, 'Luciano Baxter', '043-2268318', 1, '2018-03-08'),
(7, 'Christine Mckay', '022-2780179', 10, '2018-05-24'),
(8, 'Milagros Ellison', '0221-6998994', 53, '2018-06-07'),
(9, 'Makenna Cobb', '091-5701457', 52, '2018-06-18'),
(10, 'Joe Greer', '042-7655148', 27, '2018-08-18'),
(11, 'Esmeralda Arellano', '0321-2432730', 14, '2018-08-23'),
(12, 'Ava Jensen', '0333-3307128', 13, '2018-11-13'),
(13, 'Rowan Avery', '051-7220800', 16, '2019-01-30'),
(14, 'Clarissa Andersen', '0332-2581455', 34, '2019-02-04'),
(15, 'Audrey Doyle', '043-2590194', 35, '2019-07-26'),
(16, 'Jett Anthony', '042-7960023', 45, '2019-08-21'),
(17, 'Kaylie Benson', '021-3432130', 21, '2019-10-31'),
(18, 'Audrey Wright', '0300-4421012', 2, '2020-03-04'),
(19, 'Marquise Larsen', '051-5542827', 37, '2020-05-17'),
(20, 'Dayton Haynes', '042-7652184', 30, '2020-08-27'),
(21, 'Nylah Ashley', '093-7862685', 32, '2021-01-29'),
(22, 'Reginald Merritt', '0333-3036085', 40, '2021-05-18'),
(23, 'Joey Castillo', '024-2410379', 18, '2021-06-15'),
(24, 'Ally Oconnor', '041-2648780', 44, '2021-06-28'),
(25, 'Karina Cochran', '0332-4841443', 17, '2018-08-20'),
(26, 'Charlie Holland', '021-6312285', 50, '2018-09-04'),
(27, 'Helen Ali', '0310-4841443', 41, '2018-09-07'),
(28, 'Xander Bass', '0323-8658429', 28, '2018-10-01'),
(29, 'Tate Christensen', '052-3240061', 31, '2018-11-11'),
(30, 'Naima Garza', '055-3857007', 48, '2018-12-28'),
(31, 'Kareem Moreno', '043-1264184', 46, '2019-04-22'),
(32, 'Mariyah Russell', '021-2215142', 39, '2019-05-03'),
(33, 'Kennedi Cobb', '042-7721465', 8, '2019-10-25'),
(34, 'Crystal Fowler', '021-4937930', 54, '2019-11-02'),
(35, 'Kai Trujillo', '042-4523386', 47, '2019-11-03'),
(36, 'Dawson Schmitt', '051-6640569', 43, '2019-12-19'),
(37, 'Brendon Hines', '0221-6681127', 15, '2020-01-06'),
(38, 'Alexandra Stein', '0221-5363907', 25, '2020-02-14'),
(39, 'Maximo James', '043-6625718', 4, '2020-02-26'),
(40, 'Isai Patel', '041-8545415', 20, '2020-07-15'),
(41, 'Gilbert Krueger', '041-2690606', 6, '2020-09-21'),
(42, 'Reyna Dixon', '051-5531030', 3, '2020-11-18'),
(43, 'Areli Fritz', '0333-6619921', 29, '2020-11-30'),
(44, 'Eduardo Frye', '021-2250930', 11, '2021-01-05'),
(45, 'Erica Carlson', '051-4527172', 33, '2021-01-18'),
(46, 'Laura Heath', '0331-8783298', 7, '2021-08-21'),
(47, 'Brayan Baker', '021-2426963', 51, '2021-08-23'),
(48, 'Jamison Oneal', '0332-8795152', 12, '2021-09-17'),
(49, 'Isla Werner', '051-4850551', 49, '2017-12-28'),
(50, 'Julia Good', '021-6640965', 36, '2018-04-15'),
(51, 'Robert Tucker', '081-2821859', 38, '2018-04-20'),
(52, 'Haylee Cardenas', '0322-2042730', 42, '2018-05-06'),
(53, 'Kayden Bauer', '051-4313364', 26, '2018-07-18'),
(54, 'Ann Evans', '052-3540340', 5, '2019-05-31'),
(55, 'Gilberto Caldwell', '042-7587652', 84, '2017-02-14'),
(56, 'Renee Goodman', '0321-5871795', 62, '2017-03-11'),
(57, 'Dustin Blake', '051-5529699', 83, '2017-04-26'),
(58, 'Samantha Fitzgerald', '0334-9919561', 78, '2017-05-07'),
(59, 'Ellen Woods', '021-2215142', 67, '2017-05-30'),
(60, 'Darrel Castillo', '042-7640302', 82, '2017-12-28'),
(61, 'Willie Fields', '0300-4270983', 77, '2018-02-22'),
(62, 'Terri Obrien', '052-4262377', 81, '2018-07-02'),
(63, 'Rodolfo Gonzales', '0310-5639677', 65, '2018-10-15'),
(64, 'Felix Hines', '051-5554993', 79, '2019-03-05'),
(65, 'Yvette Richards', '021-2625466', 70, '2018-11-27'),
(66, 'Maggie Nichols', '0300-4113443', 66, '2019-04-17'),
(67, 'Gabriel Bass', '051-2575811', 74, '2018-12-11'),
(68, 'Leonard Mccormick', '0333-2737012', 60, '2019-08-20'),
(69, 'Jeremiah Parker', '041-8869132', 68, '2018-11-25'),
(70, 'Essie Allison', '021-7693584', 69, '2018-11-18'),
(71, 'Lorenzo Barker', '052-4274258', 63, '2019-09-15'),
(72, 'Russell Mcguire', '071-5623991', 57, '2019-09-23'),
(73, 'Neal Walton', '0300-5073647', 73, '2020-02-05'),
(74, 'Allen Chandler', '0340-2575116', 64, '2020-06-20'),
(75, 'Jay Goodwin', '0343-2625305', 80, '2021-02-22'),
(76, 'Rosemarie Hansen', '0334-3256095', 72, '2021-05-16'),
(77, 'Lindsey Bridges', '0335-4271973', 76, '2021-06-11'),
(78, 'Myra Barber', '042-6364535', 58, '2021-09-26'),
(79, 'Josephine Jennings', '021-5871987', 55, '2021-12-22'),
(80, 'Domingo Rowe', '0300-7320225', 75, '2017-05-26'),
(81, 'Wilma Gonzalez', '051-2281378', 59, '2018-06-15'),
(82, 'Clarissa Fray', '0321-642828', 56, '2019-11-30'),
(83, 'Jace Wayland', '021-32075031', 71, '2021-11-15'),
(84, 'Finnick Odair', '0300-7569138', 61, '2020-08-02'),
(85, 'Katniss Everdeen', '0310-5152760', 85, '2021-09-05'),
(86, 'Peeta Mellark', '0310-5152760', 86, '2021-09-17'),
(87, 'Gale Hawthorn', '0333-6077553', 87, '2021-09-23'),
(91, 'Hafsa Tariq', '1234-789654', 105, '2021-12-29'),
(92, 'Khubaib', '7896-7896541', 109, '2021-12-29');

--
-- Triggers `empinfo`
--
DELIMITER $$
CREATE TRIGGER `setAddressID_emp` BEFORE INSERT ON `empinfo` FOR EACH ROW SET NEW.addressID = IFNULL(NEW.addressID, (SELECT MAX(addressID) FROM address))
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `setHireDate_emp` BEFORE INSERT ON `empinfo` FOR EACH ROW SET NEW.hireDate = IFNULL(NEW.hireDate, CURRENT_DATE())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `emppc`
--

CREATE TABLE `emppc` (
  `empID` int(10) NOT NULL,
  `productionCenterID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `emppc`
--

INSERT INTO `emppc` (`empID`, `productionCenterID`) VALUES
(61, 3),
(62, 2),
(63, 3),
(64, 2),
(65, 1),
(66, 1),
(67, 2),
(68, 1),
(69, 1),
(70, 3),
(71, 3),
(72, 1),
(73, 1),
(74, 2),
(75, 3),
(76, 3),
(77, 2),
(78, 3),
(79, 3),
(80, 2),
(81, 2),
(82, 3),
(83, 3),
(84, 1),
(85, 2),
(86, 1),
(87, 2);

-- --------------------------------------------------------

--
-- Table structure for table `empposition`
--

CREATE TABLE `empposition` (
  `empID` int(10) NOT NULL,
  `positionID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `empposition`
--

INSERT INTO `empposition` (`empID`, `positionID`) VALUES
(1, 3),
(2, 3),
(3, 3),
(4, 16),
(5, 16),
(6, 16),
(7, 16),
(8, 4),
(9, 5),
(10, 7),
(11, 9),
(12, 10),
(13, 13),
(14, 8),
(15, 8),
(16, 3),
(17, 3),
(18, 3),
(19, 16),
(20, 16),
(21, 16),
(22, 16),
(23, 4),
(24, 5),
(25, 7),
(26, 9),
(27, 10),
(28, 13),
(29, 8),
(30, 8),
(31, 3),
(32, 3),
(33, 3),
(34, 16),
(35, 16),
(36, 16),
(37, 16),
(38, 4),
(39, 5),
(40, 7),
(41, 9),
(42, 10),
(43, 13),
(44, 8),
(45, 8),
(46, 3),
(47, 3),
(48, 3),
(49, 16),
(50, 16),
(51, 16),
(52, 16),
(53, 4),
(54, 5),
(55, 7),
(56, 9),
(57, 10),
(58, 13),
(59, 8),
(60, 8),
(61, 16),
(62, 1),
(63, 2),
(64, 6),
(65, 15),
(66, 9),
(67, 10),
(68, 11),
(69, 14),
(70, 12),
(71, 1),
(72, 16),
(73, 15),
(74, 2),
(75, 6),
(76, 9),
(77, 11),
(78, 14),
(79, 10),
(80, 12),
(81, 2),
(82, 1),
(83, 16),
(84, 9),
(85, 15),
(86, 6),
(87, 10),
(33, 16),
(29, 16);

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `inventoryID` int(10) NOT NULL,
  `productionCenterID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`inventoryID`, `productionCenterID`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6);

-- --------------------------------------------------------

--
-- Table structure for table `inventoryproducts`
--

CREATE TABLE `inventoryproducts` (
  `inventoryID` int(10) DEFAULT NULL,
  `productID` int(10) NOT NULL,
  `quantity` int(5) NOT NULL,
  `manufactDate` date DEFAULT NULL,
  `expDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `inventoryproducts`
--

INSERT INTO `inventoryproducts` (`inventoryID`, `productID`, `quantity`, `manufactDate`, `expDate`) VALUES
(1, 4, 400, '2021-12-02', '2021-12-31'),
(1, 5, 500, '2021-12-02', '2021-12-31'),
(1, 6, 450, '2021-12-02', '2021-12-31'),
(1, 7, 220, '2021-12-02', '2021-12-31'),
(1, 8, 200, '2021-12-02', '2021-12-31'),
(1, 9, 200, '2021-12-02', '2021-12-31'),
(1, 10, 150, '2021-12-02', '2021-12-31'),
(1, 11, 450, '2021-12-02', '2021-12-31'),
(1, 12, 120, '2021-12-02', '2021-12-31'),
(1, 25, 420, '2021-12-02', '2021-12-31'),
(1, 26, 230, '2021-12-02', '2021-12-31'),
(1, 28, 150, '2021-11-05', '2022-01-31'),
(1, 29, 200, '2021-11-05', '2021-12-31'),
(1, 30, 127, '2021-11-05', '2021-12-31'),
(1, 31, 133, '2021-11-05', '2021-12-31'),
(1, 32, 125, '2021-11-05', '2021-12-31'),
(1, 33, 215, '2021-11-05', '2021-12-31'),
(1, 34, 250, '2021-11-05', '2021-12-31'),
(1, 35, 200, '2021-11-05', '2021-12-05'),
(1, 36, 300, '2021-11-05', '2021-12-31'),
(1, 37, 340, '2021-11-05', '2021-12-31'),
(1, 38, 120, '2021-12-09', '2022-01-01'),
(1, 39, 100, '2021-11-05', '2021-12-31'),
(1, 40, 320, '2021-11-05', '2021-12-31'),
(1, 41, 100, '2021-11-05', '2021-12-31'),
(1, 42, 450, '2021-11-05', '2021-12-31'),
(1, 43, 120, '2021-11-05', '2021-12-31'),
(1, 44, 120, '2021-11-05', '2021-12-31'),
(1, 45, 400, '2021-11-05', '2021-12-31'),
(1, 46, 120, '2021-11-05', '2021-12-31'),
(1, 47, 100, '2021-11-05', '2021-12-31'),
(1, 48, 60, '2021-11-05', '2021-12-31'),
(3, 72, 500, '2021-12-26', '2022-01-02');

--
-- Triggers `inventoryproducts`
--
DELIMITER $$
CREATE TRIGGER `addManufact_addExp_invpro` BEFORE INSERT ON `inventoryproducts` FOR EACH ROW SET NEW.manufactDate = IFNULL(NEW.manufactDate, date(NOW())) , NEW.expDate = IFNULL(NEW.expDate, DATE_ADD(date(NOW()), INTERVAL 7 DAY))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `location`
--

CREATE TABLE `location` (
  `locationID` int(10) NOT NULL,
  `area` varchar(30) NOT NULL,
  `city` varchar(30) NOT NULL,
  `zipCode` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `location`
--

INSERT INTO `location` (`locationID`, `area`, `city`, `zipCode`) VALUES
(1, 'I-14', 'Islamabad', 44000),
(2, 'DHA Phase 5', 'Lahore', 54792),
(3, 'Clifton', 'Karachi', 75600),
(4, 'Defense Colony', 'Peshawar', 25000),
(5, 'Westridge', 'Rawalpindi', 46060),
(6, 'Hitec City', 'Hyderabad', 71000),
(7, 'Stadium Road', 'Sheikhupura', 39350),
(8, 'Bahria Town', 'Islamabad', 44000);

-- --------------------------------------------------------

--
-- Table structure for table `manager`
--

CREATE TABLE `manager` (
  `managerID` int(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `contactNum` varchar(13) NOT NULL,
  `lengthOfService` varchar(10) NOT NULL,
  `salary` int(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `manager`
--

INSERT INTO `manager` (`managerID`, `name`, `contactNum`, `lengthOfService`, `salary`) VALUES
(1, 'Hafsa Tariq', '0300-5896555', '12', 123000),
(3, 'Zainab Anwaar', '0333-1111011', '4', 789955),
(4, 'Shelaz Hussain  ', '0333-4860486', '3', 8406000),
(5, 'Fatima', '0333-5099887', '0', 540000);

-- --------------------------------------------------------

--
-- Table structure for table `managerlogin`
--

CREATE TABLE `managerlogin` (
  `managerID` int(10) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `managerlogin`
--

INSERT INTO `managerlogin` (`managerID`, `username`, `password`) VALUES
(3, 'zainab.gr', 'stalker000'),
(4, 'syed.shelaz', 'krunkernoob2825'),
(1, 'hafsa.tariq', 'gpa4scrat'),
(5, 'fatimasyed', 'pass123');

-- --------------------------------------------------------

--
-- Stand-in structure for view `maxsales_view`
-- (See below for the actual view)
--
CREATE TABLE `maxsales_view` (
`productID` int(10)
,`sales` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `orderbranch`
--

CREATE TABLE `orderbranch` (
  `orderID` int(10) DEFAULT NULL,
  `branchID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `orderbranch`
--

INSERT INTO `orderbranch` (`orderID`, `branchID`) VALUES
(18, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `orderproducts`
--

CREATE TABLE `orderproducts` (
  `orderID` int(10) DEFAULT NULL,
  `productID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `orderproducts`
--

INSERT INTO `orderproducts` (`orderID`, `productID`) VALUES
(1, 25),
(2, 65),
(6, 5),
(6, 21),
(6, 25),
(6, 40),
(6, 63),
(7, 5),
(18, 45);

-- --------------------------------------------------------

--
-- Table structure for table `ordervehicle`
--

CREATE TABLE `ordervehicle` (
  `orderID` int(10) NOT NULL,
  `vehicleID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `ordervehicle`
--

INSERT INTO `ordervehicle` (`orderID`, `vehicleID`) VALUES
(1, 2),
(2, 12),
(3, 14),
(5, 8),
(6, 9);

-- --------------------------------------------------------

--
-- Table structure for table `position`
--

CREATE TABLE `position` (
  `positionID` int(10) NOT NULL,
  `posName` varchar(30) NOT NULL,
  `salary` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `position`
--

INSERT INTO `position` (`positionID`, `posName`, `salary`) VALUES
(1, 'Dough Maker', 1802400),
(2, 'Bakery Bench Hand', 1802900),
(3, 'Bakery Clerk', 1806000),
(4, 'Bakery Assistant', 1815000),
(5, 'Cashier', 1802400),
(6, 'Baker', 2051000),
(7, 'Stock Manager', 2171100),
(8, 'Kitchen Help', 1801900),
(9, 'Dishwasher', 673200),
(10, 'Bakery Janitor', 672600),
(11, 'Dessert Chef', 2523800),
(12, 'Cake Artist', 1950200),
(13, 'Cookie Icer', 1801000),
(14, 'Savoury Chef', 2347200),
(15, 'Inventory Manager', 2255100),
(16, 'Delivery Person', 771500);

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `productID` int(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `price` int(5) NOT NULL,
  `categoryID` int(10) NOT NULL,
  `image` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`productID`, `name`, `price`, `categoryID`, `image`) VALUES
(1, 'Butter Bread', 500, 1, NULL),
(2, 'Plain Bread', 500, 1, NULL),
(3, 'Garlic Bread', 600, 1, NULL),
(4, 'Croissant', 450, 1, NULL),
(5, 'Dinner Roll', 100, 1, NULL),
(6, 'Flat Bun', 200, 1, NULL),
(7, 'Cake Rusk', 570, 1, NULL),
(8, 'Fruit Cake Rusk', 620, 1, NULL),
(9, 'Fruit Sheermal', 680, 1, NULL),
(10, 'Plain Sheermal', 600, 1, NULL),
(11, 'Crispy Rusk', 520, 1, NULL),
(12, 'Milky Bread', 250, 1, NULL),
(13, 'Cranberry Cookies', 500, 2, NULL),
(14, 'Oatley Biscuits', 500, 2, NULL),
(15, 'Pistachio Biscotti', 620, 2, NULL),
(16, 'Chocolate Walnut', 750, 2, NULL),
(17, 'Jam Biscuit', 500, 2, NULL),
(18, 'Paraline', 400, 2, NULL),
(19, 'Zeera', 720, 2, NULL),
(20, 'Blackcurrant', 500, 2, NULL),
(21, 'ChocolateChip Cookies', 800, 2, NULL),
(25, 'Strawberry Cheesecake', 500, 3, 'images/Strawberry-Cheesecake.jpg'),
(26, 'Chocolate Raspberry Cake', 1000, 3, NULL),
(28, 'Honey Almond', 500, 3, NULL),
(29, 'Redvelvet', 1000, 3, NULL),
(30, 'Mud cake', 800, 3, NULL),
(31, 'Buttercream', 850, 3, NULL),
(32, 'Chocolate Fudge Cake', 820, 3, NULL),
(33, 'Mousse Cake', 1000, 3, NULL),
(34, 'Ice-cream cake', 870, 3, NULL),
(35, 'Lemon Walnut Cake', 1200, 3, NULL),
(36, 'Ginger Teacake', 400, 3, NULL),
(37, 'Chocolate Fudge Donut', 250, 4, NULL),
(38, 'Hazelnut Donut', 200, 4, NULL),
(39, 'Glazed Donut', 150, 4, NULL),
(40, 'Chocolate Filled Donut', 300, 4, NULL),
(41, 'Sugar icing Donut', 100, 4, NULL),
(42, 'Coconut Donut', 200, 4, NULL),
(43, 'Plain Donut', 100, 4, NULL),
(44, 'Chocolate Marble Donut', 200, 4, NULL),
(45, 'Oreo Donut', 300, 4, NULL),
(46, 'Vanilla Marble Donut', 270, 4, NULL),
(47, 'Chocolate Coconut Donut', 200, 4, NULL),
(48, 'Strawberry Icing Donut', 150, 4, NULL),
(61, 'Chicken Tikka ', 1500, 6, NULL),
(62, 'BBQ Chicken pizza', 1200, 6, NULL),
(63, 'Pepperoni Passion ', 1200, 6, NULL),
(64, 'Hawaiian pizza', 1200, 6, NULL),
(65, 'Classic Cheese Pizza', 1000, 6, NULL),
(66, 'Italian Thin pizza', 1299, 6, NULL),
(67, 'Crowncrust pizza', 1000, 6, NULL),
(68, 'Stuff Crust Pizza', 1100, 6, NULL),
(69, 'Sausage Pizza', 950, 6, NULL),
(70, 'Chicken Supreme pizza', 1000, 6, NULL),
(71, 'Loaded Cheese pizza', 1300, 6, NULL),
(72, 'Ambience special pizza', 1200, 6, NULL),
(73, 'Mulit-Grain Bread', 120, 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `productioncenter`
--

CREATE TABLE `productioncenter` (
  `productionCenterID` int(10) NOT NULL,
  `capacity` int(6) NOT NULL,
  `establishDate` date DEFAULT NULL,
  `locationID` int(10) NOT NULL,
  `adminID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `productioncenter`
--

INSERT INTO `productioncenter` (`productionCenterID`, `capacity`, `establishDate`, `locationID`, `adminID`) VALUES
(1, 10, '2002-12-25', 6, 3),
(2, 10, '2006-02-11', 5, 1),
(3, 10, '2008-08-06', 7, 2),
(4, 1000, '2021-12-26', 3, NULL),
(5, 8000, '2021-12-26', 6, NULL),
(6, 5000, '2021-12-26', 7, NULL);

--
-- Triggers `productioncenter`
--
DELIMITER $$
CREATE TRIGGER `autoDate_pc_bms` BEFORE INSERT ON `productioncenter` FOR EACH ROW SET NEW.establishDate = IFNULL(NEW.establishDate, date(NOW()))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `requests`
--

CREATE TABLE `requests` (
  `requestID` int(10) NOT NULL,
  `branchID` int(10) DEFAULT NULL,
  `productID` int(10) DEFAULT NULL,
  `quantity` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `requests`
--

INSERT INTO `requests` (`requestID`, `branchID`, `productID`, `quantity`) VALUES
(1, 2, 62, 100);

-- --------------------------------------------------------

--
-- Table structure for table `stockproducts`
--

CREATE TABLE `stockproducts` (
  `stockID` int(10) NOT NULL,
  `productID` int(10) NOT NULL,
  `quantity` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `stockproducts`
--

INSERT INTO `stockproducts` (`stockID`, `productID`, `quantity`) VALUES
(2, 1, 127),
(2, 2, 154),
(2, 3, 99),
(2, 4, 319),
(2, 5, 209),
(2, 6, 330),
(2, 7, 481),
(2, 9, 104),
(2, 10, 178),
(2, 11, 199),
(2, 12, 148),
(2, 13, 312),
(2, 14, 313),
(2, 15, 347),
(2, 16, 374),
(2, 17, 313),
(2, 18, 292),
(2, 19, 309),
(2, 20, 302);

--
-- Triggers `stockproducts`
--
DELIMITER $$
CREATE TRIGGER `sendStockRequest` AFTER UPDATE ON `stockproducts` FOR EACH ROW IF new.quantity < 50 THEN
INSERT INTO requests(branchID, productID, quantity)
VALUES(old.stockID, old.productID, 100);
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `vehicle`
--

CREATE TABLE `vehicle` (
  `vehicleID` int(10) NOT NULL,
  `vehicleName` varchar(30) NOT NULL,
  `empID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `vehicle`
--

INSERT INTO `vehicle` (`vehicleID`, `vehicleName`, `empID`) VALUES
(1, 'Nissan NV 1500', 78),
(2, 'Daihatsu Hijet Turbo Cruise', 79),
(3, 'FAW X-PV', 80),
(4, 'Nissan Clipper', 10),
(5, 'Honda Acty', 7),
(6, 'Nissan NV 2500', 15),
(8, 'Mazda Scrum', 18),
(9, 'Suzuki GS 150', 19),
(10, 'Daihatsu Hijet Turbo', 18),
(11, 'Nissan NV 1500', 29),
(12, 'Honda Pridor 2017', 31),
(13, 'Road Prince RP 70', 32),
(14, 'Honda CG 125', 33),
(15, 'Metro MR 70', 34),
(16, 'Yamaha YBR 125G', 40),
(27, 'Mitsubishi Minicab Bravo', 17),
(29, 'Honda City', 4);

-- --------------------------------------------------------

--
-- Structure for view `maxsales_view`
--
DROP TABLE IF EXISTS `maxsales_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `maxsales_view`  AS SELECT `orderproducts`.`productID` AS `productID`, count(0) AS `sales` FROM `orderproducts` GROUP BY `orderproducts`.`productID` HAVING count(0) = (select max(`orderproducts`.`sales`) from (select `orderproducts`.`productID` AS `productID`,count(0) AS `sales` from `orderproducts` group by `orderproducts`.`productID`) `orderproducts`) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `address`
--
ALTER TABLE `address`
  ADD PRIMARY KEY (`addressID`);

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`adminID`);

--
-- Indexes for table `adminlogin`
--
ALTER TABLE `adminlogin`
  ADD KEY `adminID_adlog_fk` (`adminID`);

--
-- Indexes for table `bakerystock`
--
ALTER TABLE `bakerystock`
  ADD PRIMARY KEY (`stockID`),
  ADD KEY `bID_branch_fk` (`branchID`);

--
-- Indexes for table `branch`
--
ALTER TABLE `branch`
  ADD PRIMARY KEY (`branchID`),
  ADD KEY `loc_branch_fk` (`locationID`),
  ADD KEY `manager_branch_fk` (`managerID`),
  ADD KEY `invID_branch_fk` (`inventoryID`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`categoryID`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`cusID`),
  ADD KEY `addID_customer_fk` (`addressID`);

--
-- Indexes for table `customerorder`
--
ALTER TABLE `customerorder`
  ADD PRIMARY KEY (`orderID`),
  ADD KEY `cid_order_fk` (`cusID`);

--
-- Indexes for table `empbranch`
--
ALTER TABLE `empbranch`
  ADD KEY `ebranch_ebranch_fk` (`branchID`),
  ADD KEY `eid_ebranch_fk` (`empID`);

--
-- Indexes for table `empinfo`
--
ALTER TABLE `empinfo`
  ADD PRIMARY KEY (`empID`),
  ADD KEY `add_empinfo_fk` (`addressID`);

--
-- Indexes for table `emppc`
--
ALTER TABLE `emppc`
  ADD KEY `eid_epc_fk` (`empID`),
  ADD KEY `pid_epc_fk` (`productionCenterID`);

--
-- Indexes for table `empposition`
--
ALTER TABLE `empposition`
  ADD KEY `posID_emppos_fk` (`positionID`),
  ADD KEY `eid_emppos_fk` (`empID`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`inventoryID`),
  ADD KEY `pcid_inventory_fk` (`productionCenterID`);

--
-- Indexes for table `inventoryproducts`
--
ALTER TABLE `inventoryproducts`
  ADD KEY `iid_invenprod_fk` (`inventoryID`),
  ADD KEY `pid_invenprod_fk` (`productID`);

--
-- Indexes for table `location`
--
ALTER TABLE `location`
  ADD PRIMARY KEY (`locationID`);

--
-- Indexes for table `manager`
--
ALTER TABLE `manager`
  ADD PRIMARY KEY (`managerID`);

--
-- Indexes for table `managerlogin`
--
ALTER TABLE `managerlogin`
  ADD KEY `mid_manlogin_fk` (`managerID`);

--
-- Indexes for table `orderbranch`
--
ALTER TABLE `orderbranch`
  ADD KEY `oid_obranch_fk` (`orderID`),
  ADD KEY `bid_obranch_fk` (`branchID`);

--
-- Indexes for table `orderproducts`
--
ALTER TABLE `orderproducts`
  ADD KEY `oid_oproduct_fk` (`orderID`),
  ADD KEY `pid_oproduct_fk` (`productID`);

--
-- Indexes for table `ordervehicle`
--
ALTER TABLE `ordervehicle`
  ADD KEY `oid_ovehicle_fk` (`orderID`),
  ADD KEY `vid_ovehicle_fk` (`vehicleID`);

--
-- Indexes for table `position`
--
ALTER TABLE `position`
  ADD PRIMARY KEY (`positionID`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`productID`),
  ADD KEY `catid_product_fk` (`categoryID`);

--
-- Indexes for table `productioncenter`
--
ALTER TABLE `productioncenter`
  ADD PRIMARY KEY (`productionCenterID`),
  ADD KEY `lid_pc_fk` (`locationID`),
  ADD KEY `aid_pc_fk` (`adminID`);

--
-- Indexes for table `requests`
--
ALTER TABLE `requests`
  ADD PRIMARY KEY (`requestID`),
  ADD KEY `bid_request_fk` (`branchID`),
  ADD KEY `pid_request_fk` (`productID`);

--
-- Indexes for table `stockproducts`
--
ALTER TABLE `stockproducts`
  ADD KEY `sid_sproduct_fk` (`stockID`),
  ADD KEY `pid_sproduct_fk` (`productID`);

--
-- Indexes for table `vehicle`
--
ALTER TABLE `vehicle`
  ADD PRIMARY KEY (`vehicleID`),
  ADD KEY `eid_vehicle_fk` (`empID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `address`
--
ALTER TABLE `address`
  MODIFY `addressID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `adminID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `bakerystock`
--
ALTER TABLE `bakerystock`
  MODIFY `stockID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `branch`
--
ALTER TABLE `branch`
  MODIFY `branchID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `categoryID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `cusID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `customerorder`
--
ALTER TABLE `customerorder`
  MODIFY `orderID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `empinfo`
--
ALTER TABLE `empinfo`
  MODIFY `empID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `inventoryID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `location`
--
ALTER TABLE `location`
  MODIFY `locationID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `manager`
--
ALTER TABLE `manager`
  MODIFY `managerID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `position`
--
ALTER TABLE `position`
  MODIFY `positionID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `productID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- AUTO_INCREMENT for table `productioncenter`
--
ALTER TABLE `productioncenter`
  MODIFY `productionCenterID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `requests`
--
ALTER TABLE `requests`
  MODIFY `requestID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `vehicle`
--
ALTER TABLE `vehicle`
  MODIFY `vehicleID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `adminlogin`
--
ALTER TABLE `adminlogin`
  ADD CONSTRAINT `adminID_adlog_fk` FOREIGN KEY (`adminID`) REFERENCES `admin` (`adminID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `bakerystock`
--
ALTER TABLE `bakerystock`
  ADD CONSTRAINT `bID_branch_fk` FOREIGN KEY (`branchID`) REFERENCES `branch` (`branchID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `branch`
--
ALTER TABLE `branch`
  ADD CONSTRAINT `invID_branch_fk` FOREIGN KEY (`inventoryID`) REFERENCES `inventory` (`inventoryID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `loc_branch_fk` FOREIGN KEY (`locationID`) REFERENCES `location` (`locationID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `manager_branch_fk` FOREIGN KEY (`managerID`) REFERENCES `manager` (`managerID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `addID_customer_fk` FOREIGN KEY (`addressID`) REFERENCES `address` (`addressID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `customerorder`
--
ALTER TABLE `customerorder`
  ADD CONSTRAINT `cid_order_fk` FOREIGN KEY (`cusID`) REFERENCES `customer` (`cusID`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `empbranch`
--
ALTER TABLE `empbranch`
  ADD CONSTRAINT `ebranch_ebranch_fk` FOREIGN KEY (`branchID`) REFERENCES `branch` (`branchID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eid_ebranch_fk` FOREIGN KEY (`empID`) REFERENCES `empinfo` (`empID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `empinfo`
--
ALTER TABLE `empinfo`
  ADD CONSTRAINT `add_empinfo_fk` FOREIGN KEY (`addressID`) REFERENCES `address` (`addressID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `emppc`
--
ALTER TABLE `emppc`
  ADD CONSTRAINT `eid_epc_fk` FOREIGN KEY (`empID`) REFERENCES `empinfo` (`empID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pid_epc_fk` FOREIGN KEY (`productionCenterID`) REFERENCES `productioncenter` (`productionCenterID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `empposition`
--
ALTER TABLE `empposition`
  ADD CONSTRAINT `eid_emppos_fk` FOREIGN KEY (`empID`) REFERENCES `empinfo` (`empID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `posID_emppos_fk` FOREIGN KEY (`positionID`) REFERENCES `position` (`positionID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `pcid_inventory_fk` FOREIGN KEY (`productionCenterID`) REFERENCES `productioncenter` (`productionCenterID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `inventoryproducts`
--
ALTER TABLE `inventoryproducts`
  ADD CONSTRAINT `iid_invenprod_fk` FOREIGN KEY (`inventoryID`) REFERENCES `inventory` (`inventoryID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pid_invenprod_fk` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `managerlogin`
--
ALTER TABLE `managerlogin`
  ADD CONSTRAINT `mid_manlogin_fk` FOREIGN KEY (`managerID`) REFERENCES `manager` (`managerID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `orderbranch`
--
ALTER TABLE `orderbranch`
  ADD CONSTRAINT `bid_obranch_fk` FOREIGN KEY (`branchID`) REFERENCES `branch` (`branchID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `oid_obranch_fk` FOREIGN KEY (`orderID`) REFERENCES `customerorder` (`orderID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `orderproducts`
--
ALTER TABLE `orderproducts`
  ADD CONSTRAINT `oid_oproduct_fk` FOREIGN KEY (`orderID`) REFERENCES `customerorder` (`orderID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pid_oproduct_fk` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ordervehicle`
--
ALTER TABLE `ordervehicle`
  ADD CONSTRAINT `oid_ovehicle_fk` FOREIGN KEY (`orderID`) REFERENCES `customerorder` (`orderID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `vid_ovehicle_fk` FOREIGN KEY (`vehicleID`) REFERENCES `vehicle` (`vehicleID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `catid_product_fk` FOREIGN KEY (`categoryID`) REFERENCES `category` (`categoryID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `productioncenter`
--
ALTER TABLE `productioncenter`
  ADD CONSTRAINT `aid_pc_fk` FOREIGN KEY (`adminID`) REFERENCES `admin` (`adminID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `lid_pc_fk` FOREIGN KEY (`locationID`) REFERENCES `location` (`locationID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `requests`
--
ALTER TABLE `requests`
  ADD CONSTRAINT `bid_request_fk` FOREIGN KEY (`branchID`) REFERENCES `branch` (`branchID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pid_request_fk` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `stockproducts`
--
ALTER TABLE `stockproducts`
  ADD CONSTRAINT `pid_sproduct_fk` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sid_sproduct_fk` FOREIGN KEY (`stockID`) REFERENCES `bakerystock` (`stockID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `vehicle`
--
ALTER TABLE `vehicle`
  ADD CONSTRAINT `eid_vehicle_fk` FOREIGN KEY (`empID`) REFERENCES `empinfo` (`empID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
