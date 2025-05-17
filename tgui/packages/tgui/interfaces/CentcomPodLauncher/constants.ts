import { TabBay, TabDrop, TabPod } from './Tabs';
import { PodDelay, PodEffect } from './types';

export const POD_GREY = {
  color: 'grey',
} as const;

export const TABPAGES = [
  {
    title: 'View Pod',
    component: TabPod,
  },
  {
    title: 'View Bay',
    component: TabBay,
  },
  {
    title: 'View Dropoff Location',
    component: TabDrop,
  },
] as const;

type Option = {
  title: string;
  key?: string;
  icon?: string;
};

export const REVERSE_OPTIONS: Option[] = [
  {
    title: 'Mobs',
    icon: 'user',
  },
  {
    title: 'Unanchored\nObjects',
    key: 'Unanchored',
    icon: 'cube',
  },
  {
    title: 'Anchored\nObjects',
    key: 'Anchored',
    icon: 'anchor',
  },
  {
    title: 'Under-Floor',
    key: 'Underfloor',
    icon: 'eye-slash',
  },
  {
    title: 'Wall-Mounted',
    key: 'Wallmounted',
    icon: 'link',
  },
  {
    title: 'Floors',
    icon: 'border-all',
  },
  {
    title: 'Walls',
    icon: 'square',
  },
  {
    title: 'Mechs',
    key: 'Mecha',
    icon: 'truck',
  },
];

export const DELAYS: PodDelay[] = [
  {
    title: 'Pre',
    tooltip: 'Time until pod gets to station',
  },
  {
    title: 'Fall',
    tooltip: 'Duration of pods\nfalling animation',
  },
  {
    title: 'Open',
    tooltip: 'Time it takes pod to open after landing',
  },
  {
    title: 'Exit',
    tooltip: 'Time for pod to\nleave after opening',
  },
];

export const REV_DELAYS: PodDelay[] = [
  {
    title: 'Pre',
    tooltip: 'Time until pod appears above dropoff point',
  },
  {
    title: 'Fall',
    tooltip: 'Duration of pods\nfalling animation',
  },
  {
    title: 'Open',
    tooltip: 'Time it takes pod to open after landing',
  },
  {
    title: 'Exit',
    tooltip: 'Time for pod to\nleave after opening',
  },
];

export const SOUNDS = [
  {
    title: 'Fall',
    act: 'fallingSound',
    tooltip: 'Plays during fall, ends on land',
  },
  {
    title: 'Land',
    act: 'landingSound',
    tooltip: 'Plays after pod lands',
  },
  {
    title: 'Open',
    act: 'openingSound',
    tooltip: 'Plays when pod opens',
  },
  {
    title: 'Exit',
    act: 'leavingSound',
    tooltip: 'Plays when pod leaves',
  },
];

export const BAYS = [
  { title: '1' },
  { title: '2' },
  { title: '3' },
  { title: '4' },
  { title: 'ERT' },
] as const;

export const EFFECTS_LOAD: PodEffect[] = [
  {
    act: 'launchAll',
    choiceNumber: 0,
    icon: 'globe',
    selected: 'launchChoice',
    title: 'Launch All Turfs',
  },
  {
    act: 'launchOrdered',
    choiceNumber: 1,
    icon: 'sort-amount-down-alt',
    selected: 'launchChoice',
    title: 'Launch Turf Ordered',
  },
  {
    act: 'launchRandomTurf',
    choiceNumber: 2,
    icon: 'dice',
    selected: 'launchChoice',
    title: 'Pick Random Turf',
  },
  {
    divider: true,
  },
  {
    act: 'launchWholeTurf',
    choiceNumber: 0,
    icon: 'expand',
    selected: 'launchRandomItem',
    title: 'Launch Whole Turf',
  },
  {
    act: 'launchRandomItem',
    choiceNumber: 1,
    icon: 'dice',
    selected: 'launchRandomItem',
    title: 'Pick Random Item',
  },
  {
    divider: true,
  },
  {
    act: 'launchClone',
    icon: 'clone',
    soloSelected: 'launchClone',
    title: 'Clone',
  },
];

