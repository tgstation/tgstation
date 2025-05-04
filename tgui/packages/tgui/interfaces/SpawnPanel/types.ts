export interface Data {
  [panelName: string]: CreateObjectData[];
}

export type SpawnPreferences = {
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
};

export type AtomData = {
  icon: string;
  icon_state: string;
  name: string;
  mapping: boolean;
};

export interface CreateObjectData {
  Objects: {
    [key: string]: AtomData;
  };
  Turfs: {
    [key: string]: AtomData;
  };
  Mobs: {
    [key: string]: AtomData;
  };
}

export interface CreateObjectProps {
  objList: CreateObjectData;
  setAdvancedSettings: (value: boolean) => void;
}
