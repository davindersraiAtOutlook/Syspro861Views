CREATE VIEW dbo.slInventoryWH_Cost
AS
SELECT 'G' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompanyG.dbo.InvWarehouse
UNION ALL
SELECT '0' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompany0.dbo.InvWarehouse
UNION ALL
SELECT '2' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompany2.dbo.InvWarehouse
UNION ALL
SELECT '3' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompany3.dbo.InvWarehouse
UNION ALL
SELECT '8' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompany8.dbo.InvWarehouse
UNION ALL
SELECT 'D' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompanyD.dbo.InvWarehouse
UNION ALL
SELECT 'N' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompanyN.dbo.InvWarehouse
UNION ALL
SELECT 'U' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompanyU.dbo.InvWarehouse
UNION ALL
SELECT 'W' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompanyW.dbo.InvWarehouse
UNION ALL
SELECT 'X' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompanyX.dbo.InvWarehouse
UNION ALL
SELECT 'Z' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompanyZ.dbo.InvWarehouse
UNION ALL
SELECT 'M' AS Company, StockCode, Warehouse, QtyOnHand, UnitCost
FROM SysproCompanyM.dbo.InvWarehouse
