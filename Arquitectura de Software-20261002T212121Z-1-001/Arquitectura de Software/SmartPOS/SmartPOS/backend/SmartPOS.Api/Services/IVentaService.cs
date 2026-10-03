using SmartPOS.Api.Dtos;
using SmartPOS.Api.Models;

namespace SmartPOS.Api.Services;

public interface IVentaService
{
    Venta Registrar(CrearVentaDto solicitud);
    IReadOnlyList<Venta> ObtenerTodas();
}