export const EFFECTS_NORMAL: PodEffect[] = [
  {
    act: 'effectTarget',
    icon: 'user-check',
    soloSelected: 'effectTarget',
    title: 'Specific Target',
  },
  {
    act: 'effectBluespace',
    choiceNumber: 0,
    icon: 'hand-paper',
    selected: 'effectBluespace',
    title: 'Pod Stays',
  },
  {
    act: 'effectStealth',
    icon: 'user-ninja',
    soloSelected: 'effectStealth',
    title: 'Stealth',
  },
  {
    act: 'effectQuiet',
    icon: 'volume-mute',
    soloSelected: 'effectQuiet',
    title: 'Quiet',
  },
  {
    act: 'effectMissile',
    icon: 'rocket',
    soloSelected: 'effectMissile',
    title: 'Missile Mode',
  },
  {
    act: 'effectBurst',
    icon: 'certificate',
    soloSelected: 'effectBurst',
    title: 'Burst Launch',
  },
  {
    act: 'effectCircle',
    icon: 'ruler-combined',
    soloSelected: 'effectCircle',
    title: 'Any Descent Angle',
  },
  {
    act: 'effectAnnounce',
    choiceNumber: 0,
    icon: 'ghost',
    selected: 'effectAnnounce',
    title: 'No Ghost Alert\n(If you dont want to\nentertain bored ghosts)',
  },
];

export const EFFECTS_HARM: PodEffect[] = [
  {
    act: 'create_sparks',
    choiceNumber: 1,
    icon: 'certificate',
    selected: 'create_sparks',
    title: 'Create sparks; May cause fires if there is plasma in the air',
  },
  {
    divider: true,
  },
  {
    act: 'explosionCustom',
    choiceNumber: 1,
    icon: 'bomb',
    selected: 'explosionChoice',
    title: 'Explosion Custom',
  },
  {
    act: 'explosionBus',
    choiceNumber: 2,
    icon: 'bomb',
    selected: 'explosionChoice',
    title: 'Adminbus Explosion\nWhat are they gonna do, ban you?',
  },
  {
    divider: true,
  },
  {
    act: 'damageCustom',
    choiceNumber: 1,
    icon: 'skull',
    selected: 'damageChoice',
    title: 'Custom Damage',
  },
  {
    act: 'damageGib',
    choiceNumber: 2,
    icon: 'skull-crossbones',
    selected: 'damageChoice',
    title: 'Gib',
  },
  {
    divider: true,
  },
  {
    act: 'effectShrapnel',
    details: true,
    icon: 'cloud-meatball',
    soloSelected: 'effectShrapnel',
    title: 'Projectile Cloud',
  },
  {
    act: 'effectStun',
    icon: 'sun',
    soloSelected: 'effectStun',
    title: 'Stun',
  },
  {
    act: 'effectLimb',
    icon: 'socks',
    soloSelected: 'effectLimb',
    title: 'Delimb',
  },
  {
    act: 'effectOrgans',
    icon: 'book-dead',
    soloSelected: 'effectOrgans',
    title: 'Yeet Organs',
  },
];

type Effect = {
  list: typeof EFFECTS_LOAD | typeof EFFECTS_NORMAL | typeof EFFECTS_HARM;
  label: string;
  alt_label?: string;
  tooltipPosition: string;
};

export const EFFECTS_ALL: Effect[] = [
  {
    list: EFFECTS_LOAD,
    label: 'Load From',
    alt_label: 'Load',
    tooltipPosition: 'right',
  },
  {
    list: EFFECTS_NORMAL,
    label: 'Normal Effects',
    tooltipPosition: 'bottom',
  },
  {
    list: EFFECTS_HARM,
    label: 'Harmful Effects',
    tooltipPosition: 'bottom',
  },
];
