import type { Dispatch, SetStateAction } from 'react';
import type { BooleanLike } from 'tgui-core/react';

export type ReagentsData = {
  beakerSync: BooleanLike;
  bitflags: Record<string, number>;
  currentReagents: string[];
  linkedBeaker: string;
  master_reaction_list: Reaction[];
  reagent_mode_reagent: Reagent | null;
  reagent_mode_recipe: Recipe | null;
  selectedBitflags: number;
};

export type ReagentsProps = {
  pageState: [number, Dispatch<SetStateAction<number>>];
};

type Pairs = [
  [number, number],
  [number, number],
  [number, number],
  [number, number],
];

export type Recipe = {
  catalysts: Reagent[];
  explodeTemp: number;
  explosive: Pairs;
  hasProduct: BooleanLike;
  id: string;
  inversePurity: string;
  isColdRecipe: BooleanLike;
  lowerpH: number;
  minPurity: number;
  name: string;
  reactants: Reactant[];
  reagentCol: string;
  reqContainer: string | null;
  subReactIndex: number;
  subReactLen: number;
  tempMin: number;
  thermics: string;
  thermodynamics: Pairs;
  thermoUpper: number;
  upperpH: number;
};

type Reactant = {
  color: string;
  id: string;
  name: string;
  ratio: number;
  tooltip: string | null;
  tooltipBool: BooleanLike;
};

export type Reagent = {
  addictions: string[];
  desc: string;
  id: string;
  metaRate: number;
  name: string;
  OD: number;
  pH: number;
  pHCol: string;
  reagentCol: string;
};

type ReactionReagent = {
  id: string;
  name: string;
};

export type Reaction = {
  bitflags: number;
  id: string;
  name: string;
  reactants: ReactionReagent[];
};
