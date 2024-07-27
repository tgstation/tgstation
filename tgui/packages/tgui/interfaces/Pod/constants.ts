//import Example from './Parts/Example';
import WarpDrive from './Parts/WarpDrive';
import PINPart from './Parts/PINPart';
import { PodData } from './types';

export const TAGNAME2TAG = {
  // TODO: add a bit of docs.
  //Example: Example,
  WarpDrive: WarpDrive,
  PINPart: PINPart,
};

export const DataMock: PodData = {
  name: 'Pod 1',
  power: 200,
  maxPower: 500,
  maxHealth: 500,
  health: 1,
  acceleration: 10,
  maxAcceleration: 20,
  headlightsEnabled: 0,
  cabinPressure: 1013,
  parts: [
    { name: 'Part 1', desc: 'This is a very important part!' },
    { name: 'Part 2', desc: 'This part is less important...', type: 'Example' },
  ],
};
