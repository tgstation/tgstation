export function formatDeps(text: string): Record<string, string> {
  return text
    .split("\n")
    .map((statement) => statement.replace("export", "").trim())
    .filter((value) => !(value === "" || value.startsWith("#")))
    .map((statement) => statement.split("="))
    .reduce((acc, kv_pair) => {
      acc[kv_pair[0]] = kv_pair[1];
      return acc;
    }, {});
}
