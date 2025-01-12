// THIS IS A DOPPLER SHIFT UI FILE
import { Feature, FeatureChoiced, FeatureShortTextInput } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const underworld_uplink_skin: FeatureChoiced = {
  name: 'Uplink Skin',
  component: FeatureDropdownInput,
};

export const underworld_uplink_name: Feature<string> = {
  name: 'Uplink Name',
  component: FeatureShortTextInput,
};

export const underworld_uplink_desc: Feature<string> = {
  name: 'Uplink Description',
  component: FeatureShortTextInput,
};
