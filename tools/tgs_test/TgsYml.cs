using Tgstation.Server.Api.Models;

sealed class TgsYml
{
	public int Version { get; set; }

	public string Byond { get; set; } = String.Empty;

	public List<StaticFile> StaticFiles { get; set; } = new List<StaticFile>();

	public Dictionary<string, string> WindowsScripts { get; set; } = new Dictionary<string, string>();
	public Dictionary<string, string> LinuxScripts { get; set; } = new Dictionary<string, string>();

	public DreamDaemonSecurity Security { get; set; }
}
