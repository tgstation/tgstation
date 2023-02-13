import { NtosWindow } from '../layouts';
import { StatusDisplayControls } from './common/StatusDisplayControls';

export const NtosStatus = () => {
  return (
    <NtosWindow width={400} height={350}>
      <NtosWindow.Content>
        <StatusDisplayControls />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
