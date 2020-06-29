import { useBackend } from '../backend';
import { Window } from '../layouts';
import { GenericUplink } from './Uplink';

export const AbductorConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    points,
  } = data;
  return (
    <Window
      theme="abductor"
      resizable>
      <Window.Content scrollable>
        <GenericUplink
          currencyAmount={points}
          currencySymbol="PT" />
      </Window.Content>
    </Window>
  );
};
