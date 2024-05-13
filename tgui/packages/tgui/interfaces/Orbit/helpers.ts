import { sortBy } from 'common/collections';

import { HEALTH, THREAT } from './constants';
import type { AntagGroup, Antagonist, Observable } from './types';

/** Return a map of strings with each antag in its antag_category */
export function getAntagCategories(antagonists: Antagonist[]) {
  const categories: Record<string, Antagonist[]> = {};

  antagonists.map((player) => {
    const { antag_group } = player;

    if (!categories[antag_group]) {
      categories[antag_group] = [];
    }

    categories[antag_group].push(player);
  });

  return sortBy<AntagGroup>(Object.entries(categories), ([key]) => key);
}

/** Returns a disguised name in case the person is wearing someone else's ID */
export function getDisplayName(full_name: string, nickname?: string) {
  if (!nickname) {
    return full_name;
  }

  if (
    !full_name?.includes('[') ||
    full_name.match(/\(as /) ||
    full_name.match(/^Unknown/)
  ) {
    return nickname;
  }

  // return only the name before the first ' [' or ' ('
  return `"${full_name.split(/ \[| \(/)[0]}"`;
}

/** Returns the display color for certain health percentages */
function getHealthColor(health: number) {
  switch (true) {
    case health > HEALTH.Good:
      return 'good';
    case health > HEALTH.Average:
      return 'average';
    default:
      return 'bad';
  }
}

/** Returns the display color based on orbiter numbers */
function getThreatColor(orbiters = 0) {
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
}

/** Displays color for buttons based on the health or orbiter count. */
export function getDisplayColor(
  item: Observable,
  heatMap: boolean,
  color?: string,
) {
  const { health, orbiters } = item;
  if (typeof health !== 'number') {
    return color ? 'good' : 'grey';
  }

  if ('client' in item && !item.client) {
    return 'grey';
  }

  if (heatMap) {
    return getThreatColor(orbiters);
  }

  return getHealthColor(health);
}

/** Checks if a full name or job title matches the search. */
export function isJobOrNameMatch(observable: Observable, searchQuery: string) {
  if (!searchQuery) return true;

  const { full_name, job } = observable;

  return (
    full_name?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    job?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    false
  );
}

/** Sorts based on real name */
export function sortByRealName(poiA: Observable, poiB: Observable) {
  const nameA = getDisplayName(poiA.full_name, poiA.name)
    .replace(/^"/, '')
    .toLowerCase();
  const nameB = getDisplayName(poiB.full_name, poiB.name)
    .replace(/^"/, '')
    .toLowerCase();

  if (nameA < nameB) {
    return -1;
  }
  if (nameA > nameB) {
    return 1;
  }
  return 0;
}

/** Sorts by most orbiters  */
export function sortByOrbiters(poiA: Observable, poiB: Observable) {
  const orbitersA = poiA.orbiters || 0;
  const orbitersB = poiB.orbiters || 0;

  if (orbitersA < orbitersB) {
    return -1;
  }
  if (orbitersA > orbitersB) {
    return 1;
  }
  return 0;
}
