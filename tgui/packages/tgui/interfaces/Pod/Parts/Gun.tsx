import { LabeledList, ProgressBar } from 'tgui-core/components';

type Props = {
  ammo: number;
  maxAmmo: number;
  ammoPerShot: number;
  mode: string;
  ref: string;
};
export default function Gun(props: { ourProps: Props }): JSX.Element {
  const { ourProps } = props;
  return (
    <LabeledList>
      <LabeledList.Item label={'Firing Mode'}>{ourProps.mode}</LabeledList.Item>
      <LabeledList.Item>
        <ProgressBar value={ourProps.ammo / ourProps.maxAmmo}>
          {`${ourProps.ammo} of ${ourProps.maxAmmo}`}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label={'Shots remaining'}>
        {Math.floor(ourProps.ammo / ourProps.ammoPerShot)}
      </LabeledList.Item>
    </LabeledList>
  );
}
