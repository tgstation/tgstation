import { BountyBoardContent } from './BountyBoard';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  PC_device_theme: string;
};

export const NtosBountyBoard = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { PC_device_theme } = data;
  return (
    <NtosWindow width={550} height={600} theme={PC_device_theme}>
      <NtosWindow.Content scrollable>
        <BountyBoardContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
