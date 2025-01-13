using System.Data;
using System.Data.Common;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using TBP.Data;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using TBP.Models;

namespace TBP.Controllers;

public class AuthenticationController : Controller
{
    private readonly ILogger<AuthenticationController> _logger;
    private readonly ApplicationDbContext _context;

    public AuthenticationController(ILogger<AuthenticationController> logger, ApplicationDbContext context)
    {
        _logger = logger;
        _context = context;
    }

    public IActionResult Login()
    {
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> Login(string email, string password)
    {
        var user = _context.Users.FirstOrDefault(u => u.Email == email && !u.IsDeleted); 
        if (user == null) return NotFound("No active user with email " + email + " found");
        
        var isPasswordValid = await VerifyPassword(password, user.Password);
        if (!isPasswordValid) return Unauthorized("Invalid email and password combination");
        
        var userIpAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

        await using var connection = new NpgsqlConnection(_context.Database.GetDbConnection().ConnectionString);
        await connection.OpenAsync();

        await using (var command = connection.CreateCommand())
        {
            command.CommandText = "SELECT login_user(@user_id, @user_ip);";
            command.Parameters.Add(new NpgsqlParameter("user_id", user.ID));
            command.Parameters.Add(new NpgsqlParameter("user_ip", userIpAddress));
            await command.ExecuteNonQueryAsync();
        }
            
        Response.Cookies.Append("UserId", user.ID.ToString(), new CookieOptions
         {
             HttpOnly = true,
             IsEssential = true,
             Expires = DateTimeOffset.UtcNow.AddDays(7)
         });
        return RedirectToAction("Index", "Home");
    }
    
    public IActionResult Register()
    {
        return View();
    }
    
    [HttpPost]
    public async Task<IActionResult> Register(string email, string password, string firstName, string lastName, DateTime dob, int roleId)
    {
        try
        {
            if (!int.TryParse(Request.Cookies["UserId"], out var userId))
            {
                return Unauthorized("Not logged in!");
            }           
            
            await using var connection = new NpgsqlConnection(_context.Database.GetDbConnection().ConnectionString);
            await connection.OpenAsync();

            await using (var command = connection.CreateCommand())
            {
                command.CommandText = "SELECT is_admin(@user_id);";
                command.Parameters.Add(new NpgsqlParameter("user_id", userId));
                var result = await command.ExecuteScalarAsync();
                
                if (result is bool and false) return Unauthorized("Only administrator can register a new user!");
            }
            
            var newUser = new User()
            {
                Email = email,
                Password = password,
                Metadata = JsonSerializer.Serialize(new Metadata()
                {
                    FirstName = firstName,
                    LastName = lastName,
                    DateOfBirth = dob,
                }),
                RoleId = roleId
            };
            
            _context.Users.Add(newUser);
            _context.SaveChanges();

            return RedirectToAction("Login", "authentication");
        }
        catch (DbException dbException)
        {
            ModelState.AddModelError("Db Error", dbException.Message);
            return BadRequest(dbException.Message);
        }
        catch (Exception e)
        {
            ModelState.AddModelError("General Error", e.Message);
            return BadRequest(e.Message);
        }
    }

    public async Task<IActionResult> Logout()
    {
        await using var connection = new NpgsqlConnection(_context.Database.GetDbConnection().ConnectionString);
        await connection.OpenAsync();
        
        var userId = Request.Cookies["UserId"];
        if (string.IsNullOrEmpty(userId)) return Unauthorized("User ID not found in cookies");
        
        await using (var command = connection.CreateCommand())
        {
            command.CommandText = "SELECT logout_user(@user_id);";
            command.Parameters.Add(new NpgsqlParameter("user_id", int.Parse(userId)));

            await command.ExecuteNonQueryAsync();
        }

        Response.Cookies.Delete("UserId");
        
        return RedirectToAction("Login", "Authentication");
    }
    private async Task<bool> VerifyPassword(string plainTextPassword, string storedPasswordHash)
    {
        var query = "SELECT crypt(@password, @storedHash) = @storedHash;";
        await using var connection = _context.Database.GetDbConnection();
        await connection.OpenAsync();

        await using var command = connection.CreateCommand();
        command.CommandText = query;
        
        var passwordParam = command.CreateParameter();
        passwordParam.ParameterName = "@password";
        passwordParam.Value = plainTextPassword;
        command.Parameters.Add(passwordParam);

        var hashParam = command.CreateParameter();
        hashParam.ParameterName = "@storedHash";
        hashParam.Value = storedPasswordHash;
        command.Parameters.Add(hashParam);

        var result = await command.ExecuteScalarAsync();

        return result is bool and true;
    }
}