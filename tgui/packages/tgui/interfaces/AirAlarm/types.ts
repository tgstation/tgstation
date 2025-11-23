import type { BooleanLike } from 'tgui-core/react';

import type { ScrubberProps } from '../common/AtmosControls';
import type { VentProps } from '../common/AtmosControls';
import type { AIR_ALARM_ROUTES } from './AlarmControl';

type AlarmStatus = 0 | 1 | 2;

type EnvironmentData = {
  danger: AlarmStatus;
  name: string;
  value: string; // preformatted in backend, shorter code that way.
};

type Mode = {
  danger: BooleanLike;
  desc: string;
  name: string;
  path: string;
};

type TLVSettings = {
  hazard_max: number;
  hazard_min: number;
  id: string;
  name: string;
  unit: string;
  warning_max: number;
  warning_min: number;
};

export type AirAlarmData = {
  allowLinkChange: BooleanLike;
  atmosAlarm: BooleanLike; // fix this
  dangerLevel: AlarmStatus;
  emagged: BooleanLike;
  envData: EnvironmentData[];
  faultLocation: string;
  faultStatus: AlarmStatus;
  filteringPath: string;
  fireAlarm: BooleanLike;
  locked: BooleanLike;
  modes: Mode[];
  panicSiphonPath: string;
  scrubbers: ScrubberProps[];
  selectedModePath: string;
  sensor: BooleanLike;
  siliconUser: BooleanLike;
  thresholdTypeMap: Record<string, number>;
  tlvSettings: TLVSettings[];
  vents: VentProps[];
};

export type AlarmScreen = keyof typeof AIR_ALARM_ROUTES;

export type EditingModalProps = {
  finish: () => void;
  id: string;
  name: string;
  oldValue: number;
  type: number;
  typeName: string;
  typeVar: string;
  unit: string;
};

export type ActiveModal = Omit<EditingModalProps, 'oldValue'> | undefined;
