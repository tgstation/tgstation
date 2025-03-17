// THIS IS A DOPPLER SHIFT UI FILE
import { Feature } from '../../base';
import { FeatureDropdownInput } from '../../dropdowns';

export const loadout_override_preference: Feature<string> = {
  name: 'Loadout Item Preference',
  component: FeatureDropdownInput,
};
