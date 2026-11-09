export const loadedMappings: Record<string, string> = {};

export function resolveAsset(name: string): string {
  return loadedMappings[name] || name;
}
