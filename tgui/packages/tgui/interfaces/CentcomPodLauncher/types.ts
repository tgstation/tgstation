import { BooleanLike } from 'common/react';

export type PodLauncherData = {
  bayNumber: string;
  custom_rev_delay: number;
  customDropoff: BooleanLike;
  defaultSoundVolume: number;
  delays: number[];
  effectName: number;
  effectReverse: BooleanLike;
  effectShrapnel: BooleanLike;
  giveLauncher: BooleanLike;
  mapRef: string;
  oldArea: string;
  payload: number;
  picking_dropoff_turf: BooleanLike;
  renderLighting: BooleanLike;
  rev_delays: number[];
  shrapnelMagnitude: number;
  shrapnelType: string;
  soundVolume: number;
  styleChoice: number;
};
