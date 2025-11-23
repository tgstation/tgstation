import type { BooleanLike } from 'tgui-core/react';

export interface SpawnPreferences {
  hide_icons: boolean;
  hide_mappings: boolean;
  sort_by: string;
  search_text: string;
  search_by: string;
  where_dropdown_value: string;
  offset_type: string;
  offset: string;
  object_count: number;
  dir: number;
  object_name: string;
}

export interface SpawnPanelPreferences {
  hide_icons: boolean;
  hide_mappings: boolean;
  sort_by: string;
  search_text: string;
  search_by: string;
}

export interface AtomData {
  icon: string;
  icon_state: string;
  name: string;
  description?: string;
  mapping: BooleanLike;
  type: 'Objects' | 'Turfs' | 'Mobs';
}

export interface CreateObjectData {
  atoms: Record<string, AtomData>;
}

export interface CreateObjectProps {
  objList: CreateObjectData;
  setAdvancedSettings: (value: boolean) => void;
  iconSettings: {
    icon: string | null;
    iconState: string | null;
    iconSize: number;
  };
  onIconSettingsChange: (
    settings: Partial<{
      icon: string | null;
      iconState: string | null;
      iconSize: number;
    }>,
  ) => void;
}
