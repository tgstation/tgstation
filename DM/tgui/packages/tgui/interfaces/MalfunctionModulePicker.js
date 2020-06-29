import { useBackend } from '../backend';
import { Window } from '../layouts';
import { GenericUplink } from './Uplink';

export const MalfunctionModulePicker = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    processingTime,
  } = data;
  return (
    <Window
      theme="malfunction"
      resizable>
      <Window.Content scrollable>
        <GenericUplink
          currencyAmount={processingTime}
          currencySymbol="PT" />
      </Window.Content>
    </Window>
  );
};
