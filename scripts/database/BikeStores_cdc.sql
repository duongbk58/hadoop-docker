USE BikeStores;
EXEC sys.sp_cdc_enable_db;
GO
EXEC sys.sp_cdc_enable_table @source_schema = 'production', @source_name = 'categories', @role_name = NULL, @supports_net_changes = 0;
GO
EXEC sys.sp_cdc_enable_table @source_schema = 'production', @source_name = 'brands', @role_name = NULL, @supports_net_changes = 0;
GO
EXEC sys.sp_cdc_enable_table @source_schema = 'production', @source_name = 'products', @role_name = NULL, @supports_net_changes = 0;
GO
EXEC sys.sp_cdc_enable_table @source_schema = 'sales', @source_name = 'customers', @role_name = NULL, @supports_net_changes = 0;
GO
EXEC sys.sp_cdc_enable_table @source_schema = 'sales', @source_name = 'staffs', @role_name = NULL, @supports_net_changes = 0;
GO
EXEC sys.sp_cdc_enable_table @source_schema = 'sales', @source_name = 'stores', @role_name = NULL, @supports_net_changes = 0;
GO