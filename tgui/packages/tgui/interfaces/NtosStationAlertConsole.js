import { NtosWindow } from '../layouts';
import { StationAlertConsoleContent } from './StationAlertConsole';

export const NtosStationAlertConsole = () => {
  return (
    <NtosWindow
      width={315}
      height={500}
      resizable>
      <NtosWindow.Content scrollable>
        <StationAlertConsoleContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
