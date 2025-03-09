import { Feature, FeatureChoiced, FeatureShortTextInput } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const ship_captain_hull: FeatureChoiced = {
  name: 'Ship Hull',
  component: FeatureDropdownInput,
};

export const ship_captain_name: Feature<string> = {
  name: 'Ship Name',
  component: FeatureShortTextInput,
};

export const ship_captain_crewkey: Feature<string> = {
  name: 'Crew Key Identifier',
  description:
    'If a shuttle with the same crew key identifier is already spawned, you will join that as crew instead of spawning a new shuttle (unless this is set to Solo)',
  component: FeatureShortTextInput,
};
