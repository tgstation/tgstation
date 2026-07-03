import type { BooleanLike } from 'tgui-core/react';

import type { MapData } from '../common/NanoMap';

export type CrewSensor = {
  name: string;
  assignment: string | undefined;
  ijob: number;
  life_status: number;
  oxydam: number;
  toxdam: number;
  burndam: number;
  brutedam: number;
  position: Position | undefined;
  health: number;
  can_track: BooleanLike;
  ref: string;
};

export type Position = {
  area: string;
  x: number;
  y: number;
  z: number;
};

export type CrewConsoleData = {
  sensors: CrewSensor[];
  link_allowed: BooleanLike;
  mapData: MapData;
};
