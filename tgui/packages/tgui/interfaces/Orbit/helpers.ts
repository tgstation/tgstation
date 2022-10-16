import { sortBy } from 'common/collections';
import { ANTAG2GROUP } from './mappings';
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
export const getHealthColor = (color?: string, health?: number) => {
  if (health === undefined || health === null) {
    return color ? 'good' : 'grey';
  }
  switch (true) {
    case health > 75:
      return 'good';
    case health >= 20:
      return 'average';
    default:
      return 'bad';
  }
};

/** Checks if a full name or job title matches the search. */
export const isJobOrNameMatch = (
  observable: Observable,
  searchQuery: string
) => {
  const { full_name, name, job } = observable;
  const displayName = full_name ?? name;

  return (
    displayName?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    job?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    false
  );
};
