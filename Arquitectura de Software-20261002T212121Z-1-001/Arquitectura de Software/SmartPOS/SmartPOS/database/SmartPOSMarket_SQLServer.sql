/*
 SmartPOS Market - SQL Server
 Script académico listo para ejecutar en SQL Server Management Studio (SSMS).
 SGBD: Microsoft SQL Server
*/

IF DB_ID(N'SmartPOSMarket') IS NULL
BEGIN
    CREATE DATABASE SmartPOSMarket;
END;
GO

USE SmartPOSMarket;
GO

/* =========================
   1. TABLAS MAESTRAS
   ========================= */

CREATE TABLE dbo.Roles (
    IdRol           INT IDENTITY(1,1) PRIMARY KEY,
    Nombre          NVARCHAR(50) NOT NULL UNIQUE,
    Descripcion     NVARCHAR(200) NULL
);
GO

CREATE TABLE dbo.Usuarios (
    IdUsuario       INT IDENTITY(1,1) PRIMARY KEY,
    IdRol           INT NOT NULL,
    NombreUsuario   NVARCHAR(80) NOT NULL UNIQUE,
    PasswordHash    NVARCHAR(255) NOT NULL,
    NombreCompleto  NVARCHAR(150) NOT NULL,
    Activo          BIT NOT NULL CONSTRAINT DF_Usuarios_Activo DEFAULT(1),
    FechaCreacion   DATETIME2 NOT NULL CONSTRAINT DF_Usuarios_Fecha DEFAULT(SYSDATETIME()),
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IdRol) REFERENCES dbo.Roles(IdRol)
);
GO

CREATE TABLE dbo.Categorias (
    IdCategoria     INT IDENTITY(1,1) PRIMARY KEY,
    Nombre          NVARCHAR(100) NOT NULL UNIQUE,
    Descripcion     NVARCHAR(250) NULL
);
GO

CREATE TABLE dbo.Productos (
    IdProducto      INT IDENTITY(1,1) PRIMARY KEY,
    IdCategoria     INT NOT NULL,
    CodigoBarras    VARCHAR(30) NOT NULL UNIQUE,
    SKU             VARCHAR(30) NULL UNIQUE,
    Nombre          NVARCHAR(150) NOT NULL,
    Descripcion     NVARCHAR(300) NULL,
    PrecioCompra    DECIMAL(18,2) NOT NULL CONSTRAINT CK_Producto_PC CHECK (PrecioCompra >= 0),
    PrecioVenta     DECIMAL(18,2) NOT NULL CONSTRAINT CK_Producto_PV CHECK (PrecioVenta >= 0),
    StockMinimo     INT NOT NULL CONSTRAINT DF_Producto_StockMin DEFAULT(0),
    Activo          BIT NOT NULL CONSTRAINT DF_Producto_Activo DEFAULT(1),
    FechaCreacion   DATETIME2 NOT NULL CONSTRAINT DF_Producto_Fecha DEFAULT(SYSDATETIME()),
    CONSTRAINT FK_Productos_Categorias FOREIGN KEY (IdCategoria) REFERENCES dbo.Categorias(IdCategoria)
);
GO

CREATE TABLE dbo.Bodegas (
    IdBodega        INT IDENTITY(1,1) PRIMARY KEY,
    Nombre          NVARCHAR(100) NOT NULL UNIQUE,
    Ubicacion       NVARCHAR(200) NULL,
    Activa          BIT NOT NULL CONSTRAINT DF_Bodega_Activa DEFAULT(1)
);
GO

CREATE TABLE dbo.Inventario (
    IdProducto          INT NOT NULL,
    IdBodega            INT NOT NULL,
    Cantidad            INT NOT NULL CONSTRAINT DF_Inventario_Cantidad DEFAULT(0),
    UltimaActualizacion DATETIME2 NOT NULL CONSTRAINT DF_Inventario_Fecha DEFAULT(SYSDATETIME()),
    CONSTRAINT PK_Inventario PRIMARY KEY (IdProducto, IdBodega),
    CONSTRAINT FK_Inventario_Producto FOREIGN KEY (IdProducto) REFERENCES dbo.Productos(IdProducto),
    CONSTRAINT FK_Inventario_Bodega FOREIGN KEY (IdBodega) REFERENCES dbo.Bodegas(IdBodega),
    CONSTRAINT CK_Inventario_NoNegativo CHECK (Cantidad >= 0)
);
GO

