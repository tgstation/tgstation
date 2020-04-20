import { NtosWindow } from '../layouts';
import { StationAlertConsoleContent } from './StationAlertConsole';

export const NtosStationAlertConsole = () => {
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <StationAlertConsoleContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
