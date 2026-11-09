// ── Palette / label constants ─────────────────────────────────────────────────

export const CATEGORY_PALETTE: string[] = [
  '#4fc3f7',
  '#81c784',
  '#ffb74d',
  '#e57373',
  '#ba68c8',
  '#4dd0e1',
  '#fff176',
  '#f06292',
  '#a1887f',
  '#90a4ae',
];

export const LOG_TYPE_LABELS: Record<string, string> = {
  text: 'TXT',
  location: 'LOC',
  turfs: 'TURF',
  lines: 'LINE',
  path: 'PATH',
  maptext: 'MAPTXT',
};

export const LOG_TYPE_COLORS: Record<string, string> = {
  text: '#aaaaaa',
  location: '#4fc3f7',
  turfs: '#81c784',
  lines: '#ffb74d',
  path: '#ce93d8',
  maptext: '#ffe082',
};

// ── Data types ────────────────────────────────────────────────────────────────

export type Category = { name: string; enabled: boolean };

export type TrackInfoEntry = { category: string; title: string; entry: string };

export type BaseEvent = {
  id: number;
  tick: number;
  category: string;
  log_type: 'text' | 'location' | 'turfs' | 'lines' | 'path' | 'maptext';
  info: string;
  track_info?: TrackInfoEntry[];
};

export type TextEvent = BaseEvent & { log_type: 'text' };

export type LocationEvent = BaseEvent & {
  log_type: 'location';
  x: number;
  y: number;
  z: number;
};

export type TurfsEvent = BaseEvent & {
  log_type: 'turfs';
  coords: Array<{ x: number; y: number; z: number }>;
};

export type LinesEvent = BaseEvent & {
  log_type: 'lines';
  x1: number;
  y1: number;
  z1: number;
  x2: number;
  y2: number;
  z2: number;
};

export type PathEvent = BaseEvent & {
  log_type: 'path';
  coords: Array<{ x: number; y: number; z: number }>;
};

export type MapTextEvent = BaseEvent & {
  log_type: 'maptext';
  x: number;
  y: number;
  z: number;
  text: string;
};

export type EventEntry =
  | TextEvent
  | LocationEvent
  | TurfsEvent
  | LinesEvent
  | PathEvent
  | MapTextEvent;

export type InfoPair = { title: string; entry: string };

export type Track = {
  name: string;
  ref: string;
  events: EventEntry[];
  info: InfoPair[];
};

export type EventLoggerData = {
  running: boolean;
  time_start: number | null;
  time_current: number;
  categories: Category[];
  tracks: Track[];
  selected_ref: string | null;
  awaiting_pick: boolean;
};

// ── Helpers ───────────────────────────────────────────────────────────────────

export function buildCategoryColors(
  categories: Category[],
): Record<string, string> {
  const map: Record<string, string> = {};
  categories.forEach((cat, i) => {
    map[cat.name] = CATEGORY_PALETTE[i % CATEGORY_PALETTE.length];
  });
  return map;
}

export function getEventPrimaryCoord(
  evt: EventEntry,
): { x: number; y: number; z: number } | null {
  switch (evt.log_type) {
    case 'location':
    case 'maptext':
      return { x: evt.x, y: evt.y, z: evt.z };
    case 'turfs':
    case 'path':
      return evt.coords.length > 0 ? evt.coords[0] : null;
    case 'lines':
      return { x: evt.x1, y: evt.y1, z: evt.z1 };
    default:
      return null;
  }
}