CREATE TABLE dbo.Proveedores (
    IdProveedor     INT IDENTITY(1,1) PRIMARY KEY,
    Documento       VARCHAR(30) NULL UNIQUE,
    Nombre          NVARCHAR(150) NOT NULL,
    Telefono        VARCHAR(30) NULL,
    Correo          NVARCHAR(120) NULL,
    Activo          BIT NOT NULL CONSTRAINT DF_Proveedor_Activo DEFAULT(1)
);
GO

/* =========================
   2. COMPRAS / ENTRADAS
   ========================= */

CREATE TABLE dbo.Compras (
    IdCompra        BIGINT IDENTITY(1,1) PRIMARY KEY,
    IdProveedor     INT NOT NULL,
    IdUsuario       INT NOT NULL,
    Fecha           DATETIME2 NOT NULL CONSTRAINT DF_Compras_Fecha DEFAULT(SYSDATETIME()),
    Total           DECIMAL(18,2) NOT NULL CONSTRAINT DF_Compras_Total DEFAULT(0),
    Estado          VARCHAR(20) NOT NULL CONSTRAINT DF_Compras_Estado DEFAULT('REGISTRADA'),
    CONSTRAINT FK_Compras_Proveedor FOREIGN KEY (IdProveedor) REFERENCES dbo.Proveedores(IdProveedor),
    CONSTRAINT FK_Compras_Usuario FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuarios(IdUsuario),
    CONSTRAINT CK_Compras_Total CHECK (Total >= 0)
);
GO

CREATE TABLE dbo.DetalleCompra (
    IdDetalleCompra BIGINT IDENTITY(1,1) PRIMARY KEY,
    IdCompra        BIGINT NOT NULL,
    IdProducto      INT NOT NULL,
    IdBodega        INT NOT NULL,
    Cantidad        INT NOT NULL,
    CostoUnitario   DECIMAL(18,2) NOT NULL,
    Subtotal        AS (CONVERT(DECIMAL(18,2), Cantidad * CostoUnitario)) PERSISTED,
    CONSTRAINT FK_DetCompra_Compra FOREIGN KEY (IdCompra) REFERENCES dbo.Compras(IdCompra),
    CONSTRAINT FK_DetCompra_Producto FOREIGN KEY (IdProducto) REFERENCES dbo.Productos(IdProducto),
    CONSTRAINT FK_DetCompra_Bodega FOREIGN KEY (IdBodega) REFERENCES dbo.Bodegas(IdBodega),
    CONSTRAINT CK_DetCompra_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_DetCompra_Costo CHECK (CostoUnitario >= 0)
);
GO

/* =========================
   3. VENTAS / CAJA
   ========================= */

CREATE TABLE dbo.Ventas (
    IdVenta         BIGINT IDENTITY(1,1) PRIMARY KEY,
    IdUsuario       INT NOT NULL,
    Fecha           DATETIME2 NOT NULL CONSTRAINT DF_Ventas_Fecha DEFAULT(SYSDATETIME()),
    Total           DECIMAL(18,2) NOT NULL CONSTRAINT DF_Ventas_Total DEFAULT(0),
    MedioPago       VARCHAR(30) NOT NULL,
    Estado          VARCHAR(20) NOT NULL CONSTRAINT DF_Ventas_Estado DEFAULT('CONFIRMADA'),
    CONSTRAINT FK_Ventas_Usuario FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuarios(IdUsuario),
    CONSTRAINT CK_Ventas_Total CHECK (Total >= 0)
);
GO

CREATE TABLE dbo.DetalleVenta (
    IdDetalleVenta  BIGINT IDENTITY(1,1) PRIMARY KEY,
    IdVenta         BIGINT NOT NULL,
    IdProducto      INT NOT NULL,
    IdBodega        INT NOT NULL,
    Cantidad        INT NOT NULL,
    PrecioUnitario  DECIMAL(18,2) NOT NULL,
    Subtotal        AS (CONVERT(DECIMAL(18,2), Cantidad * PrecioUnitario)) PERSISTED,
    CONSTRAINT FK_DetVenta_Venta FOREIGN KEY (IdVenta) REFERENCES dbo.Ventas(IdVenta),
    CONSTRAINT FK_DetVenta_Producto FOREIGN KEY (IdProducto) REFERENCES dbo.Productos(IdProducto),
    CONSTRAINT FK_DetVenta_Bodega FOREIGN KEY (IdBodega) REFERENCES dbo.Bodegas(IdBodega),
    CONSTRAINT CK_DetVenta_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_DetVenta_Precio CHECK (PrecioUnitario >= 0)
);
GO

