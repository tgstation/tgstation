// @ts-nocheck
import { useBackend, useSharedState, useLocalState } from '../../backend';
import { Box, Button, Section, Stack, Dropdown, FitText } from '../../components';
import { CharacterPreview } from '../common/CharacterPreview';
import { PreferencesMenuData, createSetPreference } from './data';
import { NameInput } from './names';

const CLOTHING_CELL_SIZE = 64;
const CLOTHING_SIDEBAR_ROWS = 10;

const CLOTHING_SELECTION_CELL_SIZE = 64;
const CLOTHING_SELECTION_WIDTH = 6.3;
const CLOTHING_SELECTION_MULTIPLIER = 5.2;

const CharacterControls = (props: {
  handleRotate: () => void;
  handleStore: () => void;
}) => {
  return (
    <Stack>
      <Stack.Item>
        <Button
          onClick={props.handleRotate}
          fontSize="22px"
          icon="undo"
          tooltip="Rotate"
          tooltipPosition="top"
        />
      </Stack.Item>
      {props.handleStore && (
        <Stack.Item>
          <Button
            onClick={props.handleStore}
            fontSize="22px"
            icon="sack-dollar"
            tooltip="Show Store Menu"
            tooltipPosition="top"
          />
        </Stack.Item>
      )}
    </Stack>
  );
};

export const LoadoutManager = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const {
    selected_loadout,
    loadout_tabs,
    user_is_donator,
    total_coins,
    selected_unusuals,
  } = data;
  const [multiNameInputOpen, setMultiNameInputOpen] = useLocalState(
    context,
    'multiNameInputOpen',
    false
  );
  const [selectedTabName, setSelectedTab] = useSharedState(
    context,
    'tabs',
    loadout_tabs[0]?.name
  );
  const selectedTab = loadout_tabs.find((curTab) => {
    return curTab.name === selectedTabName;
  });

  return (
    <Stack height={`${CLOTHING_SIDEBAR_ROWS * CLOTHING_CELL_SIZE}px`}>
      <Stack.Item fill>
        <Stack vertical fill>
          <Stack.Item>
            <Stack horiztonal fill>
              <Stack.Item>
                <CharacterControls
                  handleRotate={() => {
                    act('rotate');
                  }}
                  handleStore={() => {
                    act('open_store');
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  width={`${CLOTHING_CELL_SIZE * 2}px`}
                  height="37px"
                  fontSize="22px"
                  icon="fa-solid fa-coins"
                  align="center"
                  tooltip="This is your total Monkecoin amount.">
                  <FitText maxFontSize={22} maxWidth={CLOTHING_CELL_SIZE * 1}>
                    {total_coins}
                  </FitText>
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow>
            <CharacterPreview height="100%" id={data.character_preview_view} />
          </Stack.Item>

          <Stack.Item position="relative">
            <NameInput
              name={data.character_preferences.names[data.name_to_use]}
              handleUpdateName={createSetPreference(act, data.name_to_use)}
              openMultiNameInput={() => {
                setMultiNameInputOpen(false);
              }}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item width={`${CLOTHING_CELL_SIZE * 16 + 15}px`}>
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
                                checked={
                                  selected_loadout.includes(item.path) ||
                                  (selected_unusuals.includes(
                                    item.unusual_placement
                                  ) &&
                                    item.unusual_spawning_requirements)
                                }
                                content="Select"
                                disabled={
                                  item.is_donator_only && !user_is_donator
                                }
                                fluid
                                onClick={() =>
                                  act('select_item', {
                                    path: item.path,
                                    unusual_spawning_requirements:
                                      item.unusual_spawning_requirements,
                                    unusual_placement: item.unusual_placement,
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
      </Stack.Item>
    </Stack>
  );
};
