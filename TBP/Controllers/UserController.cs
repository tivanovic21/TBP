using System.Runtime.InteropServices.JavaScript;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using TBP.Data;
using TBP.Models;
using TBP.Services;

namespace TBP.Controllers;

public class UserController : Controller
{
    private readonly ApplicationDbContext _context;
    private readonly IUserService _userService;

    public UserController(ApplicationDbContext context, IUserService userService)
    {
        _context = context;
        _userService = userService;
    }

    public async Task<IActionResult> AllUsers()
    {
        if (!await _userService.IsAuthenticatedAsync(HttpContext)) return RedirectToAction("Login", "Authentication");
        if (!await _userService.IsAdminAsync(HttpContext)) return Unauthorized("Only Admin can see all users");
        
        return View("AllUsers", await _context.Users.OrderBy(u => u.IsDeleted).ThenBy(u => u.ID).ToListAsync());
    }

    public async Task<IActionResult> MyAccount()
    {
        if (!await _userService.IsAuthenticatedAsync(HttpContext)) return RedirectToAction("Login", "Authentication");

        int userId = int.Parse(Request.Cookies["UserId"]);
        var user = _context.Users.FirstOrDefault(u => u.ID == userId);

        return View("MyAccount", user);
    }
    
    [HttpPost]
    public async Task<IActionResult> UpdateAccount(string email, string password, string firstName, string lastName, DateTime dateOfBirth, int? userId = null)
    {
        if (!await _userService.IsAuthenticatedAsync(HttpContext)) return RedirectToAction("Login", "Authentication");
        
        if (userId == null) userId = int.Parse(Request.Cookies["UserId"]);
        var user = await _context.Users.FirstOrDefaultAsync(u => u.ID == userId);
        if (user == null)
        {
            return NotFound();
        }

        await using var connection = new NpgsqlConnection(_context.Database.GetDbConnection().ConnectionString);
        await connection.OpenAsync();

        var metadata = new Metadata {
            FirstName = firstName,
            LastName = lastName,
            DateOfBirth = dateOfBirth
        };

        var command = connection.CreateCommand();
        command.CommandText = "UPDATE users SET email = @email, password = @password, metadata = @metadata WHERE id = @userId";
        command.Parameters.AddWithValue("email", email);
        command.Parameters.AddWithValue("password", password);
        
        var metadataParameter = command.Parameters.AddWithValue("metadata", JsonSerializer.Serialize(metadata));
        metadataParameter.NpgsqlDbType = NpgsqlTypes.NpgsqlDbType.Jsonb;

        command.Parameters.AddWithValue("userId", userId);
        await command.ExecuteNonQueryAsync();

        return RedirectToAction("MyAccount");
    }

    [HttpPost]
    public async Task<IActionResult> DeleteAccount([FromRoute] int id)
    {
        if (!await _userService.IsAuthenticatedAsync(HttpContext)) return RedirectToAction("Login", "Authentication");
        if (!await _userService.IsAdminAsync(HttpContext)) return Unauthorized("Only Admin can delete a user!");
        
        var user = await _context.Users.FirstOrDefaultAsync(u => u.ID == id);
        if (user == null)
        {
            return NotFound("No user with id " + id + " found");
        }
        
        user.IsDeleted = true;
        await _context.SaveChangesAsync();
        return RedirectToAction("AllUsers");
    }
}