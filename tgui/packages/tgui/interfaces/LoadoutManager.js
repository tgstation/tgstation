import { useBackend, useSharedState } from '../backend';
import { Box, Button, Section, Stack, Dropdown } from '../components';
import { Window } from '../layouts';

export const LoadoutManager = (props, context) => {
  const { act, data } = useBackend(context);
  const { selected_loadout, loadout_tabs, user_is_donator } = data;

  const [selectedTabName, setSelectedTab] = useSharedState(
    context,
    'tabs',
    loadout_tabs[0]?.name
  );
  const selectedTab = loadout_tabs.find((curTab) => {
    return curTab.name === selectedTabName;
  });

  return (
    <Window title="Loadout Manager" width={500} height={650}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Loadout Categories"
              align="center"
              buttons={
                <Button
                  icon="info"
                  align="center"
                  content="Tutorial"
                  onClick={() => act('toggle_tutorial')}
                />
              }>
              <Button
                icon="check-double"
                color="good"
                content="Confirm"
                tooltip="Confirm loadout and exit UI."
                onClick={() => act('close_ui', { revert: 0 })}
              />
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
                    buttons={
                      <Button.Confirm
                        icon="times"
                        color="red"
                        align="center"
                        content="Clear All Items"
                        tooltip="Clears ALL selected items from all categories."
                        width={10}
                        onClick={() => act('clear_all_items')}
                      />
                    }>
                    <Stack grow vertical>
                      {selectedTab.contents.map((item) => (
                        <Stack.Item key={item.name}>
                          <Stack fontSize="15px">
                            <Stack.Item grow align="left">
                              {item.name}
                            </Stack.Item>
                            {!!item.is_greyscale && (
                              <Stack.Item>
                                <Button
                                  icon="palette"
                                  onClick={() =>
                                    act('select_color', {
                                      path: item.path,
                                    })
                                  }
                                />
                              </Stack.Item>
                            )}
                            {!!item.is_renamable && (
                              <Stack.Item>
                                <Button
                                  icon="pen"
                                  onClick={() =>
                                    act('set_name', {
                                      path: item.path,
                                    })
                                  }
                                />
                              </Stack.Item>
                            )}
                            {!!item.is_job_restricted && (
                              <Stack.Item>
                                <Button
                                  icon="lock"
                                  onClick={() =>
                                    act('display_restrictions', {
                                      path: item.path,
                                    })
                                  }
                                />
                              </Stack.Item>
                            )}
                            {!!item.is_donator_only && (
                              <Stack.Item>
                                <Button
                                  icon="heart"
                                  color="pink"
                                  onClick={() =>
                                    act('donator_explain', {
                                      path: item.path,
                                    })
                                  }
                                />
                              </Stack.Item>
                            )}
                            {!!item.is_ckey_whitelisted && (
                              <Stack.Item>
                                <Button
                                  icon="user-lock"
                                  onClick={() =>
                                    act('ckey_explain', {
                                      path: item.path,
                                    })
                                  }
                                />
                              </Stack.Item>
                            )}
                            <Stack.Item>
                              <Button.Checkbox
                                checked={selected_loadout.includes(item.path)}
                                content="Select"
                                disabled={
                                  item.is_donator_only && !user_is_donator
                                }
                                fluid
                                onClick={() =>
                                  act('select_item', {
                                    path: item.path,
                                    deselect: selected_loadout.includes(
                                      item.path
                                    ),
                                  })
                                }
                              />
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
