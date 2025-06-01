import { chain } from 'common/collections';

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
  const lowerSearch = search.toLowerCase();

  return (
    chain(supplies)
      // Flat categories
      .mapArray((initialSupplies: SupplyCategory[]) =>
        initialSupplies.flatMap((category) => category.packs),
      )
      // Filter by name or desc
      .filter(
        (pack: Supply) =>
          pack.name?.toLowerCase().includes(lowerSearch) ||
          pack.desc?.toLowerCase().includes(lowerSearch),
      )
      // Just the first page
      .mapArray((filtered: Supply[]) => filtered.slice(0, 25))
      .unwrap()
  );
}
