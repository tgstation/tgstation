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
  return FeatureDropdownInputCore(props, (serverData) => {
    let options = generateOptions(serverData);

  const populateOptions = useCallback(
    (
      serverData: FeatureChoicedServerData,
      setDropdownOptions: (newValue: DropdownOptions) => void
    ) => {
      let options = generateOptions(serverData);

    return options;
  });
}
