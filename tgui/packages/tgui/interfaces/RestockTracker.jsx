import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

export const RestockTracker = (props) => {
  const { data } = useBackend();
  const vending_list = data.vending_list || [];
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
            <hr />
            {vending_list?.map((vend) => (
              <Stack key={vend.id} fill horizontal>
                <Stack.Item wrap width="45%" height="100%">
                  {vend.name}
                </Stack.Item>
                <Stack.Item wrap width="15%" height="100%">
                  {vend.location}
                </Stack.Item>
                <Stack.Item
                  wrap
                  width="20%"
                  color={
                    vend.percentage > 60
                      ? 'good'
                      : vend.percentage > 30
                        ? 'orange'
                        : 'bad'
                  }
                >
                  {vend.percentage}
                </Stack.Item>
                <Stack.Item
                  wrap
                  width="20%"
                  color={vend.credits > 100 ? 'good' : 'bad'}
                >
                  {vend.credits}
                </Stack.Item>
              </Stack>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
