import { Gender } from '../../gender';
import type { FeatureChoiced } from '../base';
import {
  type DropdownInputProps,
  FeatureDropdownInputCore,
  generateOptions,
} from '../dropdowns';

export const body_type: FeatureChoiced = {
  name: 'Body type',
  component: FeatureBodyTypeDropdownInput,
};

function FeatureBodyTypeDropdownInput(props: DropdownInputProps) {
  const currentGender = props.character_preferences.misc.gender;
  return FeatureDropdownInputCore(props, (serverData) => {
    let options = generateOptions(serverData);
    if (currentGender !== Gender.Male && currentGender !== Gender.Female) {
      options = options.filter(
        (option) =>
          option.value === Gender.Male || option.value === Gender.Female,
      );
    }
    return options;
  });
}
