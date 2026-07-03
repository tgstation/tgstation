import { Icon, Stack } from 'tgui-core/components';

import { TYPE_ICONS, TYPE_NAMES } from '../constants';
import type { Diet } from '../types';

type Props = {
  craftableCount?: number;
  diet: Diet;
  type: string;
};

export function FoodtypeContent(props: Props) {
  const { type, diet, craftableCount } = props;
  let iconName = '',
    iconColor = '';

  // We use iconName in the return to see if this went through.
  if (type !== 'Can Make' && diet) {
    if (diet.liked_food.includes(type)) {
      iconName = 'face-laugh-beam';
      iconColor = 'good';
    } else if (diet.disliked_food.includes(type)) {
      iconName = 'face-tired';
      iconColor = 'average';
    } else if (diet.toxic_food.includes(type)) {
      iconName = 'skull-crossbones';
      iconColor = 'bad';
    }
  }

  return (
    <Stack>
      <Stack.Item width="14px" textAlign="center">
        <Icon name={TYPE_ICONS[type] || 'circle'} />
      </Stack.Item>
      <Stack.Item grow style={{ textTransform: 'capitalize' }}>
        {TYPE_NAMES[type] || type.toLowerCase()}
      </Stack.Item>
      <Stack.Item>
        {type === 'Can Make'
          ? craftableCount
          : iconName && <Icon name={iconName} color={iconColor} />}
      </Stack.Item>
    </Stack>
  );
}
