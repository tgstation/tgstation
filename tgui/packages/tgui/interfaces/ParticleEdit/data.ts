export const RandTypes = [
  'UNIFORM_RAND',
  'NORMAL_RAND',
  'LINEAR_RAND',
  'SQUARE_RAND',
];
export const RandToNumber = {
  UNIFORM_RAND: 1,
  NORMAL_RAND: 2,
  LINEAR_RAND: 3,
  SQUARE_RAND: 4,
};

export const P_DATA_GENERATOR = 'generator';
export const P_DATA_ICON_ADD = 'icon_add';
export const P_DATA_ICON_REMOVE = 'icon_remove';
export const P_DATA_ICON_WEIGHT = 'icon_edit';

export const MatrixTypes = [
  'Simple Matrix',
  'Complex Matrix',
  'Projection Matrix',
];

export const SpaceTypes = [
  'COLORSPACE_RGB',
  'COLORSPACE_HSV',
  'COLORSPACE_HSL',
  'COLORSPACE_HCY',
];
export const SpaceToNum = {
  COLORSPACE_RGB: 0,
  COLORSPACE_HSV: 1,
  COLORSPACE_HSL: 2,
  COLORSPACE_HCY: 3,
};

export const GeneratorTypes = [
  'num',
  'vector',
  'box',
  'color',
  'circle',
  'sphere',
  'square',
  'cube',
];

export const GeneratorTypesNoVectors = [
  'num',
  'color',
  'circle',
  'sphere',
  'square',
  'cube',
];

export type ParticleUIData = {
  target_name: string;
  particle_data: ParticleData;
};

type ParticleData = {
  width: number;
  height: number;
  count: number;
  spawning: number;
  bound1: number[];
  bound2: number[];
  gravity?: number[];
  gradient?: (string | number)[];
  transform?: number[];

  icon?: string | { [key: string]: number };
  icon_state?: string | { [key: string]: number };
  lifespan?: number | string[];
  fade?: number | string[];
  fadein?: number | string[];
  color?: number | string | string[];
  color_change?: number | string[];
  position?: number[] | string[];
  velocity?: number[] | string[];
  scale?: number | number[] | string[];
  grow?: number | number[] | string[];
  rotation?: number | string[];
  spin?: number | string[];
  friction?: number | string[];

  drift?: number[] | string[];
};

export type EntryFloatProps = {
  name: string;
  var_name: string;
  float: number;
};

export type EntryCoordProps = {
  name: string;
  var_name: string;
  coord?: number[];
};

/** @see https://ref.harry.live/proc/gradient */
export type Gradient = string | number | Record<string, number>;

export type EntryGradientProps = {
  name: string;
  var_name: string;
  gradient?: Gradient[];
};

export type EntryTransformProps = {
  name: string;
  var_name: string;
  transform?: number[];
};

export type EntryIconStateProps = {
  name: string;
  var_name: string;
  icon_state?: string | { [key: string]: number };
};

export type FloatGeneratorProps = {
  name: string;
  var_name: string;
  float?: number | string[];
};

export type FloatGeneratorColorProps = {
  name: string;
  var_name: string;
  float?: number | string | string[];
};

export type GeneratorProps = {
  var_name: string;
  generator?: string[];
  allow_vectors?: boolean;
};

export type EntryGeneratorNumbersListProps = {
  name: string;
  var_name: string;
  allow_z: boolean;
  input?: number | number[] | string[];
};
