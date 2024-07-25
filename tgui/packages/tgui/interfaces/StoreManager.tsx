import { useBackend, useSharedState } from '../backend';
import { Box, Button, Section, Stack, Tabs, Table } from '../components';
import { PreferencesMenuData } from './PreferencesMenu/data';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';

export const StoreManager = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { loadout_tabs, total_coins, owned_items } = data;

  const [selectedTabName, setSelectedTab] = useSharedState(
    'tabs',
    loadout_tabs[0]?.name,
  );
  const selectedTab = loadout_tabs.find(
    (curTab) => curTab.name === selectedTabName,
  );

  return (
    <Window title="Store Manager" width={850} height={500} theme="generic">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Store Categories"
              align="center"
              buttons={
                <Button
                  icon="fa-solid fa-coins"
                  content={total_coins}
                  tooltip="This is your total Monkecoin amount."
                />
              }
            >
              <Tabs>
                {loadout_tabs.map((curTab) => (
                  <Tabs.Tab
                    key={curTab.name}
                    selected={selectedTabName === curTab.name}
                    onClick={() => setSelectedTab(curTab.name)}
                  >
                    {curTab.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title={selectedTab?.title || 'Store Items'}
              fill
              scrollable
            >
              <Table>
                <Table.Row header>
                  <Table.Cell style={{ width: '5%' }} />
                  <Table.Cell style={{ width: '75%' }}>Name</Table.Cell>
                  <Table.Cell style={{ width: '10%', textAlign: 'right' }}>
                    Cost
                  </Table.Cell>
                  <Table.Cell style={{ width: '10%', textAlign: 'right' }}>
                    Purchase
                  </Table.Cell>
                </Table.Row>
                {selectedTab && selectedTab.contents ? (
                  selectedTab.contents.map((item, index) => (
                    <Table.Row
                      key={item.name}
                      backgroundColor={index % 2 === 0 ? '#19181e' : '#16151b'}
                    >
                      <Table.Cell>
                        <Box
                          as="img"
                          src={resolveAsset(item.icon)}
                          height="32px"
                          style={{
                            '-ms-interpolation-mode': 'nearest-neighbor',
                            'image-rendering': 'pixelated',
                          }}
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          fluid
                          backgroundColor="transparent"
                          content={item.name}
                          tooltip={item.desc}
                        />
                      </Table.Cell>
                      <Table.Cell style={{ textAlign: 'right' }}>
                        <Box display="flex" justifyContent="flex-end">
                          <Button
                            icon="fa-solid fa-coins"
                            backgroundColor="transparent"
                            content={item.cost}
                            tooltip="This is the cost of the item."
                          />
                        </Box>
                      </Table.Cell>
                      <Table.Cell style={{ textAlign: 'right' }}>
                        <Box display="flex" justifyContent="flex-end">
                          <Button.Confirm
                            content={
                              owned_items.includes(item.item_path)
                                ? 'Owned'
                                : 'Purchase'
                            }
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
                        </Box>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell colSpan={4} align="center">
                      <Box>No contents for selected tab.</Box>
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
