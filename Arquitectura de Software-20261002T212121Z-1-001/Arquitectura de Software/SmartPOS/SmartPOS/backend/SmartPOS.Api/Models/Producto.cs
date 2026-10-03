namespace SmartPOS.Api.Models;

public class Producto
{
    public int Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public string Category { get; set; } = "";
    public decimal Price { get; set; }
    public int Stock { get; set; }
    public int Min { get; set; }
    public string Warehouse { get; set; } = "";
    public string Icon { get; set; } = "";
}