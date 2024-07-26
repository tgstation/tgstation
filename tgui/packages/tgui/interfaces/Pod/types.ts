import { BooleanLike } from 'common/react';

export type Part = {
  name: string;
  desc: string;
  type?: string;
};

export type PodData = {
  name: string;
  power: number;
  maxPower: number;
  health: number;
  maxHealth: number;
  acceleration: number;
  maxAcceleration: number;
  cabinPressure: number;
  headlightsEnabled: BooleanLike;
  parts: Part[];
};
