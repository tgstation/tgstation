using System.Text.RegularExpressions;

var treeDefinition = false;
var baseDir = Environment.CurrentDirectory;

var allFiles = Directory.EnumerateFiles($@"{baseDir}\code", "*.dm", SearchOption.AllDirectories).ToList();

foreach (var file in allFiles)
{
	var armorDatum = String.Empty;
	var treeIdx = -1;
	var needsUpdate = false;
	var fileContents = File.ReadAllLines(file).ToList();
	var newContents = new List<string>();
	var fileTemp = new FileInfo($"{file}.tmp");
	var currentTree = String.Empty;
	for (var lineIdx = 0; lineIdx < fileContents.Count; lineIdx++)
	{
		var line = fileContents[lineIdx];
		newContents.Add(line);
		if (line == String.Empty)
			continue;

		if (treeDefinition && treeIdx is not -1)
		{
			if (line[0] == '/' && line[1] != '/' && line[1] != '*')
			{
				treeDefinition = false;
				if (!armorDatum.Equals(String.Empty))
				{
					newContents.Insert(newContents.Count - 1, armorDatum);
					armorDatum = String.Empty;
					needsUpdate = true;
				}
			}
			else if (line.StartsWith("\tarmor = list("))
			{
				Console.WriteLine($"Armor Definition at [{file}:{lineIdx}]: '{currentTree}' = {line}");
				var datumPath = $"/datum/armor/{currentTree}";
				newContents[^1] = $"\tarmor_type = {datumPath}";
				line = line[(line.IndexOf("(", StringComparison.Ordinal) + 1) .. line.LastIndexOf(")", StringComparison.Ordinal)];
				var armorValues = line.Split(",", StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);
				armorValues = armorValues.Where(v => v.Split("=", StringSplitOptions.TrimEntries)[1] != "0").ToArray();
				if (armorValues.Length == 0)
				{
					newContents[^1] = "\tarmor_type = /datum/armor/none";
					needsUpdate = true;
					continue;
				}
				armorDatum = $"/// Automatically generated armor datum, errors may exist\n{datumPath}\n";
				armorDatum = armorValues.Aggregate(armorDatum, (current, armorValue) => current + $"\t{armorValue.ToLower()}\n");
			}
		}

		var treeRegex = Regex.Match(line, @"^(/\w+)+(\s*//.*)?$");
		if (treeRegex.Success)
		{
			var endIdx = line.Contains("//") ? line.IndexOf("//", StringComparison.Ordinal) : line.Length;
			currentTree = line[..endIdx].Split("/", StringSplitOptions.TrimEntries)[^2..].Aggregate("", (s, s1) => $"{s}_{s1}")[1..];
			treeDefinition = true;
			treeIdx = lineIdx;
		}
	}

	if (treeDefinition && treeIdx is not -1)
	{
			treeDefinition = false;
			if (!armorDatum.Equals(String.Empty))
			{
				needsUpdate = true;
				newContents.Add("\n"+armorDatum[..^1]);
			}
	}

	if (needsUpdate)
	{
		var fStream = fileTemp.CreateText();
		foreach (var newLine in newContents)
			fStream.WriteLine(newLine);
		fStream.Close();
		File.Delete(file);
		fileTemp.MoveTo(file);
	}
}

Console.WriteLine($"Processed {allFiles.Count} files.");
