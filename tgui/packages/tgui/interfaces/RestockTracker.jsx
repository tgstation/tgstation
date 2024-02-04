import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

export const RestockTracker = (props) => {
  const { data } = useBackend();
  const { vending_list = [] } = data;
  return (
    <Window width={575} height={560}>
      <Window.Content scrollable>
        <Section fill title="Vendor Stocking Status">
          <Stack fill vertical>
            <Stack fill horizontal>
              <Stack.Item bold width="45%">
                Vending Name
              </Stack.Item>
              <Stack.Item bold width="15%">
                Location
              </Stack.Item>
              <Stack.Item bold width="20%">
                Stock %
              </Stack.Item>
              <Stack.Item bold width="20%">
                Credits stored
              </Stack.Item>
            </Stack>
            {/* {vending_list?.map((vend) => (
              <Section key={vend.id}>{vend.name}</Section>
            ))} */}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
