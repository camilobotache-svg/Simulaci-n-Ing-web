namespace SmartPOS.Api.Dtos;

public class CrearVentaDto
{
    public string MedioPago { get; set; } = "";
    public List<ItemVentaDto> Items { get; set; } = new();
}

public class ItemVentaDto
{
    public int IdProducto { get; set; }
    public int Cantidad { get; set; }
}