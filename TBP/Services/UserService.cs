using Microsoft.EntityFrameworkCore;
using Npgsql;
using TBP.Data;
using TBP.Models;

namespace TBP.Services;

public class UserService : IUserService
{
    private readonly ApplicationDbContext _context;
    
    public UserService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<string> GetUserNameAsync(HttpContext context)
    {
        if (int.TryParse(context.Request.Cookies["UserId"], out var userId))
        {
            return _context.Users.FirstOrDefault(u => u.ID == userId).MetadataModel.FirstName;
        }
        
        return string.Empty;
    }

    public async Task<bool> IsAdminAsync(HttpContext context)
    {
        if (context.Request.Cookies.TryGetValue("UserId", out var userIdValue) && int.TryParse(userIdValue, out var userId))
        {
            await using var connection = new NpgsqlConnection(_context.Database.GetDbConnection().ConnectionString);
            await connection.OpenAsync();

            var command = connection.CreateCommand();
            command.CommandText = "SELECT is_admin (@userId)";
            command.Parameters.AddWithValue("userId", userId);

            var result = await command.ExecuteScalarAsync(); 

            return result != null && (bool)result;
        }
        
        return false;
    }

    public async Task<bool> IsAuthenticatedAsync(HttpContext context)
    {
        if (context.Request.Cookies.TryGetValue("UserId", out var userIdValue) && int.TryParse(userIdValue, out var userId))
        {
            await using var connection = new NpgsqlConnection(_context.Database.GetDbConnection().ConnectionString);
            await connection.OpenAsync();

            var command = connection.CreateCommand();
            command.CommandText = "SELECT has_existing_session(@userId)";
            command.Parameters.AddWithValue("userId", userId);

            var result = await command.ExecuteScalarAsync(); 

            return result != null && (bool)result;
        }
        
        return false;
    }
}