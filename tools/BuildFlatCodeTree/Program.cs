// This program builds `/flat` which is a flat directory of all .dm files + the adjusted .dme
// This is used because BYOND only include filenames in the .dmb, not full or even relative paths
// So this is how we coerce them to be deterministic across multiple files with the same name
// Run from the git root with `dotnet -c Release --project tools/BuildFlatCodeTree`

using System.Text.RegularExpressions;

const string FlatDirectoryName = "flat";

var includeRegex = new Regex("#include(\\s+)\"(.*)\"", RegexOptions.Compiled);

var outputLines = new List<string>();

// I'm not sure if a trailing slash after GetFullPath is guaranteed to exist or not
var currentDirectoryA = Path.GetFullPath(Path.Combine(Environment.CurrentDirectory, "A"));

static string FlatPath(string path) => path.Replace('\\', '/').Replace('/', '!');

var tasks = new List<Task>();
async Task CreateFlatFile(string path, bool dme)
{
	// We want it to be a relative path
	var originalPathDirectory = Path.GetFullPath(Path.GetDirectoryName(path));
	path = Path.GetFullPath(path)[(currentDirectoryA.Length - 1)..];

	var fileContents = await File.ReadAllTextAsync(path);

	var matches = includeRegex!.Matches(fileContents)
		.Cast<Match>()
		.Where(x => x.Success)
		.ToList();

	foreach (var match in matches)
	{
		var fullIncludePath = Path.Combine(originalPathDirectory, match.Groups[2].Value)[(currentDirectoryA.Length - 1)..].Replace('/', '\\');
		if (File.Exists(fullIncludePath))
			lock (tasks)
				tasks.Add(CreateFlatFile(fullIncludePath, false));

		var substitutedPath = FlatPath(fullIncludePath);
		if (dme)
			substitutedPath = $"{FlatDirectoryName}\\{substitutedPath}";
		fileContents = fileContents
			.Replace(match.Value, $"#include{match.Groups[1].Value}\"{substitutedPath}\"");
	}

	var flatFileName = Path.GetFullPath(
		dme
			? path.Replace(".dme", ".flat.dme")
			: Path.Combine(FlatDirectoryName, FlatPath(path)));

	await File.WriteAllTextAsync(
		flatFileName,
		fileContents);

	lock(outputLines)
		outputLines.Add($"\"{Path.GetFullPath(path)}\" => \"{flatFileName}\"{(matches.Count > 0 ? $" ({matches.Count} adapted #includes)" : String.Empty)}");
}

if (Directory.Exists(FlatDirectoryName))
	Directory.Delete(FlatDirectoryName, true);

var dmeFile = Directory.EnumerateFiles(
	Environment.CurrentDirectory,
	"*.dme",
	SearchOption.TopDirectoryOnly)
	.Single(x => !x.EndsWith(".flat.dme"));

Directory.CreateDirectory(FlatDirectoryName);

await CreateFlatFile(dmeFile, true);

await Task.WhenAll(tasks);

foreach (var outputLine in outputLines.OrderBy(line => line))
	Console.WriteLine(outputLine);
