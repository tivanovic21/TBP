using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace TBP.Models
{
    public class User
    {
        public int ID { get; set; }
        public required string Email { get; set; }
        public required string Password { get; set; }
        public string Metadata { get; set; }

        public int RoleId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public bool IsDeleted { get; set; }

        public Role Role { get; set; }

        [JsonIgnore]
        public Metadata MetadataModel
        {
            get => string.IsNullOrEmpty(Metadata)
                ? new Metadata()
                : JsonSerializer.Deserialize<Metadata>(Metadata) ?? new Metadata();
            set => Metadata = JsonSerializer.Serialize(value);
        }
    }

    [NotMapped]
    public class Metadata
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public DateTime DateOfBirth { get; set; }
        public int Age { get; set; } = 0;
    }
}