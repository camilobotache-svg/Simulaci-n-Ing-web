using SmartPOS.Api.Dtos;
using SmartPOS.Api.Models;
using SmartPOS.Api.Repositories;

namespace SmartPOS.Api.Services;

public class VentaService : IVentaService
{
    private readonly IProductoRepository repository;
    private readonly object bloqueo = new();
    private readonly List<Venta> ventas = new();
    private long siguienteId = 1;

    public VentaService(IProductoRepository repository)
    {
        this.repository = repository;
    }

    public Venta Registrar(CrearVentaDto solicitud)
    {
        lock (bloqueo)
        {
            if (solicitud.Items is null || solicitud.Items.Count == 0)
            {
                throw new ArgumentException(
                    "La venta debe contener productos.");
            }

            var mediosPermitidos = new[]
            {
                "Tarjeta", "Efectivo", "Transferencia"
            };

            if (!mediosPermitidos.Contains(solicitud.MedioPago))
            {
                throw new ArgumentException(
                    "El medio de pago no es válido.");
            }

            var ids = new HashSet<int>();
            var detalles = new List<DetalleVenta>();
            var descuentos = new List<(Producto Producto, int Cantidad)>();

            foreach (var item in solicitud.Items)
            {
                if (item is null || item.Cantidad <= 0)
                {
                    throw new ArgumentException(
                        "Cada producto debe tener una cantidad positiva.");
                }

                if (!ids.Add(item.IdProducto))
                {
                    throw new ArgumentException(
                        "Un producto no puede repetirse en el carrito.");
                }

                var producto = repository.ObtenerPorId(item.IdProducto);

                if (producto is null)
                {
                    throw new ArgumentException(
                        $"No existe el producto {item.IdProducto}.");
                }

                if (item.Cantidad > producto.Stock)
                {
                    throw new InvalidOperationException(
                        $"Stock insuficiente para {producto.Name}.");
                }

                detalles.Add(new DetalleVenta
                {
                    Id = producto.Id,
                    Name = producto.Name,
                    Qty = item.Cantidad,
                    Price = producto.Price
                });

                descuentos.Add((producto, item.Cantidad));
            }

            var venta = new Venta
            {
                Id = siguienteId,
                Date = DateTimeOffset.UtcNow,
                Method = solicitud.MedioPago,
                Total = detalles.Sum(d => d.Subtotal),
                Items = detalles
            };

            ventas.Add(venta);

            foreach (var descuento in descuentos)
            {
                descuento.Producto.Stock -= descuento.Cantidad;
            }

            siguienteId++;

            return venta;
        }
    }
    public IReadOnlyList<Venta> ObtenerTodas()
{
    lock (bloqueo)
    {
        return ventas
            .OrderByDescending(v => v.Id)
            .ToList()
            .AsReadOnly();
    }
}
}