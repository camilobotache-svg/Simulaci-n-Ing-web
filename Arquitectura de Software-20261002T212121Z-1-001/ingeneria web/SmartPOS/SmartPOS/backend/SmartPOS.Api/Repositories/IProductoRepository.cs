using SmartPOS.Api.Models;

namespace SmartPOS.Api.Repositories;

public interface IProductoRepository
{
    IReadOnlyList<Producto> ObtenerTodos();
    Producto? ObtenerPorId(int id);
}