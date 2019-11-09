CREATE DATABASE Trendyol
GO
USE Trendyol
GO
CREATE TABLE City(
	CityID tinyint PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(20) NOT NULL
)
GO

CREATE TABLE Region(
	RegionID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(25) NOT NULL
 )
 GO

 CREATE TABLE [ADDRESS](
AddressID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
FirstName nvarchar(50) NOT NULL,
LastName nvarchar(50) NOT NULL,
Phone nvarchar(15) NOT NULL,
CityID tinyint FOREIGN KEY(CityID) REFERENCES City (CityID) NOT NULL,
RegionID int FOREIGN KEY(RegionID) REFERENCES Region (RegionID) NOT NULL,
AddressDescription nvarchar(max) NOT NULL,
AddressName nvarchar(50) NOT NULL
)
GO

CREATE TABLE Gender(
	GenderID tinyint PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] char(1) NOT NULL,
  CONSTRAINT CK_GenderName CHECK ([Name]='E' OR [Name]='K')
)
GO

CREATE TABLE Color(
	ColorID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(30) NOT NULL
)
GO


CREATE TABLE ShoesSize(
	ShoesSizeID tinyint PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] tinyint NOT NULL
)
Go

CREATE TABLE Size(
	SizeID tinyint PRIMARY KEY  IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(5) NOT NULL
)
GO

CREATE TABLE Shipper(
	ShippersID tinyint PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(50) NOT NULL,
	Phone nvarchar(15) NOT NULL
)
GO

CREATE TABLE Trademark(
	TrademarkID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(50) Unique NOT NULL,
	SalesDepartmantPhone nvarchar(15) NOT NULL,
	Distributor nvarchar(100) NOT NULL,
	DistributorCityID tinyint FOREIGN KEY(DistributorCityID) REFERENCES City (CityID) NOT NULL
)
GO

CREATE TABLE UserLogin(
	UserID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Email nvarchar(100) UNIQUE NOT NULL,
	[Password] nvarchar(50) NOT NULL,
	GenderID tinyint FOREIGN KEY(GenderID) REFERENCES Gender (GenderID) NOT NULL
)
GO

CREATE TABLE AccountInfo(
	AccountID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	FirstName nvarchar(50) NOT NULL,
	LastName nvarchar(50) NOT NULL,
	Phone nvarchar(15) NULL,
	IdentityNo nvarchar(20) UNIQUE NULL,
	AddressID int FOREIGN KEY(AddressID) REFERENCES [Address] (AddressID) NOT NULL,
	BirthDate date NOT NULL,
	UserID int FOREIGN KEY(UserID) REFERENCES UserLogin (UserID) NOT NULL,
	CONSTRAINT CK_BirthDate CHECK (BirthDate<=dateadd(year,(-10),getdate()))
)
GO

CREATE TABLE Category(
	CategoryID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(25) NOT NULL,
	ParentCategoryID int FOREIGN KEY(ParentCategoryID) REFERENCES Category (CategoryID) NULL
)
GO

CREATE TABLE CategoryTrademark(
	CategoryID int FOREIGN KEY(CategoryID) REFERENCES Category (CategoryID) NOT NULL,
	TrademarkID int FOREIGN KEY(TrademarkID) REFERENCES Trademark (TrademarkID) NOT NULL
)
GO

CREATE TABLE CityRegion(
	CityID tinyint FOREIGN KEY (CityID) REFERENCES City (CityID) NOT NULL,
	RegionID int FOREIGN KEY(RegionID) REFERENCES Region (RegionID) NOT NULL
)
GO

CREATE TABLE Coupons(
	CouponID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	CouponCode nvarchar(20) NOT NULL,
	Discount real DEFAULT (0) CHECK (Discount>=0 AND Discount<=1) NOT NULL,
	[Description] nvarchar(max) NOT NULL
)
GO

