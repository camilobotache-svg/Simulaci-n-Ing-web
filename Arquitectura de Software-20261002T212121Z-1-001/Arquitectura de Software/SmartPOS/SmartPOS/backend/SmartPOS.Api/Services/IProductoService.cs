using SmartPOS.Api.Models;

namespace SmartPOS.Api.Services;

public interface IProductoService
{
    IReadOnlyList<Producto> ObtenerTodos();
    Producto? ObtenerPorId(int id);
}