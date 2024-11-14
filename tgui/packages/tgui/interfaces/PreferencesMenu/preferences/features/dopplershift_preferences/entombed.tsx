import {
  CheckboxInput,
  Feature,
  FeatureChoiced,
  FeatureShortTextInput,
  FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const entombed_skin: FeatureChoiced = {
  name: 'MODsuit Skin',
  component: FeatureDropdownInput,
};

export const entombed_mod_name: Feature<string> = {
  name: 'MODsuit Control Unit Name',
  component: FeatureShortTextInput,
};

export const entombed_mod_desc: Feature<string> = {
  name: 'MODsuit Control Unit Description',
  component: FeatureShortTextInput,
};

export const entombed_mod_prefix: Feature<string> = {
  name: 'MODsuit Deployed Prefix',
  description:
    "This is appended to any deployed pieces of MODsuit gear, like the chest, helmet, etc. The default is 'fused' - try to use an adjective, if you can.",
  component: FeatureShortTextInput,
};

export const entombed_deploy_lock: FeatureToggle = {
  name: 'MODsuit Stays Deployed (Soft DNR)',
  description:
    'Prevents anyone from retracting any of your MODsuit, except your helmet. Even you. WARNING: this may make you extremely difficult to revive, and can be considered a soft DNR. Choose wisely.',
  component: CheckboxInput,
};
