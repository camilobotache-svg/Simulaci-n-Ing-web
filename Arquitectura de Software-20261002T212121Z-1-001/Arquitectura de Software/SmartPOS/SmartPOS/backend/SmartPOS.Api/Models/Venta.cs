namespace SmartPOS.Api.Models;

public class Venta
{
    public long Id { get; set; }
    public DateTimeOffset Date { get; set; }
    public string Method { get; set; } = "";
    public decimal Total { get; set; }
    public List<DetalleVenta> Items { get; set; } = new();
}

public class DetalleVenta
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public int Qty { get; set; }
    public decimal Price { get; set; }
    public decimal Subtotal => Price * Qty;
}