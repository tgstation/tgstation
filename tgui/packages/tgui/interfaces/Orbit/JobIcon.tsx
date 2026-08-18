import { DmIcon, Icon } from 'tgui-core/components';

import { JOB2ICON } from '../common/JobToIcon';
import type { Antagonist, Observable } from './types';

type Props = {
  item: Observable | Antagonist;
  realNameDisplay: boolean;
};

type JobIconSettings = {
  transform: string;
};

type AntagIconSettings = {
  dmi: string;
  transform: string;
};

const normalIcon: JobIconSettings = {
  transform: 'scale(2.3) translateX(9px) translateY(1px)',
};

const antagIcon: AntagIconSettings = {
  dmi: 'icons/mob/huds/antag_hud.dmi',
  transform: 'scale(1.8) translateX(-16px) translateY(7px)',
};

export function JobIcon(props: Props) {
  const { item, realNameDisplay } = props;

  // We don't need to cast here but typescript isn't smart enough to know that
  const {
    icon = '',
    icon_state = '',
    job = '',
    mind_icon = '',
    mind_icon_state = '',
  } = item;
  const usedIcon = realNameDisplay ? mind_icon || icon : icon;
  let usedIconState = realNameDisplay
    ? mind_icon_state || icon_state
    : icon_state;
  let usedJob = realNameDisplay ? mind_icon || job : job;

  let iconSettings: AntagIconSettings | JobIconSettings;
  if ('antag' in item && !realNameDisplay) {
    iconSettings = antagIcon;
    usedJob = item.antag;
    usedIconState = item.antag_icon;
  } else {
    iconSettings = normalIcon;
  }

  return (
    <div className="JobIcon">
      {icon_state === 'borg' ? (
        <Icon color="lightblue" name={JOB2ICON[usedJob]} ml={0.3} mt={0.4} />
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
