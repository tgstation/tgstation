import { DmIcon, Icon } from '../../components';
import { JOB2ICON } from '../common/JobToIcon';
import { Antagonist, Observable } from './types';

type Props = {
  item: Observable | Antagonist;
};

type IconSettings = {
  dmi: string;
  transform: string;
};

const normalIcon: IconSettings = {
  dmi: 'icons/mob/huds/hud.dmi',
  transform: 'scale(2) translateX(8px)',
};

const antagIcon: IconSettings = {
  dmi: 'icons/mob/huds/antag_hud.dmi',
  transform: 'scale(1.8) translateX(-16px) translateY(7px)',
};

export function JobIcon(props: Props) {
  const { item } = props;

  let iconSettings: IconSettings;

  let antag;
  if ('antag' in item) {
    antag = item.antag;
    iconSettings = antagIcon;
  } else {
    iconSettings = normalIcon;
  }

  // We don't need to cast here but typescript isn't smart enough to know that
  const { icon = '', job = '' } = item;

  return (
    <div className="JobIcon">
      {icon === 'borg' ? (
        <Icon color="lightblue" name={JOB2ICON[job]} mr={0.5} />
      ) : (
        <div
          style={{
            height: '17px',
            width: '19px',
          }}
        >
          <DmIcon
            icon={iconSettings.dmi}
            icon_state={icon}
            style={{ transform: iconSettings.transform }}
          />
        </div>
      )}
    </div>
  );
}
