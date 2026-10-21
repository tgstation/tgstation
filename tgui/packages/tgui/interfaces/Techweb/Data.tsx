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
  // Both of these come in with the first update after we get linked to a techweb
  if (!data.catalogue || !data.nodes) {
    return <LoadingScreen />;
  }

  return (
    <TechwebCatalogue catalogue={data.catalogue}>
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
