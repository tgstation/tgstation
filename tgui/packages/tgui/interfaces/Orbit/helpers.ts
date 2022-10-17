import { sortBy } from 'common/collections';
import { ANTAG2GROUP, HEALTH, THREAT } from './constants';
import type { AntagGroup, Antags, Observable } from './types';

/**
 * Collates antagonist groups into their own separate sections.
 * Some antags are grouped together lest they be listed separately,
 * ie: Nuclear Operatives. See: ANTAG_GROUPS.
 */
export const collateAntagonists = (antagonists: Antags) => {
  const collatedAntagonists = {}; // Hate that I cant use a map here
  antagonists.map((player) => {
    const { antag } = player;
    const resolvedName: string = ANTAG2GROUP[antag] || antag;
    if (!collatedAntagonists[resolvedName]) {
      collatedAntagonists[resolvedName] = [];
    }
    collatedAntagonists[resolvedName].push(player);
  });
  const sortedAntagonists = sortBy<AntagGroup>(([key]) => key)(
    Object.entries(collatedAntagonists)
  );

  return sortedAntagonists;
};

/** Returns a disguised name in case the person is wearing someone else's ID */
export const getDisplayName = (full_name: string, name?: string) => {
  if (!name) {
    return full_name;
  }
  if (
    !full_name?.includes('[') ||
    full_name.match(/\(as /) ||
    full_name.match(/^Unknown/)
  ) {
    return name;
  }
  // return only the name before the first ' [' or ' ('
  return `"${full_name.split(/ \[| \(/)[0]}"`;
};

/** Returns the display color for certain health percentages */
const getHealthColor = (health: number) => {
  switch (true) {
    case health > HEALTH.Good:
      return 'good';
    case health > HEALTH.Average:
      return 'average';
    default:
      return 'bad';
  }
};

/** Returns the display color based on orbiter numbers */
const getThreatColor = (orbiters: number) => {
  switch (true) {
    case orbiters > THREAT.High:
      return 'violet';
    case orbiters > THREAT.Medium:
      return 'blue';
    case orbiters > THREAT.Low:
      return 'teal';
    default:
      return 'good';
  }
};

/**
 * ### getDisplayColor
 * Displays color for buttons based on the health or orbiter count. Toggleable.
 * @param {Observable} item - The point of interest.
 * @param {boolean} heatMap - Whether the user has heat map toggled.
 * @param {string} color - OPTIONAL: The color to default to.
 */
export const getDisplayColor = (
  item: Observable,
  heatMap: boolean,
  color?: string
) => {
  const { health, orbiters = 0 } = item;
  if (typeof health !== 'number') {
    return color ? 'good' : 'grey';
  }
  if (heatMap) {
    return getThreatColor(orbiters);
  }
  return getHealthColor(health);
};

/** Checks if a full name or job title matches the search. */
export const isJobOrNameMatch = (
  observable: Observable,
  searchQuery: string
) => {
  if (!searchQuery) {
    return true;
  }
  const { full_name, job } = observable;

  return (
    full_name?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    job?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    false
  );
};
