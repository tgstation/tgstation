import type { BooleanLike } from 'tgui-core/react';
import { CATEGORY_ICONS_COOKING, CATEGORY_ICONS_CRAFTING } from './constants';
import type { CraftingData } from './types';

export function findIcon(atom_id: number, data: CraftingData): string {
  let icon: string = data.icon_data[atom_id];
  if (!icon) {
    icon = `${data.mode ? 'cooking32x32' : 'crafting32x32'} a${atom_id}`;
  }

  return icon;
}

export function getFAIcon(category: string, mode: BooleanLike): string {
  const icons = mode ? CATEGORY_ICONS_COOKING : CATEGORY_ICONS_CRAFTING;
  return icons[category] || 'circle';
}
