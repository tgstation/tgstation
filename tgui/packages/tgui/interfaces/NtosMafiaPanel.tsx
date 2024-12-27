import { NtosWindow } from '../layouts';
import { MafiaPanelData } from './MafiaPanel';

export const NtosMafiaPanel = (props) => {
  return (
    <NtosWindow width={900} height={600}>
      <NtosWindow.Content>
        <MafiaPanelData />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
