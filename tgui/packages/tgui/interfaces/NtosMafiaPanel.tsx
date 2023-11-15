import { MafiaPanelData } from './MafiaPanel';
import { NtosWindow } from '../layouts';

export const NtosMafiaPanel = (props, context) => {
  return (
    <NtosWindow width={900} height={600}>
      <NtosWindow.Content>
        <MafiaPanelData />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
