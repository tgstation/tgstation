import { TabBay, TabDrop, TabPod } from './Tabs';

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

export const REVERSE_OPTIONS = [
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
] as const;

export const DELAYS = [
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
] as const;

export const REV_DELAYS = [
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
] as const;

export const SOUNDS = [
  {
    title: 'Fall',
    act: 'fallingSound',
    tooltip: 'Plays while pod falls, timed\nto end when pod lands',
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

export const STYLES = [
  { title: 'Standard' },
  { title: 'Advanced' },
  { title: 'Nanotrasen' },
  { title: 'Syndicate' },
  { title: 'Deathsquad' },
  { title: 'Cultist' },
  { title: 'Missile' },
  { title: 'Syndie Missile' },
  { title: 'Supply Box' },
  { title: 'Clown Pod' },
  { title: 'Fruit' },
  { title: 'Invisible' },
  { title: 'Gondola' },
  { title: 'Seethrough' },
] as const;

export const BAYS = [
  { title: '1' },
  { title: '2' },
  { title: '3' },
  { title: '4' },
  { title: 'ERT' },
] as const;

export const EFFECTS_LOAD = [
  {
    title: 'Launch All Turfs',
    icon: 'globe',
    choiceNumber: 0,
    selected: 'launchChoice',
    act: 'launchAll',
  },
  {
    title: 'Launch Turf Ordered',
    icon: 'sort-amount-down-alt',
    choiceNumber: 1,
    selected: 'launchChoice',
    act: 'launchOrdered',
  },
  {
    title: 'Pick Random Turf',
    icon: 'dice',
    choiceNumber: 2,
    selected: 'launchChoice',
    act: 'launchRandomTurf',
  },
  {
    divider: 1,
  },
  {
    title: 'Launch Whole Turf',
    icon: 'expand',
    choiceNumber: 0,
    selected: 'launchRandomItem',
    act: 'launchWholeTurf',
  },
  {
    title: 'Pick Random Item',
    icon: 'dice',
    choiceNumber: 1,
    selected: 'launchRandomItem',
    act: 'launchRandomItem',
  },
  {
    divider: 1,
  },
  {
    title: 'Clone',
    icon: 'clone',
    soloSelected: 'launchClone',
    act: 'launchClone',
  },
] as const;

export const EFFECTS_NORMAL = [
  {
    title: 'Specific Target',
    icon: 'user-check',
    soloSelected: 'effectTarget',
    act: 'effectTarget',
  },
  {
    title: 'Pod Stays',
    icon: 'hand-paper',
    choiceNumber: 0,
    selected: 'effectBluespace',
    act: 'effectBluespace',
  },
  {
    title: 'Stealth',
    icon: 'user-ninja',
    soloSelected: 'effectStealth',
    act: 'effectStealth',
  },
  {
    title: 'Quiet',
    icon: 'volume-mute',
    soloSelected: 'effectQuiet',
    act: 'effectQuiet',
  },
  {
    title: 'Missile Mode',
    icon: 'rocket',
    soloSelected: 'effectMissile',
    act: 'effectMissile',
  },
  {
    title: 'Burst Launch',
    icon: 'certificate',
    soloSelected: 'effectBurst',
    act: 'effectBurst',
  },
  {
    title: 'Any Descent Angle',
    icon: 'ruler-combined',
    soloSelected: 'effectCircle',
    act: 'effectCircle',
  },
  {
    title: 'No Ghost Alert\n(If you dont want to\nentertain bored ghosts)',
    icon: 'ghost',
    choiceNumber: 0,
    selected: 'effectAnnounce',
    act: 'effectAnnounce',
  },
] as const;

export const EFFECTS_HARM = [
  {
    title: 'Explosion Custom',
    icon: 'bomb',
    choiceNumber: 1,
    selected: 'explosionChoice',
    act: 'explosionCustom',
  },
  {
    title: 'Adminbus Explosion\nWhat are they gonna do, ban you?',
    icon: 'bomb',
    choiceNumber: 2,
    selected: 'explosionChoice',
    act: 'explosionBus',
  },
  {
    divider: 1,
  },
  {
    title: 'Custom Damage',
    icon: 'skull',
    choiceNumber: 1,
    selected: 'damageChoice',
    act: 'damageCustom',
  },
  {
    title: 'Gib',
    icon: 'skull-crossbones',
    choiceNumber: 2,
    selected: 'damageChoice',
    act: 'damageGib',
  },
  {
    divider: 1,
  },
  {
    title: 'Projectile Cloud',
    details: true,
    icon: 'cloud-meatball',
    soloSelected: 'effectShrapnel',
    act: 'effectShrapnel',
  },
  {
    title: 'Stun',
    icon: 'sun',
    soloSelected: 'effectStun',
    act: 'effectStun',
  },
  {
    title: 'Delimb',
    icon: 'socks',
    soloSelected: 'effectLimb',
    act: 'effectLimb',
  },
  {
    title: 'Yeet Organs',
    icon: 'book-dead',
    soloSelected: 'effectOrgans',
    act: 'effectOrgans',
  },
];

export const EFFECTS_ALL = [
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
] as const;
