import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const RequestKiosk = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    health,
    color,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Health status">
          Test
        </Section>
      </Window.Content>
    </Window>
  );
};