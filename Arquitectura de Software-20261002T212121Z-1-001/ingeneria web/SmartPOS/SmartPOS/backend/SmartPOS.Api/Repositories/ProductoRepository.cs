using SmartPOS.Api.Models;

namespace SmartPOS.Api.Repositories;

public class ProductoRepository : IProductoRepository
{
    private readonly List<Producto> productos = new()
    {
        new Producto
        {
            Id = 1, Code = "7501055301234",
            Name = "Leche Entera 1L", Category = "Lácteos",
            Price = 5200, Stock = 25, Min = 8,
            Warehouse = "Bodega Principal", Icon = "🥛"
        },
        new Producto
        {
            Id = 2, Code = "7501055305676",
            Name = "Arroz Premium 1kg", Category = "Granos",
            Price = 7800, Stock = 18, Min = 8,
            Warehouse = "Bodega Principal", Icon = "🍚"
        },
        new Producto
        {
            Id = 3, Code = "7501055308905",
            Name = "Aceite Vegetal 900ml", Category = "Despensa",
            Price = 14900, Stock = 12, Min = 6,
            Warehouse = "Bodega Principal", Icon = "🧴"
        },
        new Producto
        {
            Id = 4, Code = "7501055301111",
            Name = "Azúcar Blanca 1kg", Category = "Granos",
            Price = 5900, Stock = 30, Min = 10,
            Warehouse = "Bodega Principal", Icon = "🧂"
        },
        new Producto
        {
            Id = 5, Code = "7702001123456",
            Name = "Gaseosa Cola 1.5L", Category = "Bebidas",
            Price = 7200, Stock = 7, Min = 8,
            Warehouse = "Piso de Venta", Icon = "🥤"
        },
        new Producto
        {
            Id = 6, Code = "7701234009876",
            Name = "Pan Integral", Category = "Panadería",
            Price = 6900, Stock = 5, Min = 6,
            Warehouse = "Piso de Venta", Icon = "🍞"
        },
        new Producto
        {
            Id = 7, Code = "7700000991122",
            Name = "Huevos AA x12", Category = "Lácteos",
            Price = 11900, Stock = 16, Min = 8,
            Warehouse = "Bodega Principal", Icon = "🥚"
        },
        new Producto
        {
            Id = 8, Code = "7709999887766",
            Name = "Café Molido 500g", Category = "Despensa",
            Price = 18400, Stock = 9, Min = 5,
            Warehouse = "Bodega Principal", Icon = "☕"
        }
    };

    public IReadOnlyList<Producto> ObtenerTodos()
    {
        return productos.AsReadOnly();
    }

    public Producto? ObtenerPorId(int id)
    {
        return productos.FirstOrDefault(p => p.Id == id);
    }
}