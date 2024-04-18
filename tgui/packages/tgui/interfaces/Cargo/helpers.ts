import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';

import { Supply, SupplyCategory } from './types';

/**
 * Take entire supplies tree
 * and return a flat supply pack list that matches search,
 * sorted by name and only the first page.
 * @param {Supply[]} supplies Supplies list, aka Object.values(data.supplies)
 * @param {string} search The search term
 * @returns {Supply[]} The flat list of supply packs.
 */
export function searchForSupplies(
  supplies: SupplyCategory[],
  search: string,
): Supply[] {
  search = search.toLowerCase();

  return flow([
    (categories: SupplyCategory[]) =>
      categories.flatMap((category) => category.packs),
    filter(
      (pack: Supply) =>
        pack.name?.toLowerCase().includes(search?.toLowerCase()) ||
        pack.desc?.toLowerCase().includes(search?.toLowerCase()),
    ),
    sortBy((pack: Supply) => pack.name),
    (packs) => packs.slice(0, 25),
  ])(supplies);
}
