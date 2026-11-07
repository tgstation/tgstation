import { use, useDeferredValue, useEffect, useLayoutEffect } from 'react';

/** Where to find a catalogue file the server published, and which build it is */
export type CatalogueRef = {
  url: string;
  version: number;
};

/**
 * Makes the hooks for loading one kind of catalogue file. Each kind keeps its own builds,
 * so a window that gets reused for another interface keeps what it was showing.
 */
export function createCatalogueLoader<Contents extends { version: number }>() {
  /** A catalogue build we've asked for - its url, version and file */
  type CatalogueBuild = {
    url: string;
    version: number;
    file: Promise<Contents>;
    /** Resolves the file - cleared once it has */
    load?: (file: Contents) => void;
  };

  /** The build on screen, kept until a newer one has loaded */
  let shownBuild: CatalogueBuild | undefined;
  /** The newest build asked for */
  let newestBuild: CatalogueBuild | undefined;
  /** The build useShownCatalogue() picked for each catalogue - useCatalogueFile() only reads these, so an old deferred catalogue can't replace the newest build */
  const partBuilds = new WeakMap<CatalogueRef, CatalogueBuild>();

  function isBuild(
    build: CatalogueBuild | undefined,
    { url, version }: CatalogueRef,
  ): build is CatalogueBuild {
    return build?.url === url && build.version === version;
  }

  /** Returns the build a catalogue points to - the one on screen, or the newest (making it if needed) */
  function loadCatalogue(catalogue: CatalogueRef): CatalogueBuild {
    if (isBuild(shownBuild, catalogue)) {
      return shownBuild;
    }
    if (!isBuild(newestBuild, catalogue)) {
      const { url, version } = catalogue;
      let load: CatalogueBuild['load'];
      const file = new Promise<Contents>((resolve) => {
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
        .then((file: Contents) => {
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
  function useShownCatalogue<Catalogue extends CatalogueRef>(
    catalogue: Catalogue,
    load = true,
  ): Catalogue {
    const deferred = useDeferredValue(catalogue);
    const build = load ? loadCatalogue(catalogue) : undefined;
    if (build) {
      partBuilds.set(catalogue, build);
    }
    useEffect(() => (build?.load ? keepFetching(build) : undefined), [build]);
    return isBuild(shownBuild, catalogue) ? catalogue : deferred;
  }

  /** Returns the file of a catalogue from useShownCatalogue(), suspending until it has loaded */
  function useCatalogueFile(catalogue: CatalogueRef): Contents | undefined {
    const build = partBuilds.get(catalogue);
    const file = build && use(build.file);
    useLayoutEffect(() => {
      if (build) {
        shownBuild = build;
      }
    }, [build]);
    return file;
  }

  return { useShownCatalogue, useCatalogueFile };
}
