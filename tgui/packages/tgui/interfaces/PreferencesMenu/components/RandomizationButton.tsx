import { Dropdown } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { RandomSetting } from '../types';

const options = [
  {
    displayText: 'Do not randomize',
    value: RandomSetting.Disabled,
  },

  {
    displayText: 'Always randomize',
    value: RandomSetting.Enabled,
  },

  {
    displayText: 'Randomize when antagonist',
    value: RandomSetting.AntagOnly,
  },
];

type Props = {
  dropdownProps?: Record<string, unknown>;
  setValue: (newValue: RandomSetting) => void;
  value: RandomSetting;
};

export function RandomizationButton(props: Props) {
  const { dropdownProps = {}, setValue, value } = props;

  let color;

  switch (value) {
    case RandomSetting.AntagOnly:
      color = 'orange';
      break;
    case RandomSetting.Disabled:
      color = 'red';
      break;
    case RandomSetting.Enabled:
      color = 'green';
      break;
    default:
      exhaustiveCheck(value);
  }

  return (
    <Dropdown
      color={color}
      {...dropdownProps}
      clipSelectedText={false}
      icon="dice-d20"
      options={options}
      noChevron
      onSelected={setValue}
      menuWidth="120px"
      width={1.85}
      selected="None"
    />
  );
}
