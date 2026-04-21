import type { Coordinates } from '../common/Connections';

export type AppearanceDebugData = {
  mainAppearance: AppearanceData;
  planeToText: Record<string, number>;
  layerToText: Record<string, number>;
  mapRef: string;
};

export enum AppearanceType {
  MutableAppearance = 'appearance',
  Image = 'image',
}

export type FilterData = {
  type: string;
  name: string;
};

export const APPEARANCE_FLAGS = {
  LONG_GLIDE: 0,
  RESET_COLOR: 1,
  RESET_ALPHA: 2,
  RESET_TRANSFORM: 3,
  NO_CLIENT_COLOR: 4,
  KEEP_TOGETHER: 5,
  KEEP_APART: 6,
  PLANE_MASTER: 7,
  TILE_BOUND: 8,
  PIXEL_SCALE: 9,
  PASS_MOUSE: 10,
  TILE_MOVER: 11,
};

export const VIS_FLAGS = {
  VIS_INHERIT_ICON: 0,
  VIS_INHERIT_ICON_STATE: 1,
  VIS_INHERIT_DIR: 2,
  VIS_INHERIT_LAYER: 3,
  VIS_INHERIT_PLANE: 4,
  VIS_INHERIT_ID: 5,
  VIS_UNDERLAY: 6,
  VIS_HIDE: 7,
};

export const MOUSE_OPACITY = {
  TRANSPARENT: 0,
  ICON: 1,
  OPAQUE: 2,
};

export const BLEND_MODE = {
  BLEND_DEFAULT: 0,
  BLEND_OVERLAY: 1,
  BLEND_ADD: 2,
  BLEND_SUBTRACT: 3,
  BLEND_MULTIPLY: 4,
  BLEND_INSET_OVERLAY: 5,
};

export type AppearanceData = {
  type: AppearanceType;
  id: number;
  alpha: number;
  flags: number;
  blend_mode: number;
  color: string | number[];
  dir: number | null;
  filters: FilterData[];
  icon: string;
  icon_state: string;
  invisibility: number;
  underlays: AppearanceData[];
  overlays: AppearanceData[];
  layer: number;
  layer_text_override: string | null;
  name: string;
  maptext: string | null;
  maptext_width: number;
  maptext_height: number;
  maptext_x: number;
  maptext_y: number;
  mouse_opacity: number;
  pixel_x: number;
  pixel_y: number;
  pixel_w: number;
  pixel_z: number;
  plane: number;
  plane_true: number;
  render_source: string | null;
  render_target: string | null;
  screen_loc: string | null;
  transform: number[];
  embed_icon: string | null;
  vis_flags: number | null;
};

export enum AppearanceParentType {
  None = 0,
  Underlay = 1,
  Overlay = 2,
}

export type Appearance = {
  data: AppearanceData;
  underlays: Appearance[] | null;
  overlays: Appearance[] | null;
  parent: Appearance | null;
  parent_type: AppearanceParentType;
  render_target_to: Appearance[] | null;
  position: Coordinates;
  depth: number;
};

export type AppearanceMap = Record<number, Appearance>;
