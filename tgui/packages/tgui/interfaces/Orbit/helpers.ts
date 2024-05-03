import { filter, sortBy } from 'common/collections';

import { HEALTH, THREAT } from './constants';
import type { AntagGroup, Antagonist, Observable } from './types';

/** Return a map of strings with each antag in its antag_category */
export const getAntagCategories = (antagonists: Antagonist[]) => {
  const categories: Record<string, Antagonist[]> = {};

  antagonists.map((player) => {
    const { antag_group } = player;

    if (!categories[antag_group]) {
      categories[antag_group] = [];
    }

    categories[antag_group].push(player);
  });

  return sortBy<AntagGroup>(Object.entries(categories), ([key]) => key);
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

export const getMostRelevant = (
  searchQuery: string,
  observables: Observable[][],
): Observable => {
  const queriedObservables =
    // Sorts descending by orbiters
    sortBy(
      // Filters out anything that doesn't match search
      filter(
        observables
          // Makes a single Observables list for an easy search
          .flat(),
        (observable) => isJobOrNameMatch(observable, searchQuery),
      ),
      (observable) => -(observable.orbiters || 0),
    );
  return queriedObservables[0];
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
const getThreatColor = (orbiters = 0) => {
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

/** Displays color for buttons based on the health or orbiter count. */
export const getDisplayColor = (
  item: Observable,
  heatMap: boolean,
  color?: string,
) => {
  const { health, orbiters } = item;
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
  searchQuery: string,
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
