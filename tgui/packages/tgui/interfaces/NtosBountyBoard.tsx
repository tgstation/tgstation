import { NtosWindow } from '../layouts';
import { BountyBoardContent } from './BountyBoard';

export const NtosBountyBoard = (props) => {
  return (
    <NtosWindow width={550} height={600}>
      <NtosWindow.Content scrollable>
        <BountyBoardContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
