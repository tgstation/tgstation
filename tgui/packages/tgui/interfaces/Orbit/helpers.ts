import { ReverseJobsRu } from '../../bandastation/ru_jobs'; // BANDASTATION EDIT
import { DEPARTMENT2COLOR, HEALTH, THREAT, VIEWMODE } from './constants';
import type { AntagGroup, Antagonist, Observable, ViewMode } from './types';

/** Return a map of strings with each antag in its antag_category */
export function getAntagCategories(antagonists: Antagonist[]): AntagGroup[] {
  const categories = new Map<string, Antagonist[]>();

  for (const player of antagonists) {
    const { antag_group } = player;

    if (!categories.has(antag_group)) {
      categories.set(antag_group, []);
    }
    categories.get(antag_group)!.push(player);
  }

  const sorted = Array.from(categories.entries()).sort((a, b) => {
    const lowerA = a[0].toLowerCase();
    const lowerB = b[0].toLowerCase();

    if (lowerA < lowerB) return -1;
    if (lowerA > lowerB) return 1;
    return 0;
  });

  return sorted;
}

/** Returns a disguised name in case the person is wearing someone else's ID */
export function getDisplayName(full_name: string, nickname?: string): string {
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
export function getDepartmentByJob(job: string): string | undefined {
  const withoutParenthesis = ReverseJobsRu(job).replace(/ \(.*\)/, '');

  for (const department in DEPARTMENT2COLOR) {
    if (DEPARTMENT2COLOR[department].trims.includes(withoutParenthesis)) {
      return department;
    }
  }
}

/** Gets department color for a job */
function getDepartmentColor(job: string | undefined): string {
  if (!job) return 'grey';

  const department = getDepartmentByJob(job);
  if (!department) return 'grey';

  return DEPARTMENT2COLOR[department].color;
}

/** Returns the display color for certain health percentages */
function getHealthColor(health: number): string {
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
function getThreatColor(orbiters = 0): string {
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
): string {
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
      return getDepartmentColor(job);
    default:
      return getHealthColor(health);
  }
}

/** Checks if a full name or job title matches the search. */
export function isJobCkeyOrNameMatch(
  observable: Observable,
  searchQuery: string,
): boolean {
  if (!searchQuery) return true;

  const { full_name, job, name, ckey } = observable;

  return (
    full_name?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    name?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    job?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    ckey?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    false
  );
}

/** Sorts by department */
export function sortByDepartment(poiA: Observable, poiB: Observable): number {
  const departmentA = (poiA.job && getDepartmentByJob(poiA.job)) || 'unknown';
  const departmentB = (poiB.job && getDepartmentByJob(poiB.job)) || 'unknown';

  if (departmentA < departmentB) return -1;
  if (departmentA > departmentB) return 1;
  return 0;
}

/** Sorts based on real name */
export function sortByDisplayName(poiA: Observable, poiB: Observable): number {
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
export function sortByOrbiters(poiA: Observable, poiB: Observable): number {
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
