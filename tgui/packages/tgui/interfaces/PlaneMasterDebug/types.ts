import { BooleanLike } from 'tgui-core/react';

import { Position } from '../common/Connections';

export type PlaneDebugData = {
  mob_name: string;
  mob_ref: string;
  our_ref: string;
  tracking_active: BooleanLike;
  enable_group_view: BooleanLike;
  our_group: string;
  present_groups: string[];
  planes: PlaneData[];
};

export type PlaneData = {
  name: string;
  documentation: string;
  plane: number;
  offset: number;
  real_plane: number;
  renders_onto: number[];
  blend_mode: string;
  color: string | number[];
  alpha: number;
  render_target: string;
  force_hidden: BooleanLike;
  relays: RelayData[];
  filters: FilterData[];
};

export type RelayData = {
  name: string;
  source: number;
  target: number;
  layer: number;
  blend_mode: string;
  our_ref: string;
};

export type FilterData = {
  name: string;
  render_source: string;
  our_ref: string;
  type: string;
  // For layering filters
  blend_mode?: string;
};

export type Plane = {
  name: string;
  documentation: string;
  plane: number;
  offset: number;
  real_plane: number;
  renders_onto: Plane[];
  blend_mode: string;
  color: string | number[];
  alpha: number;
  render_target: string;
  force_hidden: boolean;
  incoming_relays: Relay[];
  incoming_filters: Filter[];
  outgoing_relays: Relay[];
  outgoing_filters: Filter[];
  position: Position;
  parents: Plane[];
  depth: number;
};

export type Relay = {
  name: string;
  source?: Plane;
  target?: Plane;
  layer: number;
  blend_mode: string;
  our_ref: string;
  node_color: string;
};

export type Filter = {
  name: string;
  source?: Plane;
  target?: Plane;
  our_ref: string;
  type: string;
  // For layering filters
  blend_mode?: string;
  node_color: string;
};

export const BlendColors = {
  BLEND_DEFAULT: undefined,
  BLEND_OVERLAY: 'white',
  BLEND_ADD: 'olive',
  BLEND_SUBTRACT: 'red',
  BLEND_MULTIPLY: 'orange',
  BLEND_INSET_OVERLAY: 'teal',
};

export enum BlendModes {
  BLEND_DEFAULT,
  BLEND_OVERLAY,
  BLEND_ADD,
  BLEND_SUBTRACT,
  BLEND_MULTIPLY,
  BLEND_INSET_OVERLAY,
}

export type PlaneMap = Record<number, Plane>;
export type PlaneTargetMap = Record<string, Plane>;
export type PlaneConnectionsMap = Record<string, PlaneConnection>;
export type PlaneConnectorsMap = Record<string, PlaneConnectorElement>;

export type PlaneConnectorElement = {
  // Both of these are relay/filter ref -> HTMLElement for that input/output
  input?: HTMLElement;
  output?: HTMLElement;
};

export type PlaneConnection = {
  // Both of these are relay/filter ref -> coordinates for that input/output
  input: Position;
  output: Position;
};

export type PlaneHighlight = {
  // Must be numbers as actual Plane objects are constantly regenerated
  source: number;
  target: number;
};
