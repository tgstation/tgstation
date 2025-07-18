import type { CraftingData } from './types';

export function findIcon(atom_id: number, data: CraftingData): string {
  let icon: string = data.icon_data[atom_id];
  if (!icon) {
    icon = `${data.mode ? 'cooking32x32' : 'crafting32x32'} a${atom_id}`;
  }

  return icon;
}
