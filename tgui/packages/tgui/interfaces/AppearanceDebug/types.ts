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
  Atom = 'atom',
}

export type FilterData = {
  type: string;
  name: string;
};

export const APPEARANCE_FLAGS = {
  LONG_GLIDE: 1,
  RESET_COLOR: 2,
  RESET_ALPHA: 4,
  RESET_TRANSFORM: 8,
  NO_CLIENT_COLOR: 16,
  KEEP_TOGETHER: 32,
  KEEP_APART: 64,
  PLANE_MASTER: 128,
  TILE_BOUND: 256,
  PIXEL_SCALE: 512,
  PASS_MOUSE: 1024,
  TILE_MOVER: 2048,
};

export const VIS_FLAGS = {
  VIS_INHERIT_ICON: 1,
  VIS_INHERIT_ICON_STATE: 2,
  VIS_INHERIT_DIR: 4,
  VIS_INHERIT_LAYER: 8,
  VIS_INHERIT_PLANE: 16,
  VIS_INHERIT_ID: 32,
  VIS_UNDERLAY: 64,
  VIS_HIDE: 128,
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
  vis_contents: AppearanceData[] | null;
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
  boundingBox: [Coordinates, Coordinates];
  parentType: AppearanceParentType;
  renderTargetTo: Appearance[] | null;
  relativePosition: Coordinates;
  depth: number;
};

export type AppearanceMap = Record<number, Appearance>;
