import type { BooleanLike } from 'tgui-core/react';

export enum SpellCategory {
  Offensive = 'Offensive',
  Defensive = 'Defensive',
  Mobility = 'Mobility',
  Assistance = 'Assistance',
  Rituals = 'Rituals',
  Perks = 'Perks',
}

export type SpellEntry = {
  // Name of the spell
  name: string;
  // Description of what the spell does
  desc: string;
  // Byond REF of the spell entry datum
  ref: string;
  // Whether the spell requires wizard clothing to cast
  requires_wizard_garb: BooleanLike;
  // Spell points required to buy the spell
  cost: number;
  // How many times the spell has been bought
  times: number;
  // Cooldown length of the spell once cast once
  cooldown: number;
  // Category of the spell
  cat: SpellCategory;
  // Whether the spell is refundable
  refundable: BooleanLike;
  // The verb displayed when buying
  buyword: Buywords;
};

export type SpellbookData = {
  owner: string;
  points: number;
  semi_random_bonus: number;
  full_random_bonus: number;
  entries: SpellEntry[];
};

export type TabType = {
  title: string;
} & Partial<{
  blurb: string;
  component: (props?: any) => React.JSX.Element;
  locked: boolean;
  scrollable: boolean;
}>;

export enum Buywords {
  Learn = 'Learn',
  Summon = 'Summon',
  Cast = 'Cast',
}

export enum Tab {
  EnscribedName = 0,
  TableOfContents = 1,
  Offensive = 2,
  Defensive = 3,
  Mobility = 4,
  Assistance = 5,
  Challenges = 6,
  Rituals = 7,
  Loadouts = 8,
  Randomize = 9,
  Perks = 10,
  TableOfContents2 = 11,
}
