using Microsoft.EntityFrameworkCore;
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
            var user = await _context.Users.FirstOrDefaultAsync(u => u.ID == userId);

            if (user != null && user.RoleId == (int)Roles.Admin)
            {
                return true;
            }
            else return false;
        }
        
        return false;
    }
}