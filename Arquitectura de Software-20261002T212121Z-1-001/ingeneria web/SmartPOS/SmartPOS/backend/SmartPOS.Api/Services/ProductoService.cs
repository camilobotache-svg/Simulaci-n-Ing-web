using SmartPOS.Api.Models;
using SmartPOS.Api.Repositories;

namespace SmartPOS.Api.Services;

public class ProductoService : IProductoService
{
    private readonly IProductoRepository repository;

    public ProductoService(IProductoRepository repository)
    {
        this.repository = repository;
    }

    public IReadOnlyList<Producto> ObtenerTodos()
    {
        return repository.ObtenerTodos();
    }

    public Producto? ObtenerPorId(int id)
    {
        return repository.ObtenerPorId(id);
    }
}