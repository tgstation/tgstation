import { sortBy } from 'common/collections';

import { DEPARTMENT2COLOR, HEALTH, THREAT, VIEWMODE } from './constants';
import { AntagGroup, Antagonist, Observable, ViewMode } from './types';

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

/** Returns the department the player is in */
function getDepartmentByJob(job: string) {
  for (const department in DEPARTMENT2COLOR) {
    if (DEPARTMENT2COLOR[department].trims.includes(job)) {
      return department;
    }
  }
}

/** Gets department color for a job */
function getDepartmentColor(job: string) {
  const department = getDepartmentByJob(job);
  if (!department) return 'grey';

  return DEPARTMENT2COLOR[department].color;
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
  mode: ViewMode,
  override?: string,
) {
  const { job, health, orbiters } = item;

  // Things like blob camera, etc
  if (typeof health !== 'number') {
    return override ? 'good' : 'grey';
  }

  // Players that are AFK
  if ('client' in item && !item.client) {
    return 'grey';
  }

  switch (mode) {
    case VIEWMODE.Orbiters:
      return getThreatColor(orbiters);
    case VIEWMODE.Department:
      if (!job) return 'grey';
      return getDepartmentColor(job);
    default:
      return getHealthColor(health);
  }
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

/** Sorts by department */
export function sortByDepartment(poiA: Observable, poiB: Observable) {
  const departmentA = (poiA.job && getDepartmentByJob(poiA.job)) || 'unknown';
  const departmentB = (poiB.job && getDepartmentByJob(poiB.job)) || 'unknown';

  if (departmentA < departmentB) return -1;
  if (departmentA > departmentB) return 1;
  return 0;
}

/** Sorts based on real name */
export function sortByDisplayName(poiA: Observable, poiB: Observable) {
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
