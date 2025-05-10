import { ComponentProps } from 'react';
import { Floating } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

export type PodLauncherData = {
  bayNumber: string;
  custom_rev_delay: number;
  customDropoff: BooleanLike;
  damageChoice: number;
  defaultSoundVolume: number;
  delays: Record<string, number>;
  effectAnnounce: BooleanLike;
  effectBluespace: BooleanLike;
  effectBurst: BooleanLike;
  effectCircle: BooleanLike;
  effectLimb: BooleanLike;
  effectMissile: BooleanLike;
  effectName: number;
  effectOrgans: BooleanLike;
  effectQuiet: BooleanLike;
  effectReverse: BooleanLike;
  effectShrapnel: BooleanLike;
  effectStealth: BooleanLike;
  effectStun: BooleanLike;
  effectTarget: string | null;
  explosionChoice: number;
  fallingSound: BooleanLike;
  giveLauncher: BooleanLike;
  landingSound: string | null;
  launchChoice: number;
  launchClone: BooleanLike;
  launchRandomItem: BooleanLike;
  leavingSound: string | null;
  mapRef: string;
  numObjects: number;
  oldArea: string | null;
  openingSound: string | null;
  payload: BooleanLike;
  picking_dropoff_turf: BooleanLike;
  podDesc: string;
  podName: string;
  rev_delays: Record<string, number>;
  reverse_option_list: Record<string, BooleanLike>;
  shrapnelMagnitude: number;
  shrapnelType: string;
  soundVolume: number;
  styleChoice: string;
  podStyles: Array<Record<string, string>>;
};

export type PodDelay = {
  title: string;
  tooltip: string;
};

export type PodEffect =
  | {
      act: string;
      choiceNumber?: number;
      content?: string;
      details?: boolean;
      divider?: never;
      icon: string;
      payload?: Record<string, any>;
      selected?: string;
      soloSelected?: string;
      title: string;
      tooltipPosition?: ComponentProps<typeof Floating>['placement'];
    }
  | { divider: boolean };
