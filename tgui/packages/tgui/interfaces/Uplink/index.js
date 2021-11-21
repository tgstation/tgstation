import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { GenericUplink } from './GenericUplink';

export const MAX_SEARCH_RESULTS = 25;

export const Uplink = (props, context) => {
  const { data } = useBackend(context);
  const { telecrystals } = data;
  return (
    <Window
      width={620}
      height={580}
      theme="syndicate">
      <Window.Content scrollable>
        <GenericUplink
          currencyAmount={telecrystals}
          currencySymbol="TC" />
      </Window.Content>
    </Window>
  );
};


