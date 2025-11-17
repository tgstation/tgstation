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

export const bitflagInfo = [
  {
    flag: 'BRUTE',
    icon: 'gavel',
    tooltip: 'Produces a reagent that heals or deals brute damage.',
    category: 'Affects',
    toggle: 'toggle_tag_brute', // future todo : just make this use ui state
  },
  {
    flag: 'BURN',
    icon: 'burn',
    tooltip: 'Produces a reagent that heals or deals burn damage.',
    category: 'Affects',
    toggle: 'toggle_tag_burn',
  },
  {
    flag: 'TOXIN',
    icon: 'biohazard',
    tooltip: 'Produces a reagent that heals or deals toxin damage.',
    category: 'Affects',
    toggle: 'toggle_tag_toxin',
  },
  {
    flag: 'OXY',
    icon: 'wind',
    tooltip: 'Produces a reagent that heals or deals suffocation damage.',
    category: 'Affects',
    toggle: 'toggle_tag_oxy',
  },
  {
    flag: 'HEALING',
    icon: 'medkit',
    tooltip: 'Produces a healing reagent.',
    category: 'Type',
    toggle: 'toggle_tag_healing',
  },
  {
    flag: 'DAMAGING',
    icon: 'skull-crossbones',
    tooltip: 'Produces a damaging reagent.',
    category: 'Type',
    toggle: 'toggle_tag_damaging',
  },
  {
    flag: 'EXPLOSIVE',
    icon: 'bomb',
    tooltip: 'Produces a reagent that explodes or explodes on reaction.',
    category: 'Type',
    toggle: 'toggle_tag_explosive',
  },
  {
    flag: 'OTHER',
    icon: 'question',
    tooltip: 'Produces a reagent with some other side effect.',
    category: 'Affects',
    toggle: 'toggle_tag_other',
  },
  {
    flag: 'DANGEROUS',
    icon: 'exclamation-triangle',
    tooltip: 'Reaction may have a dangerous immediate effect.',
    category: 'Difficulty',
    toggle: 'toggle_tag_dangerous',
  },
  {
    flag: 'EASY',
    icon: 'chess-pawn',
    tooltip: 'Easy to perform reaction.',
    category: 'Difficulty',
    toggle: 'toggle_tag_easy',
  },
  {
    flag: 'MODERATE',
    icon: 'chess-knight',
    tooltip: 'Moderate difficulty reaction.',
    category: 'Difficulty',
    toggle: 'toggle_tag_moderate',
  },
  {
    flag: 'HARD',
    icon: 'chess-queen',
    tooltip: 'Hard to perform reaction.',
    category: 'Difficulty',
    toggle: 'toggle_tag_hard',
  },
  {
    flag: 'ORGAN',
    icon: 'brain',
    tooltip: 'Produces a reagent that heals or deals organ damage.',
    category: 'Affects',
    toggle: 'toggle_tag_organ',
  },
  {
    flag: 'DRINK',
    icon: 'cocktail',
    tooltip: 'Produces a drinkable reagent. Usually performed in the bar.',
    category: 'Type',
    toggle: 'toggle_tag_drink',
  },
  {
    flag: 'FOOD',
    icon: 'drumstick-bite',
    tooltip: 'Produces a food. Usually performed in the kitchen.',
    category: 'Type',
    toggle: 'toggle_tag_food',
  },
  {
    flag: 'SLIME',
    icon: 'microscope',
    tooltip: 'A reaction related to Xenobiology.',
    category: 'Type',
    toggle: 'toggle_tag_slime',
  },
  {
    flag: 'DRUG',
    icon: 'pills',
    tooltip:
      'Produces an addictive reagent with positive and negative effects.',
    category: 'Type',
    toggle: 'toggle_tag_drug',
  },
  {
    flag: 'UNIQUE',
    icon: 'puzzle-piece',
    tooltip: 'A unique or special reaction.',
    category: 'Type',
    toggle: 'toggle_tag_unique',
  },
  {
    flag: 'CHEMICAL',
    icon: 'flask',
    tooltip: 'Produces a reagent which alters other reactions.',
    category: 'Affects',
    toggle: 'toggle_tag_chemical',
  },
  {
    flag: 'PLANT',
    icon: 'seedling',
    tooltip: 'Produces a reagent that can help or harm plants.',
    category: 'Affects',
    toggle: 'toggle_tag_plant',
  },
  {
    flag: 'COMPETITIVE',
    icon: 'recycle',
    tooltip: 'A reaction that competes with other reactions.',
    category: 'Difficulty',
    toggle: 'toggle_tag_competitive',
  },
  {
    flag: 'COMPONENT',
    icon: 'question',
    tooltip: 'Produces a reagent commonly used in other reactions.',
    category: 'Type',
    toggle: 'toggle_tag_component',
  },
  {
    flag: 'ACTIVE',
    icon: 'question',
    tooltip: 'Reaction has an active, immediate effect.',
    category: 'Type',
    toggle: 'toggle_tag_active',
  },
];