CREATE TABLE Product(
	ProductID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Name] nvarchar(50) NOT NULL,
	ShoesSizeID tinyint DEFAULT (1) FOREIGN KEY(ShoesSizeID) REFERENCES ShoesSize (ShoesSizeID) NOT NULL,
	SizeID tinyint DEFAULT (1) FOREIGN KEY(SizeID) REFERENCES Size (SizeID) NOT NULL,
	ColorID int FOREIGN KEY(ColorID) REFERENCES Color (ColorID) NOT NULL,
	CategoryID int FOREIGN KEY(CategoryID) REFERENCES Category (CategoryID) NOT NULL,
	TrademarkID int NOT NULL,
	IsUnisex bit DEFAULT (0) NOT NULL,
	UnitPrice money CHECK  (UnitPrice>0) NOT NULL,
	UnitInStock smallint CHECK (UnitInStock>=0) NOT NULL,
	UnitsInOrder smallint  CHECK  (UnitsInOrder>=0)NOT NULL,
	ReOrderLevel smallint CHECK (ReOrderLevel>=0) NOT NULL,
	Discontinued bit DEFAULT (1) NOT NULL
)
GO

CREATE TABLE [Order](
	OrderID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	AccountID int FOREIGN KEY(AccountID) REFERENCES AccountInfo (AccountID) NOT NULL,
	OrderDate datetime DEFAULT (getdate()) NOT NULL,
	RequiredDate datetime DEFAULT (dateadd(day,(10),getdate())) NOT NULL,
	DeliveredDate datetime NULL,
	ShippedDate datetime NULL,
	ShipperID tinyint FOREIGN KEY(ShipperID) REFERENCES Shipper (ShippersID) NOT NULL,
	Freight money CHECK  (Freight>0) NOT NULL,
	CONSTRAINT CK_Order_ShippedDate CHECK
  (
    (ShippedDate >= OrderDate AND ShippedDate <= DeliveredDate)
  )
)
GO

CREATE TABLE OrderDetail(
	OrderID int FOREIGN KEY(OrderID) REFERENCES [Order] (OrderID) NOT NULL,
	TrademarkID int FOREIGN KEY(TrademarkID) REFERENCES Trademark (TrademarkID) NOT NULL,
	ProductID int FOREIGN KEY(ProductID) REFERENCES Product (ProductID) NOT NULL,
	UnitPrice money CHECK (UnitPrice>0) NOT NULL,
	Quantity tinyint CHECK (Quantity>0) NOT NULL,
	Discount real DEFAULT (0) CHECK (Discount>=0 AND Discount<=1)NOT NULL
)
GO

CREATE TABLE Restitute(
	RestituteID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	OrderID int FOREIGN KEY(OrderID) REFERENCES [Order] (OrderID) NOT NULL,
	AccountID int FOREIGN KEY(AccountID) REFERENCES AccountInfo (AccountID) NOT NULL,
	ProductID int FOREIGN KEY(ProductID) REFERENCES Product (ProductID) NOT NULL,
	ShipperID tinyint FOREIGN KEY(ShipperID) REFERENCES Shipper (ShippersID) NOT NULL,
	Description nvarchar(max) NULL,
	[Date] datetime DEFAULT (getdate()) NOT NULL
)
GO

CREATE TABLE Cart(
	CartID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	AccountID int FOREIGN KEY(AccountID) REFERENCES AccountInfo(AccountID) NOT NULL,
	ProductID int FOREIGN KEY(ProductID) REFERENCES Product (ProductID) NOT NULL,
	Quantity tinyint DEFAULT (1) CHECK  (Quantity>=0) NOT NULL,
	CouponID int  FOREIGN KEY(CouponID) REFERENCES Coupons (CouponID) NULL
)
GO

CREATE TABLE Favorites(
	FavoriteID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	AccountID int FOREIGN KEY(AccountID) REFERENCES AccountInfo (AccountID) NOT NULL,
	ProductID int FOREIGN KEY(ProductID) REFERENCES Product (ProductID) NOT NULL
)
GO

CREATE TABLE Rating(
	RatingID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Description nvarchar(max) NULL,
	AccountID int FOREIGN KEY(AccountID) REFERENCES AccountInfo (AccountID) NOT NULL,
	ProductID int FOREIGN KEY(ProductID) REFERENCES Product (ProductID) NOT NULL,
	RatingDate datetime DEFAULT (getdate()) NOT NULL,
	Point tinyint CHECK (Point>=1 AND Point<=5) NOT NULL
)
GO

INSERT City
VALUES
('Ýstanbul'),
('Ýzmir'),
('Ankara')
GO

INSERT Region
VALUES
('Þiþli'),
('Bakýrköy'),
('Fatih'),
('Kaðýthane'),
('Bahçelievler'),
('Kýzýlay'),
('Çankaya'),
('Göztepe'),
('Karþýyaka')
GO

