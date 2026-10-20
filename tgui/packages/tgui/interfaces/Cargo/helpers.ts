import { filter } from 'es-toolkit/compat';
import {
  use,
  useDeferredValue,
  useEffect,
  useLayoutEffect,
  useMemo,
} from 'react';
import { flow } from 'tgui-core/fp';

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

/** A catalogue build we've asked for - its url, version and file */
type CatalogueBuild = {
  url: string;
  version: number;
  file: Promise<CatalogueFile>;
  /** Resolves the file - cleared once it has */
  load?: (file: CatalogueFile) => void;
};

/** The build on screen, kept until a newer one has loaded */
let shownBuild: CatalogueBuild | undefined;
/** The newest build asked for */
let newestBuild: CatalogueBuild | undefined;
/** The build useShownCatalogue() picked for each catalogue - useCatalogue() only reads these, so an old deferred catalogue can't replace the newest build */
const partBuilds = new WeakMap<Catalogue, CatalogueBuild>();

function isBuild(
  build: CatalogueBuild | undefined,
  { url, version }: Pick<Catalogue, 'url' | 'version'>,
): build is CatalogueBuild {
  return build?.url === url && build.version === version;
}

/** Returns the build a catalogue points to - the one on screen, or the newest (making it if needed) */
function loadCatalogue(catalogue: Catalogue): CatalogueBuild {
  if (isBuild(shownBuild, catalogue)) {
    return shownBuild;
  }
  if (!isBuild(newestBuild, catalogue)) {
    const { url, version } = catalogue;
    let load: CatalogueBuild['load'];
    const file = new Promise<CatalogueFile>((resolve) => {
      load = resolve;
    });
    newestBuild = { url, version, file, load };
  }
  return newestBuild;
}

/** Fetches a build's file until it loads, backing off from 1 to 30 seconds and adding ?v= if we get an older build back - returns a function that stops it */
function keepFetching(build: CatalogueBuild): () => void {
  let timer: ReturnType<typeof setTimeout> | undefined;
  let stopped = false;
  const attempt = (wait: number, query: string) => {
    let retryQuery = query;
    fetch(build.url + query)
      .then((response) => response.json())
      .then((file: CatalogueFile) => {
        if (file.version !== build.version) {
          retryQuery = `?v=${build.version}`;
          throw new Error(
            `catalogue build ${file.version} is not ${build.version}`,
          );
        }
        build.load?.(file);
        build.load = undefined;
      })
      .catch(() => {
        if (!stopped) {
          timer = setTimeout(
            () => attempt(Math.min(wait * 2, 30000), retryQuery),
            wait,
          );
        }
      });
  };
  attempt(1000, '');
  return () => {
    stopped = true;
    clearTimeout(timer);
  };
}

/** Returns the catalogue to show - keeps the current one up while a new build loads, and only fetches while the window is open */
export function useShownCatalogue(catalogue: Catalogue): Catalogue {
  const deferred = useDeferredValue(catalogue);
  const build = catalogue.groups ? loadCatalogue(catalogue) : undefined;
  if (build) {
    partBuilds.set(catalogue, build);
  }
  useEffect(() => (build?.load ? keepFetching(build) : undefined), [build]);
  return isBuild(shownBuild, catalogue) ? catalogue : deferred;
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
  const build = partBuilds.get(catalogue);
  const file = build && use(build.file);
  useLayoutEffect(() => {
    if (build) {
      shownBuild = build;
    }
  }, [build]);
  return useMemo(
    () => (file ? joinCatalogue(file, catalogue) : []),
    [file, catalogue],
  );
}
