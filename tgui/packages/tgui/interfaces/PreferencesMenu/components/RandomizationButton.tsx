import { Dropdown } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { RandomSetting } from '../types';

const options = [
  {
    value: RandomSetting.Disabled,
    displayText: 'Не рандомизировать',
  },
  {
    value: RandomSetting.Enabled,
    displayText: 'Всегда рандомизировать',
  },
  {
    value: RandomSetting.AntagOnly,
    displayText: 'Рандомизировать при антагонизме',
  },
];

type Props = {
  setValue: (newValue: RandomSetting) => void;
  value: RandomSetting;
};

export function RandomizationButton(props: Props) {
  const { setValue, value } = props;

  let color;
  switch (value) {
    case RandomSetting.AntagOnly:
      color = 'yellow';
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
      iconOnly
      icon="dice"
      color={color}
      width="auto"
      menuWidth="auto"
      selected="NONE"
      options={options}
      onSelected={setValue}
    />
  );
}
