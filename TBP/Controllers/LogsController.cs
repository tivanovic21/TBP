using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TBP.Data;
using TBP.Services;

namespace TBP.Controllers;

public class LogsController : Controller
{
    private readonly ApplicationDbContext _context;
    private readonly IUserService _userService;

    public LogsController(ApplicationDbContext context, IUserService userService)
    {
        _context = context;
        _userService = userService;
    }
    
    public async Task<IActionResult> Index()
    {
        if (!await _userService.IsAuthenticatedAsync(HttpContext)) return RedirectToAction("Login", "Authentication");
        if (!await _userService.IsAdminAsync(HttpContext)) return Unauthorized("Only Admin can see logs");
        
        var logs = await _context.AuditLogs
            .Include(log => log.User)
            .Include(log => log.Action)
            .ToListAsync();
        
        return View("~/Views/Log/Logs.cshtml", logs);
    }
}