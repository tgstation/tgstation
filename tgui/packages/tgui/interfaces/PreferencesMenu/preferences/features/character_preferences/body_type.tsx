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
  return FeatureDropdownInputCore(props, (serverData, setDropdownOptions) => {
    let options = generateOptions(serverData);

    const current_gender = props.character_preferences.misc.gender;
    if (current_gender !== Gender.Male && current_gender !== Gender.Female) {
      options = options.filter(
        (option) =>
          option.value === Gender.Male || option.value === Gender.Female,
      );
    }

    setDropdownOptions(options);
  });
}
