import { filter } from 'es-toolkit/compat';
import { useMemo } from 'react';
import { flow } from 'tgui-core/fp';

import { createCatalogueLoader } from '../common/catalogue';
import type { Catalogue, CatalogueFile, Supply, SupplyCategory } from './types';

/**
 * Take entire supplies tree
 * and return a flat supply pack list that matches search,
 * sorted by name and only the first page.
 * @param {Supply[]} supplies Supplies list, from useCatalogue()
 * @param {string} search The search term
 * @returns {Supply[]} The flat list of supply packs.
 */
export function searchForSupplies(
  supplies: SupplyCategory[],
  search: string,
): Supply[] {
  const lowerSearch = search.toLowerCase();

  return flow([
    // Flat categories
    (initialSupplies: SupplyCategory[]) =>
      initialSupplies.flatMap((category) => category.packs),
    // Filter by name or desc
    (flatMapped: Supply[]) =>
      filter(
        flatMapped,
        (pack: Supply) =>
          pack.name?.toLowerCase().includes(lowerSearch) ||
          pack.desc?.toLowerCase().includes(lowerSearch),
      ),
    // Just the first page
    (filtered: Supply[]) => filtered.slice(0, 25),
  ])(supplies);
}

const { useShownCatalogue: useShownBuild, useCatalogueFile } =
  createCatalogueLoader<CatalogueFile>();

/** Returns the catalogue to show - keeps the current one up while a new build loads, and only fetches while the window is open */
export function useShownCatalogue(catalogue: Catalogue): Catalogue {
  return useShownBuild(catalogue, !!catalogue.groups);
}

/** Joins the catalogue file with the UI's catalogue data into the groups to show, skipping packs the file doesn't have */
export function joinCatalogue(
  file: CatalogueFile,
  catalogue: Catalogue,
): SupplyCategory[] {
  return Object.entries(catalogue.groups ?? {}).map(([name, pairs]) => {
    const packs: Supply[] = [];
    for (let offset = 0; offset < pairs.length; offset += 2) {
      const entry = file.packs[pairs[offset]];
      if (!entry) {
        continue;
      }
      const { contraband, ...pack } = entry;
      const cost = pairs[offset + 1];
      packs.push(
        catalogue.show_contraband
          ? { ...pack, cost, contraband }
          : { ...pack, cost },
      );
    }
    return { name, packs };
  });
}

/** Returns the groups to show, suspending until the catalogue file has loaded */
export function useCatalogue(catalogue: Catalogue): SupplyCategory[] {
  const file = useCatalogueFile(catalogue);
  return useMemo(
    () => (file ? joinCatalogue(file, catalogue) : []),
    [file, catalogue],
  );
}
