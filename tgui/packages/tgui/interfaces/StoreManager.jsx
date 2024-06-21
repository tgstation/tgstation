import { useBackend, useSharedState } from '../backend';
import { Box, Button, Section, Stack, Dropdown } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';

export const StoreManager = (props) => {
  const { act, data } = useBackend();
  const { loadout_tabs, total_coins, owned_items } = data;

  const [selectedTabName, setSelectedTab] = useSharedState(
    'tabs',
    loadout_tabs[0]?.name
  );
  const selectedTab = loadout_tabs.find((curTab) => {
    return curTab.name === selectedTabName;
  });

  return (
    <Window title="Store Manager" width={500} height={650} theme="generic">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Store Categories"
              align="center"
              buttons={
                <Button
                  icon="fa-solid fa-coins"
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
                  <Section
                    title={selectedTab.title}
                    fill
                    scrollable
                    align="center">
                    <Stack
                      direction="row"
                      textAlign="center"
                      align="center"
                      wrap>
                      {selectedTab.contents.map((item) => (
                        <Stack.Item
                          class="thisissettostopwiththebullshit"
                          key={item.name}
                          minWidth="50%"
                          wrap
                          backgroundColor="rgba(52, 204, 235, 0.3)"
                          style={{
                            border: '2px double silver',
                            'border-radius': '5px',
                          }}>
                          <Stack.Item>
                            <Stack.Item>
                              <Box
                                as="img"
                                src={resolveAsset(item.icon)}
                                height="192px"
                                style={{
                                  '-ms-interpolation-mode': 'nearest-neighbor',
                                  'image-rendering': 'pixelated',
                                }}
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                fluid
                                backgroundColor="transparent"
                                content={item.name}
                                tooltip={item.desc}
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                fluid
                                content="Job Restricted"
                                disabled={!item.job_restricted}
                                tooltip={item.job_restricted}
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button.Confirm
                                content="Purchase"
                                minWidth="49%"
                                disabled={
                                  owned_items.includes(item.item_path) ||
                                  total_coins < item.cost
                                }
                                onClick={() =>
                                  act('select_item', {
                                    path: item.path,
                                  })
                                }
                              />
                              <Button
                                icon="fa-solid fa-coins"
                                backgroundColor="transparent"
                                content={item.cost}
                                minWidth="49%"
                                tooltip="This is the cost of the item."
                              />
                            </Stack.Item>
                          </Stack.Item>
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
