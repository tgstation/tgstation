import { DmIcon, Icon, Image } from 'tgui-core/components';

import type { SearchItem } from './types';

type Props = {
  item: SearchItem;
  size: Size;
};

type Size = {
  height: number;
  width: number;
};

export function IconDisplay(props: Props) {
  const {
    item: { icon, icon_state },
    size: { height, width },
  } = props;

  const fallback = <Icon name="spinner" size={1.5} spin color="gray" />;

  if (!icon) {
    return fallback;
  }

  if (icon === 'n/a') {
    return <Icon name="dumpster-fire" size={1.5} color="gray" />;
  }

  if (icon_state) {
    return (
      <DmIcon
        fallback={fallback}
        icon={icon}
        icon_state={icon_state}
        height={height}
        width={width}
      />
    );
  }

  return <Image fixErrors src={icon} height={3} width={3} />;
}
