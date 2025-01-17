import { DmIcon, Icon, Image } from 'tgui-core/components';

import { SearchItem } from './types';

type Props = {
  item: SearchItem;
};

type Size = {
  height: number;
  width: number;
};

export function IconDisplay(props: Props) {
  const {
    item: { icon, icon_state },
  } = props;

  const fallback = <Icon name="spinner" spin color="gray" p={1.5} />;

  if (!icon) {
    return fallback;
  }

  if (icon === 'n/a') {
    return <Icon name="dumpster-fire" color="gray" p={1.5} />;
  }

  if (icon_state) {
    return (
      <DmIcon
        height={'32px'}
        fallback={fallback}
        icon={icon}
        icon_state={icon_state}
      />
    );
  }

  return <Image fixErrors src={icon} height={'32px'} />;
}