CREATE TABLE dbo.Pagos (
    IdPago          BIGINT IDENTITY(1,1) PRIMARY KEY,
    IdVenta         BIGINT NOT NULL,
    MedioPago       VARCHAR(30) NOT NULL,
    Valor           DECIMAL(18,2) NOT NULL,
    Referencia      NVARCHAR(100) NULL,
    Fecha           DATETIME2 NOT NULL CONSTRAINT DF_Pagos_Fecha DEFAULT(SYSDATETIME()),
    CONSTRAINT FK_Pagos_Ventas FOREIGN KEY (IdVenta) REFERENCES dbo.Ventas(IdVenta),
    CONSTRAINT CK_Pagos_Valor CHECK (Valor > 0)
);
GO

/* =========================
   4. MOVIMIENTOS Y AUDITORÍA
   ========================= */

CREATE TABLE dbo.MovimientosInventario (
    IdMovimiento    BIGINT IDENTITY(1,1) PRIMARY KEY,
    IdProducto      INT NOT NULL,
    IdBodega        INT NOT NULL,
    IdUsuario       INT NOT NULL,
    Tipo            VARCHAR(20) NOT NULL,
    Cantidad        INT NOT NULL,
    Referencia      NVARCHAR(100) NULL,
    Fecha           DATETIME2 NOT NULL CONSTRAINT DF_MovInv_Fecha DEFAULT(SYSDATETIME()),
    CONSTRAINT FK_MovInv_Producto FOREIGN KEY (IdProducto) REFERENCES dbo.Productos(IdProducto),
    CONSTRAINT FK_MovInv_Bodega FOREIGN KEY (IdBodega) REFERENCES dbo.Bodegas(IdBodega),
    CONSTRAINT FK_MovInv_Usuario FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuarios(IdUsuario),
    CONSTRAINT CK_MovInv_Tipo CHECK (Tipo IN ('ENTRADA','VENTA','DEVOLUCION','AJUSTE_POS','AJUSTE_NEG')),
    CONSTRAINT CK_MovInv_Cantidad CHECK (Cantidad > 0)
);
GO

CREATE TABLE dbo.Auditoria (
    IdAuditoria     BIGINT IDENTITY(1,1) PRIMARY KEY,
    IdUsuario       INT NULL,
    Entidad         NVARCHAR(80) NOT NULL,
    IdEntidad       NVARCHAR(80) NULL,
    Accion          VARCHAR(30) NOT NULL,
    Detalle         NVARCHAR(1000) NULL,
    Fecha           DATETIME2 NOT NULL CONSTRAINT DF_Auditoria_Fecha DEFAULT(SYSDATETIME()),
    CONSTRAINT FK_Auditoria_Usuario FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuarios(IdUsuario)
);
GO

/* =========================
   5. ÍNDICES
   ========================= */

CREATE NONCLUSTERED INDEX IX_Productos_Nombre
ON dbo.Productos(Nombre)
INCLUDE (CodigoBarras, PrecioVenta, Activo);
GO

CREATE NONCLUSTERED INDEX IX_Ventas_Fecha
ON dbo.Ventas(Fecha)
INCLUDE (Total, IdUsuario, MedioPago, Estado);
GO

CREATE NONCLUSTERED INDEX IX_DetalleVenta_Producto
ON dbo.DetalleVenta(IdProducto, IdVenta)
INCLUDE (Cantidad, PrecioUnitario);
GO

CREATE NONCLUSTERED INDEX IX_MovInventario_Producto_Fecha
ON dbo.MovimientosInventario(IdProducto, Fecha DESC)
INCLUDE (IdBodega, Tipo, Cantidad, Referencia);
GO

/* =========================
   6. VISTAS DE NEGOCIO
   ========================= */

