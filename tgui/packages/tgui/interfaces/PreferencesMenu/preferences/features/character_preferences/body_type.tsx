import { useCallback } from 'react';
import { Gender } from '../../gender';
import type { FeatureChoicedServerData, FeatureChoiced } from '../base';
import {
  type DropdownInputProps,
  type DropdownOptions,
  FeatureDropdownInputCore,
  generateOptions,
} from '../dropdowns';

export const body_type: FeatureChoiced = {
  name: 'Body type',
  component: FeatureBodyTypeDropdownInput,
};

function FeatureBodyTypeDropdownInput(props: DropdownInputProps) {
  const currentGender = props.character_preferences.misc.gender;

  const populateOptions = useCallback(
    (
      serverData: FeatureChoicedServerData,
      setDropdownOptions: (newValue: DropdownOptions) => void
    ) => {
      let options = generateOptions(serverData);

      if (currentGender !== Gender.Male && currentGender !== Gender.Female) {
        options = options.filter(
          (option) =>
            option.value === Gender.Male || option.value === Gender.Female,
        );
      }

      setDropdownOptions(options);
    },
    [currentGender],
  );

  return <FeatureDropdownInputCore
    dropdownProps={props}
    populateOptions={populateOptions}
  />
}