INSERT [ADDRESS]
VALUES
('ÝSMAÝL','DEVLEZ','05308956879',1,1,'Gültepe Mahallesi','Ev')
GO

INSERT Gender
VALUES
('E'),
('K')
GO

INSERT Color
VALUES
('Kýrmýzý'),
('Turuncu'),
('Sarý'),
('Yeþil'),
('Mavi'),
('Mor'),
('Kahverengi')
GO

INSERT ShoesSize
VALUES
(0),
(39),
(40),
(41),
(42)
GO

INSERT Size
VALUES
('Yok'),
('XS'),
('S'),
('M'),
('L')
GO

INSERT Shipper
VALUES
('Mng','444-44-44'),
('Yurtiçi','445-45-45')

GO

INSERT Trademark
VALUES
('Pierre Cardin','444-44-44','Yasin',1),
('Trendyol Man','446-46-46','Ýso',2),
('Asus','445-45-45','Tayfun',3)
GO

INSERT UserLogin
VALUES
('yasin@gmail.com','123',1),
('bilal@gmail.com','123',1),
('tayfun@gmail.com','123',1)
GO

INSERT AccountInfo
VALUES
('Yasin','Mataracý','447-4878','12345678901',1,'1995-01-01',1),
('Ýsmail','Devlez','447-4444','12345678902',1,'1992-01-01',2),
('Tayfun','Karaveli','447-4222','12345678903',1,'1998-01-01',3)
GO

INSERT Category
VALUES
('Erkek',null),
('Kadýn',null),
('Erkek Giyim',1),
('Kadýn Giyim',2),
('Elektronik',null),
('Bilgisayar',5)
GO

INSERT CategoryTrademark
VALUES
(1,1),
(1,2),
(2,1),
(2,2),
(6,3)
GO

INSERT CityRegion
VALUES
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(2,5),
(2,6),
(2,7),
(3,8),
(3,9)
GO

INSERT Coupons
VALUES
('Post42',0.42,'%42 indirim yaptýk'),
('2019WINTER',0.1,'%10 indirim yaptýk')
GO

INSERT Product
VALUES
('Sweatshirt',1,3,2,3,1,0,10,100,50,25,1),
('Laptop',1,1,1,6,3,1,1000,10,5,3,1)
GO

INSERT [Order]
VALUES
(1,'2019-10-04','2019-10-14','2019-10-07','2019-10-06',1,30),
(2,'2019-10-04','2019-10-14','2019-10-07','2019-10-06',2,1000)
GO

INSERT OrderDetail
VALUES
(1,1,1,10,3,0),
(2,3,2,1000,1,0)
GO

INSERT Restitute
VALUES
(2,3,1,1,'Beklediðim gibi gelmedi','2019-10-05')
GO

INSERT Cart
VALUES
(1,2,1,NULL)
GO

INSERT Favorites
VALUES
(3,1)
GO

INSERT Rating
VALUES
('Ürün güzel',1,2,'2019-10-05',4)
GO

CREATE PROC Sp_Category_Products_Count(@CategoryID INT)
AS
BEGIN

SELECT COUNT(*) 'Ürün adedi' FROM Category C, Product P
WHERE C.CategoryID = P.CategoryID AND C.CategoryID = @CategoryID

END
GO
--exec Sp_Category_Products_Count 1

CREATE PROC Sp_Products_Total_Orders
AS
BEGIN
	SELECT P.ProductID, SUM(OD.Quantity) 'Toplam Sipariþ'
	FROM OrderDetail OD, Product P
	WHERE OD.ProductID = P.ProductID
	GROUP BY P.ProductID
	ORDER BY 2 DESC
End
GO
--exec Sp_Products_Total_Orders

CREATE PROC Sp_Most_Expensive_Products
AS
BEGIN
SELECT P.[Name] 'Ürün Adý', P.UnitPrice
FROM Product P
ORDER BY P.UnitPrice DESC
End
GO
--exec Sp_Most_Expensive_Products

CREATE PROC Sp_User_Orders(@AccountID int)
AS
BEGIN
SELECT O.AccountID, OrderID, OrderDate, RequiredDate, DeliveredDate, ShippedDate
FROM [Order] O
WHERE O.AccountID = @AccountID
ORDER BY OrderID
END
GO
--exec Sp_User_Orders 4

