using SmartPOS.Api.Dtos;
using SmartPOS.Api.Repositories;
using SmartPOS.Api.Services;
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSingleton<IProductoRepository, ProductoRepository>();
builder.Services.AddScoped<IProductoService, ProductoService>();
builder.Services.AddSingleton<IVentaService, VentaService>();

var app = builder.Build();
app.UseDefaultFiles();
app.UseStaticFiles();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint(
        "/swagger/v1/swagger.json",
        "SmartPOS.Api v1"
    );
});
}

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

app.MapGet("/api/v1/productos",
    (IProductoService service) =>
    {
        return Results.Ok(service.ObtenerTodos());
    })
    .WithTags("Productos")
    .WithName("ObtenerProductos");

app.MapGet("/api/v1/productos/{id:int}",
    (int id, IProductoService service) =>
    {
        var producto = service.ObtenerPorId(id);

        if (producto is null)
        {
            return Results.NotFound(new
            {
                mensaje = "Producto no encontrado."
            });
        }

        return Results.Ok(producto);
    })
    .WithTags("Productos")
    .WithName("ObtenerProductoPorId");
app.MapPost("/api/v1/ventas",
    (CrearVentaDto solicitud, IVentaService service) =>
    {
        try
        {
            var venta = service.Registrar(solicitud);
            return Results.Json(venta, statusCode: 201);
        }
        catch (ArgumentException error)
        {
            return Results.BadRequest(new
            {
                mensaje = error.Message
            });
        }
        catch (InvalidOperationException error)
        {
            return Results.Conflict(new
            {
                mensaje = error.Message
            });
        }
    })
    .WithTags("Ventas")
    .WithName("RegistrarVenta");
app.MapGet("/api/v1/ventas",
    (IVentaService service) =>
    {
        return Results.Ok(service.ObtenerTodas());
    })
    .WithTags("Ventas")
    .WithName("ObtenerVentas");
app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
