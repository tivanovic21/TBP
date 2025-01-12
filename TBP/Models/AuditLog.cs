namespace TBP.Models;

public class AuditLog
{  
    public int Id { get; set; }
    public int ActionId { get; set; }
    public int ExecutedBy { get; set; }
    public DateTime ExecutedAt { get; set; }
}