CREATE PROC Sp_Create_User(@Email NVARCHAR(100),@Password NVARCHAR(50),@GenderID TINYINT) 
AS 
INSERT UserLogin 
VALUES (@Email,@Password,@GenderID) 
GO

--exec Sp_Create_User 'yusuf@gmail.com','123',1

CREATE FUNCTION FNC_Add_Price(@Price MONEY)
RETURNS MONEY
AS
BEGIN
	DECLARE @TotalPrice MONEY = @Price * 1.10
	RETURN @TotalPrice
END
GO

--SELECT dbo.FNC_Add_Price (P.UnitPrice) 'New Price',P.* FROM Product P


CREATE FUNCTION FNC_Order_Total_Price (@OrderID int)
RETURNS MONEY
AS
BEGIN
	DECLARE @OrderTotalPrice MONEY;
	SELECT @OrderTotalPrice=SUM(UnitPrice*Quantity*(1-Discount)) 
	FROM OrderDetail  
	WHERE OrderID= @OrderID 
	RETURN @OrderTotalPrice
END
GO

--SELECT dbo.FNC_Order_Total_Price (2) AS 'Total Price',OD.* from OrderDetail OD

CREATE FUNCTION FNC_Users_Products(@USERID int)
RETURNS TABLE
AS
RETURN
(
	SELECT  AI.FirstName,P.[Name],P.UnitPrice,OD.Quantity 
	FROM OrderDetail OD,[Order] O,Product P, AccountInfo AI
	WHERE OD.OrderID=O.OrderID AND OD.ProductID=P.ProductID AND  AI.AccountID = @USERID
)
GO
--SELECT * from FNC_Users_Products (3)


CREATE FUNCTION FNC_Products_Category(@ProductID INT)
RETURNS NVARCHAR(25)
BEGIN
	DECLARE @CategoryName NVARCHAR(25)='Ürün Bulumamadý'

	SELECT @CategoryName=C.[Name]  
	FROM Product P, Category C 
	WHERE P.CategoryID=C.CategoryID
	AND P.ProductID=@ProductID

	RETURN @CategoryName

END
GO
--select dbo.FNC_Products_Category(1)

CREATE FUNCTION FNC_Users_Information(@USERID INT)
RETURNS TABLE
AS
RETURN
(
SELECT AI.FirstName,AI.LastName,AI.Phone,AI.IdentityNo,AI.BirthDate 
FROM AccountInfo AI
WHERE AI.UserID = @USERID
)
GO
--SELECT * FROM DBO.FNC_Users_Information (3)

CREATE VIEW V_Man_Users
AS
SELECT AI.FirstName,AI.LastName,AI.Phone,AI.IdentityNo,AI.BirthDate 
FROM UserLogin UL,AccountInfo AI 
WHERE UL.GenderID = 1
GO

CREATE VIEW V_Woman_Users
AS
SELECT AI.FirstName,AI.LastName,AI.Phone,AI.IdentityNo,AI.BirthDate 
FROM UserLogin UL,AccountInfo AI 
WHERE UL.GenderID = 2
GO

CREATE VIEW V_Product_Stock
AS
SELECT P.ProductID, P.[Name],P.UnitInStock,P.ReOrderLevel
FROM Product P
WHERE P.UnitInStock < P.ReOrderLevel
GO

CREATE VIEW V_Product_Active
AS
SELECT C.Name 'Kategori Adý', P.Name 'Ürün Adý', P.UnitInStock, P.Discontinued
FROM Category C, Product P
WHERE C.CategoryID = P.CategoryID AND P.Discontinued = 1
GO

CREATE VIEW V_Product_NotActive
AS
SELECT C.Name 'Kategori Adý', P.Name 'Ürün Adý', P.UnitInStock, P.Discontinued
FROM Category C, Product P
WHERE C.CategoryID = P.CategoryID AND P.Discontinued = 0
GO

CREATE TRIGGER Trg_ProductDelete
ON Product
INSTEAD OF DELETE
AS
BEGIN
	UPDATE Product SET Discontinued = 0
END
GO

CREATE TRIGGER Trg_ProductInsert_IncreasePrice
ON Product
AFTER INSERT
AS
BEGIN
	UPDATE Product SET UnitPrice = UnitPrice * 1.18
END