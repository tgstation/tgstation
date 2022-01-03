import { useBackend } from '../backend';
import { Stack, Section, ByondUi, Button } from '../components';
import { Window } from '../layouts';

export const BarberPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hairstyles,
    selected_hairstyle,
    facial_hairstyles,
    selected_facial_hairstyle,
    assigned_map,
  } = data;
  return (
    <Window
      title="Haircut Menu"
      width={900}
      height={670}
      theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Section fill scrollable title="Haircuts">
              <Stack grow vertical>
                {Object.keys(hairstyles).map(item => (
                  <Stack.Item key={item}>
                    <Stack fontSize="15px">
                      <Stack.Item grow align="left">
                        {item}
                      </Stack.Item>
                      <Stack.Item>
                        <Button.Checkbox
                          checked={selected_hairstyle === item}
                          content="Select"
                          fluid
                          onClick={() => act('select_hair', {
                            name: item,
                          })} />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Beards">
              <Stack grow vertical>
                {Object.keys(facial_hairstyles).map(item => (
                  <Stack.Item key={item}>
                    <Stack fontSize="15px">
                      <Stack.Item grow align="left">
                        {item}
                      </Stack.Item>
                      <Stack.Item>
                        <Button.Checkbox
                          checked={selected_facial_hairstyle === item}
                          content="Select"
                          fluid
                          onClick={() => act('select_beard', {
                            name: item,
                          })} />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Character Preview">
              <Stack vertical>
                <Stack.Item grow>
                  <ByondUi
                    height="100%"
                    width="100%"
                    className="BarberPanel__northPreview"
                    params={{
                      id: assigned_map,
                      type: 'map',
                    }} />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
