import { DmIcon, Icon } from 'tgui-core/components';

import type { Antagonist, Observable } from './types';

type Props = {
  item: Observable | Antagonist;
  realNameDisplay: boolean;
};

type IconSettings = {
  transform: string;
};

const normalIcon: IconSettings = {
  transform: 'scale(2.3) translateX(9px) translateY(1px)',
};

const antagIcon: IconSettings = {
  transform: 'scale(2) translateX(-15px) translateY(8px)',
};

export function JobIcon(props: Props) {
  const { item, realNameDisplay } = props;

  // We don't need to cast here but typescript isn't smart enough to know that
  const {
    icon = '',
    icon_state = '',
    mind_job_icon = '',
    mind_icon = '',
    mind_icon_state = '',
  } = item;
  const usedIcon = realNameDisplay ? mind_icon || icon : icon;
  const usedIconState = realNameDisplay
    ? mind_icon_state || icon_state
    : icon_state;

  let iconSettings: IconSettings;
  if ('antag' in item && !realNameDisplay) {
    iconSettings = antagIcon;
  } else {
    iconSettings = normalIcon;
  }

  return (
    <div className="JobIcon">
      {icon_state === 'borg' ? (
        <Icon color="lightblue" name={mind_job_icon} ml={0.3} mt={0.4} />
      ) : (
        <DmIcon
          icon={usedIcon}
          icon_state={usedIconState}
          style={{
            transform: iconSettings.transform,
          }}
        />
      )}
    </div>
  );
}
