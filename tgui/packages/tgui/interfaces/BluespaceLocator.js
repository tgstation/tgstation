import { useBackend } from '../backend';
import { Section } from '../components';
import { Window } from '../layouts';

export const BluespaceLocator = (props, context) => {
  const { data } = useBackend(context);
  const {
    telebeacons, 
    trackimplants,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Hello, world!">
          We can put words and stuff and things here!
        </Section>
      </Window.Content>
    </Window>
  );
};