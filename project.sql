-- phpMyAdmin SQL Dump
-- version 4.8.0.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 20, 2019 at 02:39 PM
-- Server version: 5.7.22
-- PHP Version: 7.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `project`
--

-- --------------------------------------------------------

--
-- Stand-in structure for view `bestsellers`
-- (See below for the actual view)
--
CREATE TABLE `bestsellers` (
`shopID` int(11)
,`productID` int(11)
,`amount` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `courier`
--

CREATE TABLE `courier` (
  `ID` int(11) NOT NULL,
  `firstName` text NOT NULL,
  `lastName` text NOT NULL,
  `tel` text NOT NULL,
  `status` text NOT NULL,
  `credit` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `courier`
--

INSERT INTO `courier` (`ID`, `firstName`, `lastName`, `tel`, `status`, `credit`) VALUES
(1, 'reza', 'yosefi', '0912-1111', 'busy', 0),
(2, 'sadegh', 'sadeghi', '0912-2222', 'busy', 0),
(3, 'sahar', 'kashefi', '0912-3333', 'busy', 22),
(4, 'nima', 'karimi', '0912-4444', 'busy', 0);

-- --------------------------------------------------------

--
-- Table structure for table `courier_status_log`
--

CREATE TABLE `courier_status_log` (
  `courierID` int(11) NOT NULL,
  `new_status` text NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `courier_status_log`
--

INSERT INTO `courier_status_log` (`courierID`, `new_status`, `time`) VALUES
(3, 'busy', '2019-01-19 21:49:47'),
(3, 'free', '2019-01-19 21:53:00'),
(1, 'busy', '2019-01-19 22:01:16'),
(3, 'busy', '2019-01-19 22:07:38'),
(2, 'busy', '2019-01-19 23:22:28'),
(4, 'busy', '2019-01-19 23:23:23');

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `userID` int(11) NOT NULL,
  `pass` text NOT NULL,
  `email` text NOT NULL,
  `firstName` text NOT NULL,
  `lastName` text NOT NULL,
  `zipCode` int(11) NOT NULL,
  `sex` varchar(10) NOT NULL,
  `credit` int(11) NOT NULL DEFAULT '0',
  `tel` text NOT NULL,
  `address` varchar(20) NOT NULL,
  `pass_hash` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`userID`, `pass`, `email`, `firstName`, `lastName`, `zipCode`, `sex`, `credit`, `tel`, `address`, `pass_hash`) VALUES
(1, '123', 'n.a@gmail.com', 'nazanin', 'akhtarian', 111, 'female', 100, '0912-111', 'tehran1', '*23AE809DDACAF96AF0FD78ED04B6A265E05AA257'),
(2, '321', 'bb@gmail.com', 'babak', 'babaie', 222, 'male', 10, '0912-222', 'tehran2', '*7297C3E22DEB91303FC493303A8158AD4231F486'),
(3, '345', 'saheli@gmail.com', 'sahel', 'nori', 333, 'female', 0, '0912-333', 'tehran3', '*68484737735FFCDEEB048B050540FAAF3C26EB4B');

--
-- Triggers `customer`
--
DELIMITER $$
CREATE TRIGGER `customer_after_insert` AFTER INSERT ON `customer` FOR EACH ROW BEGIN
insert into customer_address values(new.userID, new.address);
insert into customer_tel values(new.userID, new.tel);
insert into customer_credit values(new.userID, new.pass, new.credit);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `customer_before_insert` BEFORE INSERT ON `customer` FOR EACH ROW BEGIN
set new.pass_hash := password(new.pass);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_info` BEFORE UPDATE ON `customer` FOR EACH ROW BEGIN
declare pass_hold text;
declare id_hold integer;
if (NEW.pass IS NULL or new.pass = '') then
signal sqlstate '45000'
set message_text = 'enter your user and pass';

elseif (NEW.userID IS NULL or new.userID = '') then
signal sqlstate '45000'
set message_text = 'enter your user and pass';
end if;

set id_hold := (select count(*) from customer where new.userID = userID);
if (id_hold <> 0) THEN
set pass_hold := (select pass from customer
                  where new.userID = userID);
                  
if (pass_hold <> new.pass) THEN
signal sqlstate '45000'
set message_text = 'password wrong';
end if;                  

ELSE
signal sqlstate '45000'
set message_text = 'username wrong';
end if;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer_address`
--

CREATE TABLE `customer_address` (
  `userID` int(11) NOT NULL,
  `address` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `customer_address`
--

INSERT INTO `customer_address` (`userID`, `address`) VALUES
(1, 'tehran1'),
(2, 'tehran2'),
(3, 'tehran3');

-- --------------------------------------------------------

--
-- Table structure for table `customer_credit`
--

CREATE TABLE `customer_credit` (
  `userID` int(11) NOT NULL,
  `pass` text NOT NULL,
  `credit` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `customer_credit`
--

INSERT INTO `customer_credit` (`userID`, `pass`, `credit`) VALUES
(1, '123', 50),
(2, '321', 0),
(3, '345', 0);

--
-- Triggers `customer_credit`
--
DELIMITER $$
CREATE TRIGGER `credit_increment` BEFORE UPDATE ON `customer_credit` FOR EACH ROW BEGIN
declare pass_hold text;
declare id_hold integer;
set id_hold := (select count(*) from customer_credit
                where new.userID = userID);
if (id_hold <> 0) THEN
set pass_hold := (select pass from customer
                  where new.userID = userID);
                  
if (pass_hold <> new.pass) THEN
signal sqlstate '45000'
set message_text = 'password wrong';
ELSE
update customer set credit = new.credit where userID = new.userID;
end if;                  

ELSE
signal sqlstate '45000'
set message_text = 'username wrong';
end if;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer_order`
--

CREATE TABLE `customer_order` (
  `ID` int(11) NOT NULL,
  `shopID` int(11) NOT NULL,
  `customerID` int(11) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'submitted',
  `paymentType` text NOT NULL,
  `orderDate` date NOT NULL,
  `deliveryAddress` varchar(20) NOT NULL,
  `productID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `customer_order`
--

INSERT INTO `customer_order` (`ID`, `shopID`, `customerID`, `status`, `paymentType`, `orderDate`, `deliveryAddress`, `productID`) VALUES
(1, 1, 1, 'completed', 'bank', '2019-01-01', 'tehran1', 5),
(2, 1, 2, 'denied', 'bank', '2019-01-03', 'tehran4', 5),
(3, 3, 5, 'denied', 'bank', '2019-01-02', 'vanak', 2),
(4, 3, 1, 'posted', 'bank', '2019-01-02', 'tehran1', 2),
(5, 4, 2, 'denied', 'credit', '2019-01-09', 'tehran2', 2),
(6, 4, 4, 'posted', 'bank', '2019-01-02', 'tehran7', 2),
(7, 1, 1, 'posted', '', '2019-01-01', 'tehran1', 7),
(8, 1, 1, 'denied', '', '2019-01-01', 'tehran3', 7),
(9, 1, 2, 'posted', '', '2019-01-01', 'tehran2', 7),
(10, 1, 3, 'denied', 'bank', '2019-01-03', 'tehran3', 7),
(11, 1, 3, 'denied', 'bank', '2019-01-03', 'tehran5', 7),
(12, 4, 3, 'denied', 'bank', '2019-01-03', 'tehran3', 2),
(13, 4, 2, 'denied', 'bank', '2019-01-03', 'tehran2', 2),
(14, 3, 1, 'denied', 'bank', '2019-01-04', 'tehran1', 9),
(15, 3, 1, 'denied', 'bank', '2019-01-04', 'tehran1', 8),
(16, 3, 2, 'denied', 'bank', '2019-01-04', 'tehran2', 8),
(17, 3, 3, 'denied', 'bank', '2019-01-04', 'tehran3', 8),
(18, 2, 3, 'denied', 'bank', '2019-01-04', 'tehran3', 4),
(19, 2, 1, 'denied', 'bank', '2019-01-04', 'tehran1', 4),
(20, 2, 6, 'denied', 'bank', '2019-01-04', 'tehran6', 10),
(21, 2, 7, 'denied', 'bank', '2019-01-04', 'tehran6', 10),
(22, 2, 7, 'denied', 'bank', '2019-01-04', 'tehran', 4),
(23, 2, 8, 'denied', 'bank', '2019-01-02', 'tehran9', 3),
(24, 1, 2, 'denied', 'bank', '2019-01-05', 'tehran2', 6),
(25, 4, 6, 'denied', 'bank', '2019-01-01', 'tehran5', 2);

--
-- Triggers `customer_order`
--
DELIMITER $$
CREATE TRIGGER `completed` AFTER UPDATE ON `customer_order` FOR EACH ROW BEGIN

declare id_hold integer;
declare price_hold integer;
if (old.status = 'posted') then
select courierID into id_hold
from order_courier
where new.ID = orderID;

update courier set courier.status = 'free'
where courier.ID = id_hold;

insert into courier_status_log values(id_hold, 'free', now());

select price into price_hold
from product
where new.productID = product.ID;

update courier set credit = credit + 1.05 * price_hold
where courier.ID = id_hold;
insert into order_status_log values(new.ID,'posted','completed',now());
end if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `customer_request` BEFORE INSERT ON `customer_order` FOR EACH ROW BEGIN

declare flag integer;
declare flag2 integer;
declare opensAt integer;
declare closesAt integer;
declare current_t integer;
declare flag3 integer;
declare a integer;
declare free_c integer;
DECLARE id_hold integer;
declare price_holder integer;
declare c_credit integer;

set c_credit := (select credit
                       	from customer_credit
                        where userID = new.customerID);
                        
set price_holder := (select price
                     from product
                     where ID = new.productID);

set free_c := (SELECT COUNT(*)
from shop_courier, courier
where courier.ID = shop_courier.courierID AND
shop_courier.shopID = new.shopID AND
courier.status = 'free');

set a := (select amount
from product_amount
where productID = new.productID and shopID = new.shopID);

set flag := (SELECT count(*)
FROM customer_address
WHERE userID = NEW.customerID);

set flag2 := (SELECT count(*)
FROM customer_address
WHERE address = NEW.deliveryAddress and userID = NEW.customerID);

set opensAt := (select openAt from shop WHERE shop.ID = new.shopID);

set closesAt := (select closeAt from shop WHERE shop.ID = new.shopID);

set current_t := (select hour(CURRENT_TIME));

insert into checking values(opensAt, closesAt, current_t);

set flag3 := (SELECT count(*)
FROM customer_address
WHERE userID = NEW.customerID);

IF (current_t >= closesAt or current_t <= opensAt) THEN
set new.status = 'denied';
INSERT INTO orderdenied VALUES(new.customerID, new.ID, 'time');

elseif (flag3 = 0 and new.paymentType <> 'bank') THEN
set new.status = 'denied';
insert into orderdenied values(new.customerID, new.ID, 'wrong payment type');

elseif (flag <> 0 and flag2 = 0) THEN
set new.status = 'denied';
insert into orderdenied values(new.customerID, new.ID, 'wrong address');

elseif (a = 0) THEN
set new.status = 'denied';
INSERT INTO orderdenied VALUES(new.customerID, new.ID, 'no product');

ELSEIF (free_c = 0) then
set new.status = 'denied';
INSERT INTO orderdenied VALUES(new.customerID, new.ID, 'no courier');

elseif (new.paymentType = 'credit' and c_credit < price_holder) then
set new.status = 'denied';
INSERT INTO orderdenied VALUES(new.customerID, new.ID, 'credit not enough');

ELSE
set new.status = 'posted';
insert into order_status_log values(new.ID, 'submitted', 'posted' ,now());
update product_amount set amount = amount - 1
where productID = new.productID and shopID = new.shopID;
insert into product_log values(new.productID,new.shopID,a,a-1,now());
set id_hold := (select courierID
from shop_courier, courier
where courier.ID = courierID AND
shop_courier.shopID = new.shopID AND
courier.status = 'free'
limit 1);

update courier set courier.status = 'busy'
where courier.ID = id_hold;
insert into courier_status_log values(id_hold, 'busy', now());
insert into order_courier values(new.ID, id_hold);
end if;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer_tel`
--

CREATE TABLE `customer_tel` (
  `userID` int(11) NOT NULL,
  `tel` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `customer_tel`
--

INSERT INTO `customer_tel` (`userID`, `tel`) VALUES
(1, '0912-111'),
(2, '0912-222'),
(3, '0912-333');

-- --------------------------------------------------------

--
-- Stand-in structure for view `dif`
-- (See below for the actual view)
--
CREATE TABLE `dif` (
`avg_price` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `free_couriers`
-- (See below for the actual view)
--
CREATE TABLE `free_couriers` (
`courierID` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `new_customers`
-- (See below for the actual view)
--
CREATE TABLE `new_customers` (
`customerID` int(11)
,`price` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `old_customers`
-- (See below for the actual view)
--
CREATE TABLE `old_customers` (
`customerID` int(11)
,`price` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `operator`
--

CREATE TABLE `operator` (
  `ID` int(11) NOT NULL,
  `firstName` text NOT NULL,
  `lastName` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `operator`
--

INSERT INTO `operator` (`ID`, `firstName`, `lastName`) VALUES
(1, 'nazanin', 'akhtarian'),
(2, 'yasamin', 'molavi');

-- --------------------------------------------------------

--
-- Table structure for table `orderdenied`
--

CREATE TABLE `orderdenied` (
  `customerID` int(11) NOT NULL,
  `orderID` int(11) NOT NULL,
  `reason` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `orderdenied`
--

INSERT INTO `orderdenied` (`customerID`, `orderID`, `reason`) VALUES
(2, 2, 'wrong address'),
(5, 3, 'no courier'),
(2, 5, 'credit not enough'),
(1, 8, 'wrong address'),
(3, 10, 'no courier'),
(3, 11, 'wrong address'),
(3, 12, 'no courier'),
(2, 13, 'no courier'),
(1, 14, 'no courier'),
(1, 15, 'no courier'),
(2, 16, 'no courier'),
(3, 17, 'no courier'),
(3, 18, 'no courier'),
(1, 19, 'no courier'),
(6, 20, 'no courier'),
(7, 21, 'no courier'),
(7, 22, 'no courier'),
(8, 23, 'no courier'),
(2, 24, 'no courier'),
(6, 25, 'time');

-- --------------------------------------------------------

--
-- Table structure for table `order_courier`
--

CREATE TABLE `order_courier` (
  `orderID` int(11) NOT NULL,
  `courierID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `order_courier`
--

INSERT INTO `order_courier` (`orderID`, `courierID`) VALUES
(4, 1),
(6, 3),
(7, 2),
(9, 4);

-- --------------------------------------------------------

--
-- Table structure for table `order_status_log`
--

CREATE TABLE `order_status_log` (
  `orderID` int(11) NOT NULL,
  `preStatus` text NOT NULL,
  `nextStatus` text NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `order_status_log`
--

INSERT INTO `order_status_log` (`orderID`, `preStatus`, `nextStatus`, `time`) VALUES
(1, 'submitted', 'posted', '2019-01-19 21:49:47'),
(1, 'posted', 'completed', '2019-01-19 21:53:00'),
(4, 'submitted', 'posted', '2019-01-19 22:01:16'),
(6, 'submitted', 'posted', '2019-01-19 22:07:38'),
(7, 'submitted', 'posted', '2019-01-19 23:22:28'),
(9, 'submitted', 'posted', '2019-01-19 23:23:23');

-- --------------------------------------------------------

--
-- Stand-in structure for view `organized_bestsellers`
-- (See below for the actual view)
--
CREATE TABLE `organized_bestsellers` (
`shopID` int(11)
,`productID` int(11)
,`amount` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `ID` int(11) NOT NULL,
  `title` text NOT NULL,
  `shopID` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `discount` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`ID`, `title`, `shopID`, `price`, `discount`) VALUES
(1, 'shoe', 3, 200, 0),
(2, 'bag', 3, 100, 0),
(3, 'mobile', 1, 1000, 0),
(4, 'tv', 1, 2000, 0),
(5, 'book', 2, 10, 0),
(6, 'notebook', 2, 20, 0),
(7, 'pen', 2, 5, 0),
(8, 'pants', 3, 100, 0),
(9, 'sneaker', 3, 150, 0),
(10, 'laptop', 1, 1500, 0),
(11, 'eraser', 2, 5, 0);

-- --------------------------------------------------------

--
-- Table structure for table `product_amount`
--

CREATE TABLE `product_amount` (
  `shopID` int(11) NOT NULL,
  `productID` int(11) NOT NULL,
  `amount` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product_amount`
--

INSERT INTO `product_amount` (`shopID`, `productID`, `amount`) VALUES
(1, 5, 4),
(1, 6, 4),
(1, 7, 5),
(1, 11, 2),
(2, 3, 7),
(2, 4, 8),
(2, 10, 4),
(3, 1, 2),
(3, 2, 1),
(3, 8, 3),
(3, 9, 4),
(4, 1, 3),
(4, 2, 2);

-- --------------------------------------------------------

--
-- Table structure for table `product_log`
--

CREATE TABLE `product_log` (
  `shopID` int(11) NOT NULL,
  `productID` int(11) NOT NULL,
  `preAmount` int(11) DEFAULT NULL,
  `nextAmount` int(11) DEFAULT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product_log`
--

INSERT INTO `product_log` (`shopID`, `productID`, `preAmount`, `nextAmount`, `time`) VALUES
(5, 1, 5, 4, '2019-01-19 21:49:47'),
(2, 3, 2, 1, '2019-01-19 22:01:16'),
(2, 4, 3, 2, '2019-01-19 22:07:38'),
(7, 1, 7, 6, '2019-01-19 23:22:28'),
(7, 1, 6, 5, '2019-01-19 23:23:23');

-- --------------------------------------------------------

--
-- Table structure for table `shop`
--

CREATE TABLE `shop` (
  `ID` int(11) NOT NULL,
  `title` text NOT NULL,
  `city` text NOT NULL,
  `address` varchar(20) NOT NULL,
  `tel` text NOT NULL,
  `manager` text NOT NULL,
  `openAt` int(11) NOT NULL,
  `closeAt` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `shop`
--

INSERT INTO `shop` (`ID`, `title`, `city`, `address`, `tel`, `manager`, `openAt`, `closeAt`) VALUES
(1, 'pasdaran', 'tehran', 'tehran1', '0912-1', 'yosefi', 9, 19),
(2, 'saadat-abad', 'tehran', 'tehran2', '0912-2', 'razavi', 8, 13),
(3, 'niavaran', 'tehran', 'tehran3', '0912-3', 'salehi', 7, 14),
(4, 'vanak', 'tehran', 'tehran44', '0912-444', 'abasi', 14, 18);

-- --------------------------------------------------------

--
-- Table structure for table `shop_courier`
--

CREATE TABLE `shop_courier` (
  `shopID` int(11) NOT NULL,
  `courierID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `shop_courier`
--

INSERT INTO `shop_courier` (`shopID`, `courierID`) VALUES
(3, 1),
(1, 2),
(2, 2),
(3, 2),
(1, 3),
(2, 3),
(4, 3),
(1, 4),
(3, 4);

-- --------------------------------------------------------

--
-- Table structure for table `shop_operator`
--

CREATE TABLE `shop_operator` (
  `shopID` int(11) NOT NULL,
  `opID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `shop_operator`
--

INSERT INTO `shop_operator` (`shopID`, `opID`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(1, 2),
(2, 2),
(3, 2);

-- --------------------------------------------------------

--
-- Table structure for table `shop_supplier`
--

CREATE TABLE `shop_supplier` (
  `shopID` int(11) NOT NULL,
  `supplierID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `shop_supplier`
--

INSERT INTO `shop_supplier` (`shopID`, `supplierID`) VALUES
(2, 1),
(3, 1),
(3, 2),
(1, 3),
(2, 4),
(3, 4),
(1, 5),
(4, 5);

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `ID` int(11) NOT NULL,
  `firstName` text NOT NULL,
  `lastName` text NOT NULL,
  `tel` text NOT NULL,
  `address` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`ID`, `firstName`, `lastName`, `tel`, `address`) VALUES
(1, 'ali', 'alavi', '912-111', 'tehran111'),
(2, 'sara', 'sabaie', '912-222', 'tehran222'),
(3, 'hasan', 'gholami', '0912-333', 'tehran333'),
(4, 'mahsa', 'hoseini', '0912-444', 'tehran444'),
(5, 'akbar', 'asghari', '0912-555', 'tehran555');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v`
-- (See below for the actual view)
--
CREATE TABLE `v` (
`shopID` int(11)
,`difference` bigint(12)
);

-- --------------------------------------------------------

--
-- Structure for view `bestsellers`
--
DROP TABLE IF EXISTS `bestsellers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bestsellers`  AS  select `customer_order`.`shopID` AS `shopID`,`customer_order`.`productID` AS `productID`,count(0) AS `amount` from `customer_order` group by `customer_order`.`shopID`,`customer_order`.`productID` ;

-- --------------------------------------------------------

--
-- Structure for view `dif`
--
DROP TABLE IF EXISTS `dif`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dif`  AS  (select avg(`old_customers`.`price`) AS `avg_price` from `old_customers`) union (select avg(`new_customers`.`price`) AS `AVG(price)` from `new_customers`) ;

-- --------------------------------------------------------

--
-- Structure for view `free_couriers`
--
DROP TABLE IF EXISTS `free_couriers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `free_couriers`  AS  select `shop_courier`.`courierID` AS `courierID` from (`shop_courier` join `courier`) where ((`courier`.`ID` = `shop_courier`.`courierID`) and (`courier`.`status` = 'free')) ;

-- --------------------------------------------------------

--
-- Structure for view `new_customers`
--
DROP TABLE IF EXISTS `new_customers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `new_customers`  AS  select `customer_order`.`customerID` AS `customerID`,`product`.`price` AS `price` from (`customer_order` join `product`) where ((`customer_order`.`status` <> 'denied') and (`customer_order`.`productID` = `product`.`ID`) and `customer_order`.`customerID` in (select `customer`.`userID` from `customer`)) ;

-- --------------------------------------------------------

--
-- Structure for view `old_customers`
--
DROP TABLE IF EXISTS `old_customers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `old_customers`  AS  select `customer_order`.`customerID` AS `customerID`,`product`.`price` AS `price` from (`customer_order` join `product`) where ((`customer_order`.`status` <> 'denied') and (`customer_order`.`productID` = `product`.`ID`) and (not(`customer_order`.`customerID` in (select `customer`.`userID` from `customer`)))) ;

-- --------------------------------------------------------

--
-- Structure for view `organized_bestsellers`
--
DROP TABLE IF EXISTS `organized_bestsellers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `organized_bestsellers`  AS  select `bestsellers`.`shopID` AS `shopID`,`bestsellers`.`productID` AS `productID`,`bestsellers`.`amount` AS `amount` from `bestsellers` order by `bestsellers`.`shopID`,`bestsellers`.`amount` desc ;

-- --------------------------------------------------------

--
-- Structure for view `v`
--
DROP TABLE IF EXISTS `v`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v`  AS  select `shop`.`ID` AS `shopID`,(`shop`.`closeAt` - `shop`.`openAt`) AS `difference` from `shop` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `courier`
--
ALTER TABLE `courier`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`userID`);

--
-- Indexes for table `customer_address`
--
ALTER TABLE `customer_address`
  ADD PRIMARY KEY (`userID`,`address`);

--
-- Indexes for table `customer_credit`
--
ALTER TABLE `customer_credit`
  ADD PRIMARY KEY (`userID`);

--
-- Indexes for table `customer_order`
--
ALTER TABLE `customer_order`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `shopID` (`shopID`),
  ADD KEY `productID` (`productID`,`shopID`);

--
-- Indexes for table `customer_tel`
--
ALTER TABLE `customer_tel`
  ADD PRIMARY KEY (`userID`,`tel`);

--
-- Indexes for table `operator`
--
ALTER TABLE `operator`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `product_fk1` (`shopID`);

--
-- Indexes for table `product_amount`
--
ALTER TABLE `product_amount`
  ADD PRIMARY KEY (`shopID`,`productID`),
  ADD KEY `productID` (`productID`);

--
-- Indexes for table `shop`
--
ALTER TABLE `shop`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `shop_courier`
--
ALTER TABLE `shop_courier`
  ADD PRIMARY KEY (`shopID`,`courierID`),
  ADD KEY `courierID` (`courierID`);

--
-- Indexes for table `shop_operator`
--
ALTER TABLE `shop_operator`
  ADD PRIMARY KEY (`shopID`,`opID`),
  ADD KEY `opID` (`opID`);

--
-- Indexes for table `shop_supplier`
--
ALTER TABLE `shop_supplier`
  ADD PRIMARY KEY (`shopID`,`supplierID`),
  ADD KEY `fk2` (`supplierID`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`ID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `customer_address`
--
ALTER TABLE `customer_address`
  ADD CONSTRAINT `c_add_fk1` FOREIGN KEY (`userID`) REFERENCES `customer` (`userID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `customer_credit`
--
ALTER TABLE `customer_credit`
  ADD CONSTRAINT `customer_credit_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `customer` (`userID`);

--
-- Constraints for table `customer_order`
--
ALTER TABLE `customer_order`
  ADD CONSTRAINT `customer_order_ibfk_1` FOREIGN KEY (`shopID`) REFERENCES `shop` (`ID`),
  ADD CONSTRAINT `customer_order_ibfk_2` FOREIGN KEY (`productID`) REFERENCES `product` (`ID`),
  ADD CONSTRAINT `customer_order_ibfk_3` FOREIGN KEY (`productID`,`shopID`) REFERENCES `product_amount` (`productID`, `shopID`);

--
-- Constraints for table `customer_tel`
--
ALTER TABLE `customer_tel`
  ADD CONSTRAINT `c_tel_fk1` FOREIGN KEY (`userID`) REFERENCES `customer` (`userID`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_fk1` FOREIGN KEY (`shopID`) REFERENCES `shop` (`ID`);

--
-- Constraints for table `product_amount`
--
ALTER TABLE `product_amount`
  ADD CONSTRAINT `product_amount_ibfk_1` FOREIGN KEY (`productID`) REFERENCES `product` (`ID`),
  ADD CONSTRAINT `product_amount_ibfk_2` FOREIGN KEY (`shopID`) REFERENCES `shop` (`ID`);

--
-- Constraints for table `shop_courier`
--
ALTER TABLE `shop_courier`
  ADD CONSTRAINT `shop_courier_ibfk_1` FOREIGN KEY (`courierID`) REFERENCES `courier` (`ID`),
  ADD CONSTRAINT `shop_courier_ibfk_2` FOREIGN KEY (`shopID`) REFERENCES `shop` (`ID`);

--
-- Constraints for table `shop_operator`
--
ALTER TABLE `shop_operator`
  ADD CONSTRAINT `shop_operator_ibfk_1` FOREIGN KEY (`opID`) REFERENCES `operator` (`ID`),
  ADD CONSTRAINT `shop_operator_ibfk_2` FOREIGN KEY (`shopID`) REFERENCES `shop` (`ID`);

--
-- Constraints for table `shop_supplier`
--
ALTER TABLE `shop_supplier`
  ADD CONSTRAINT `fk1` FOREIGN KEY (`shopID`) REFERENCES `shop` (`ID`),
  ADD CONSTRAINT `fk2` FOREIGN KEY (`supplierID`) REFERENCES `supplier` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
