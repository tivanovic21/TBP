using Microsoft.EntityFrameworkCore;
using TBP.Models;
using Action = TBP.Models.Action;

namespace TBP.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }
    
    public DbSet<User> Users { get; set; }
    public DbSet<Role> Roles { get; set; }
    public DbSet<Action> Actions { get; set; }
    public DbSet<AuditLog> AuditLogs { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder
            .HasPostgresExtension("pgcrypto");

        modelBuilder.Entity<User>()
            .Property(u => u.Metadata)
            .HasColumnType("jsonb");
            
        modelBuilder.Entity<User>().ToTable("users")
            .HasKey(u => u.ID);
        
        modelBuilder.Entity<User>()
            .Property(u => u.UpdatedAt)
            .ValueGeneratedOnUpdate()
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .Metadata.SetAfterSaveBehavior(Microsoft.EntityFrameworkCore.Metadata.PropertySaveBehavior.Ignore);
        
        modelBuilder.Entity<Metadata>().HasNoKey();
        modelBuilder.Ignore<Metadata>();
        
        modelBuilder.Entity<Role>().ToTable("roles");
        modelBuilder.Entity<Action>().ToTable("actions");
        modelBuilder.Entity<AuditLog>().ToTable("auditlogs");
        
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            foreach (var property in entityType.GetProperties())
            {
                property.SetColumnName(property.Name.ToLower());
            }
        }
    }
}