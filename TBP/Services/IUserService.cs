namespace TBP.Services;

public interface IUserService
{
    Task<string> GetUserNameAsync(HttpContext context);
    Task<bool> IsAdminAsync(HttpContext context);
}