CREATE OR ALTER VIEW dbo.vw_StockActual
AS
SELECT
    p.IdProducto,
    p.CodigoBarras,
    p.Nombre AS Producto,
    b.IdBodega,
    b.Nombre AS Bodega,
    i.Cantidad,
    p.StockMinimo,
    CASE WHEN i.Cantidad <= p.StockMinimo THEN 1 ELSE 0 END AS StockBajo
FROM dbo.Inventario i
INNER JOIN dbo.Productos p ON p.IdProducto = i.IdProducto
INNER JOIN dbo.Bodegas b ON b.IdBodega = i.IdBodega;
GO

CREATE OR ALTER VIEW dbo.vw_VentasDiarias
AS
SELECT
    CONVERT(date, Fecha) AS Fecha,
    COUNT(*) AS NumeroVentas,
    SUM(Total) AS TotalVendido
FROM dbo.Ventas
WHERE Estado = 'CONFIRMADA'
GROUP BY CONVERT(date, Fecha);
GO

/* =========================
   7. TIPO TABLA PARA DETALLE DE VENTA
   ========================= */

IF TYPE_ID(N'dbo.TipoDetalleVenta') IS NULL
EXEC('CREATE TYPE dbo.TipoDetalleVenta AS TABLE (
    IdProducto INT NOT NULL,
    IdBodega INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(18,2) NOT NULL
)');
GO

/* =========================
   8. PROCEDIMIENTO TRANSACCIONAL DE VENTA
   Evita sobreventa usando bloqueos UPDLOCK/HOLDLOCK.
   ========================= */

CREATE OR ALTER PROCEDURE dbo.sp_RegistrarVenta
    @IdUsuario INT,
    @MedioPago VARCHAR(30),
    @Detalle dbo.TipoDetalleVenta READONLY,
    @IdVenta BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM @Detalle)
            THROW 50001, 'La venta no contiene productos.', 1;

        -- Validación y bloqueo de las filas de inventario involucradas.
        IF EXISTS (
            SELECT 1
            FROM @Detalle d
            LEFT JOIN dbo.Inventario i WITH (UPDLOCK, HOLDLOCK)
              ON i.IdProducto = d.IdProducto AND i.IdBodega = d.IdBodega
            WHERE i.IdProducto IS NULL OR i.Cantidad < d.Cantidad
        )
            THROW 50002, 'Stock insuficiente para uno o más productos.', 1;

        DECLARE @Total DECIMAL(18,2);
        SELECT @Total = SUM(Cantidad * PrecioUnitario) FROM @Detalle;

        INSERT INTO dbo.Ventas(IdUsuario, Total, MedioPago, Estado)
        VALUES(@IdUsuario, @Total, @MedioPago, 'CONFIRMADA');

        SET @IdVenta = SCOPE_IDENTITY();

        INSERT INTO dbo.DetalleVenta(IdVenta, IdProducto, IdBodega, Cantidad, PrecioUnitario)
        SELECT @IdVenta, IdProducto, IdBodega, Cantidad, PrecioUnitario
        FROM @Detalle;

        UPDATE i
           SET i.Cantidad = i.Cantidad - d.Cantidad,
               i.UltimaActualizacion = SYSDATETIME()
        FROM dbo.Inventario i
        INNER JOIN @Detalle d
          ON d.IdProducto = i.IdProducto
         AND d.IdBodega = i.IdBodega;

        INSERT INTO dbo.MovimientosInventario
            (IdProducto, IdBodega, IdUsuario, Tipo, Cantidad, Referencia)
        SELECT IdProducto, IdBodega, @IdUsuario, 'VENTA', Cantidad,
               CONCAT('VENTA-', @IdVenta)
        FROM @Detalle;

        INSERT INTO dbo.Pagos(IdVenta, MedioPago, Valor)
        VALUES(@IdVenta, @MedioPago, @Total);

        INSERT INTO dbo.Auditoria(IdUsuario, Entidad, IdEntidad, Accion, Detalle)
        VALUES(@IdUsuario, 'Ventas', CONVERT(NVARCHAR(80),@IdVenta), 'INSERT',
               CONCAT('Venta confirmada por ', FORMAT(@Total,'N2')));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/* =========================
   9. DATOS DE PRUEBA
   ========================= */

