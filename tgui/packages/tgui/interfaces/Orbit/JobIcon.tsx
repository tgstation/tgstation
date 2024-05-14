import { DmIcon, Icon } from '../../components';
import { JOB2ICON } from '../common/JobToIcon';

type Props = {
  icon: string | undefined;
  job: string;
};

export function JobIcon(props: Props) {
  const { icon, job } = props;

  if (!icon || icon === 'hudunknown') return null;

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
            icon="icons/mob/huds/hud.dmi"
            icon_state={icon}
            style={{ transform: 'scale(2)  translateX(8px)' }}
          />
        </div>
      )}
    </div>
  );
}
