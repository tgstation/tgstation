import { EnscribedName } from './EnscribedName';
import { Loadouts } from './Loadouts';
import { Randomize } from './Randomize';
import { TableOfContents } from './TableOfContents';
import type { TabType } from './types';

export const TAB2NAME: TabType[] = [
  {
    title: 'Enscribed Name',
    blurb:
      "This book answers only to its owner, and of course, must have one. The permanence of the pact between a spellbook and its owner ensures such a powerful artifact cannot fall into enemy hands, or be used in ways that break the Federation's rules such as bartering spells.",
    component: EnscribedName,
  },
  {
    title: 'Table of Contents',
    component: TableOfContents,
  },
  {
    title: 'Offensive',
    blurb: 'Spells and items geared towards debilitating and destroying.',
    scrollable: true,
  },
  {
    title: 'Defensive',
    blurb:
      "Spells and items geared towards improving your survivability or reducing foes' ability to attack.",
    scrollable: true,
  },
  {
    title: 'Mobility',
    blurb:
      'Spells and items geared towards improving your ability to move. It is a good idea to take at least one.',
    scrollable: true,
  },
  {
    title: 'Assistance',
    blurb:
      'Spells and items geared towards bringing in outside forces to aid you or improving upon your other items and abilities.',
    scrollable: true,
  },
  {
    title: 'Challenges',
    blurb:
      'The Wizard Federation is looking for shows of power. Arming the station against you will increase the danger, but will grant you more charges for your spellbook.',
    locked: true,
    scrollable: true,
  },
  {
    title: 'Rituals',
    blurb:
      'These powerful spells change the very fabric of reality. Not always in your favour.',
    scrollable: true,
  },
  {
    title: 'Loadouts',
    blurb:
      'The Wizard Federation accepts that sometimes, choosing is hard. You can choose from some approved wizard loadouts here.',
    component: Loadouts,
  },
  {
    title: 'Randomize',
    blurb:
      "If you didn't like the loadouts offered, you can embrace chaos. Not recommended for newer wizards.",
    component: Randomize,
  },
  {
    title: 'Perks',
    blurb:
      'Perks are useful (and not so useful) improvements to the soul and body collected from all corners of the universe.',
    scrollable: true,
  },
  {
    title: 'Table of Contents',
    component: TableOfContents,
  },
];

export const BUYWORD2ICON = {
  Learn: 'plus',
  Summon: 'hat-wizard',
  Cast: 'meteor',
};
