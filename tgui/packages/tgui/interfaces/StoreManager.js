import { useBackend, useSharedState } from '../backend';
import { Box, Button, Section, Stack, Dropdown } from '../components';
import { Window } from '../layouts';

export const StoreManager = (props, context) => {
  const { act, data } = useBackend(context);
  const { loadout_tabs, total_coins } = data;

  const [selectedTabName, setSelectedTab] = useSharedState(
    context,
    'tabs',
    loadout_tabs[0]?.name
  );
  const selectedTab = loadout_tabs.find((curTab) => {
    return curTab.name === selectedTabName;
  });

  return (
    <Window title="Store Manager" width={500} height={650}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Store Categories"
              align="center"
              buttons={
                <Button
                  icon="coin"
                  align="center"
                  content={total_coins}
                  tooltip="This is your total Monkecoin amount."
                />
              }>
              <Dropdown
                width="100%"
                selected={selectedTabName}
                displayText={selectedTabName}
                options={loadout_tabs.map((curTab) => ({
                  value: curTab,
                  displayText: curTab.name,
                }))}
                onSelected={(curTab) => setSelectedTab(curTab.name)}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow>
                {selectedTab && selectedTab.contents ? (
                  <Section title={selectedTab.title} fill scrollable>
                    <Stack grow vertical>
                      {selectedTab.contents.map((item) => (
                        <Stack.Item key={item.name}>
                          <Stack fontSize="15px">
                            <Stack.Item grow align="left">
                              {item.name} {item.cost}
                              <Stack.Item>
                                <Button.Checkbox
                                  content="Select"
                                  fluid
                                  onClick={() =>
                                    act('select_item', {
                                      path: item.path,
                                    })
                                  }
                                />
                              </Stack.Item>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Section>
                ) : (
                  <Section fill>
                    <Box>No contents for selected tab.</Box>
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