IF NOT EXISTS (SELECT 1 FROM dbo.Roles)
BEGIN
    INSERT INTO dbo.Roles(Nombre,Descripcion) VALUES
    ('ADMINISTRADOR','Administración completa del sistema'),
    ('CAJERO','Registro de ventas y pagos'),
    ('BODEGA','Entradas, inventario y movimientos'),
    ('SUPERVISOR','Reportes, anulaciones y ajustes'),
    ('AUDITOR','Consulta de auditoría y reportes');
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Categorias)
BEGIN
    INSERT INTO dbo.Categorias(Nombre,Descripcion) VALUES
    ('Lácteos','Leches, yogures y derivados'),
    ('Granos','Arroz, azúcar, fríjol y similares'),
    ('Bebidas','Gaseosas, jugos y aguas'),
    ('Aseo','Productos para el hogar');
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Bodegas)
BEGIN
    INSERT INTO dbo.Bodegas(Nombre,Ubicacion) VALUES
    ('Bodega Principal','Zona posterior del supermercado'),
    ('Piso de Venta','Área de exhibición');
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios)
BEGIN
    INSERT INTO dbo.Usuarios(IdRol,NombreUsuario,PasswordHash,NombreCompleto)
    SELECT TOP 1 IdRol,'admin','$2b$12$CAMBIAR_HASH_EN_APLICACION','Administrador SmartPOS'
    FROM dbo.Roles WHERE Nombre='ADMINISTRADOR';

    INSERT INTO dbo.Usuarios(IdRol,NombreUsuario,PasswordHash,NombreCompleto)
    SELECT TOP 1 IdRol,'cajero1','$2b$12$CAMBIAR_HASH_EN_APLICACION','Cajero Principal'
    FROM dbo.Roles WHERE Nombre='CAJERO';
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Productos)
BEGIN
    DECLARE @Lacteos INT=(SELECT IdCategoria FROM dbo.Categorias WHERE Nombre='Lácteos');
    DECLARE @Granos INT=(SELECT IdCategoria FROM dbo.Categorias WHERE Nombre='Granos');
    DECLARE @Bebidas INT=(SELECT IdCategoria FROM dbo.Categorias WHERE Nombre='Bebidas');

    INSERT INTO dbo.Productos(IdCategoria,CodigoBarras,SKU,Nombre,PrecioCompra,PrecioVenta,StockMinimo)
    VALUES
    (@Lacteos,'770000000001','LAC-001','Leche Entera 1L',3800,5200,5),
    (@Granos,'770000000002','GRN-001','Arroz Premium 1kg',4800,6100,8),
    (@Bebidas,'770000000003','BEB-001','Gaseosa 1.5L',5200,7200,6),
    (@Granos,'770000000004','GRN-002','Azúcar Blanca 1kg',3900,5900,8);
END;
GO

MERGE dbo.Inventario AS t
USING (
    SELECT p.IdProducto, b.IdBodega, 25 AS Cantidad
    FROM dbo.Productos p
    CROSS JOIN dbo.Bodegas b
    WHERE b.Nombre='Bodega Principal'
) AS s
ON t.IdProducto=s.IdProducto AND t.IdBodega=s.IdBodega
WHEN NOT MATCHED THEN
  INSERT(IdProducto,IdBodega,Cantidad) VALUES(s.IdProducto,s.IdBodega,s.Cantidad);
GO

PRINT 'SmartPOSMarket creada correctamente.';
GO

/* =========================
   10. EJEMPLO DE VENTA
   =========================
DECLARE @D dbo.TipoDetalleVenta;
INSERT INTO @D(IdProducto,IdBodega,Cantidad,PrecioUnitario)
SELECT TOP 1 p.IdProducto,b.IdBodega,2,p.PrecioVenta
FROM dbo.Productos p CROSS JOIN dbo.Bodegas b
WHERE p.CodigoBarras='770000000001' AND b.Nombre='Bodega Principal';

DECLARE @Venta BIGINT;
EXEC dbo.sp_RegistrarVenta
    @IdUsuario=2,
    @MedioPago='TARJETA',
    @Detalle=@D,
    @IdVenta=@Venta OUTPUT;

SELECT @Venta AS IdVentaCreada;
SELECT * FROM dbo.vw_StockActual;
*/
