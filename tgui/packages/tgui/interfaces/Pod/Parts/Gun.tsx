import { BooleanLike } from 'common/react';
import { useBackend } from '../../../backend';
import { LabeledList, ProgressBar } from 'tgui-core/components';
type Data = {
  ammo: number;
  maxAmmo: number;
  ammoPerShot: number;
  mode: string;
  ref: string;
};
export default function Gun(props: { partData: Data }): JSX.Element {
  const { act } = useBackend<{
    ourData: Data;
  }>();
  const ourData = props.partData as Data;
  return (
    <LabeledList>
      <LabeledList.Item label={'Firing Mode'}>{ourData.mode}</LabeledList.Item>
      <LabeledList.Item>
        <ProgressBar
          value={ourData.ammo / ourData.maxAmmo}
        >{`${ourData.ammo} of ${ourData.maxAmmo}`}</ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label={'Shots remaining'}>
        {Math.floor(ourData.ammo / ourData.ammoPerShot)}
      </LabeledList.Item>
    </LabeledList>
  );
}
