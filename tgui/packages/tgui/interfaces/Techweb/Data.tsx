import { type ReactNode, Suspense, useMemo } from 'react';

import { useBackend } from '../../backend';
import { type CatalogueRef, createCatalogueLoader } from '../common/catalogue';
import { LoadingScreen } from '../common/LoadingScreen';
import { joinResearch, remapCatalogue, TechwebDataContext } from './helpers';
import type { CatalogueFile, TechWebData } from './types';

const { useShownCatalogue, useCatalogueFile } =
  createCatalogueLoader<CatalogueFile>();

type Props = {
  children: ReactNode;
};

/** Joins our data with the catalogue for the techweb. When a new build comes in, we keep the old one up until it's loaded */
export function TechwebDataProvider(props: Props) {
  const { data } = useBackend<TechWebData>();
  // NtOS can send our data before our static data the first time the app's opened, so wait for both
  if (!data.techweb_catalogue || !data.nodes) {
    return <LoadingScreen />;
  }

  return (
    <TechwebCatalogue catalogue={data.techweb_catalogue}>
      {props.children}
    </TechwebCatalogue>
  );
}

function TechwebCatalogue(props: Props & { catalogue: CatalogueRef }) {
  const catalogue = useShownCatalogue(props.catalogue);

  return (
    <Suspense fallback={<LoadingScreen />}>
      <TechwebJoin catalogue={catalogue}>{props.children}</TechwebJoin>
    </Suspense>
  );
}

function TechwebJoin(props: Props & { catalogue: CatalogueRef }) {
  const { data } = useBackend<TechWebData>();
  // Never undefined here, since useShownCatalogue() loads every catalogue we give it
  const file = useCatalogueFile(props.catalogue) as CatalogueFile;
  const catalogue = useMemo(() => remapCatalogue(file), [file]);
  const research = useMemo(
    () => joinResearch(data, catalogue),
    [data, catalogue],
  );

  return (
    <TechwebDataContext.Provider value={research}>
      {props.children}
    </TechwebDataContext.Provider>
  );
}
