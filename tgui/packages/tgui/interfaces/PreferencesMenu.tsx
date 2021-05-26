import { classes } from "common/react";
import { sendAct, useBackend, useLocalState } from "../backend";
import { Box, Button, ByondUi, Flex, Icon, Popper, Stack } from "../components";
import { Window } from "../layouts";

const CLOTHING_CELL_SIZE = 32;
const CLOTHING_SIDEBAR_ROWS = 9;

const CLOTHING_SELECTION_CELL_SIZE = 48;
const CLOTHING_SELECTION_WIDTH = 5.4;
const CLOTHING_SELECTION_MULTIPLIER = 5.2;

// MOTHBLOCKS TODO: Put this in the datum, or perhaps derive it?
const KEYS_TO_NAMES = {
  backpack: "Backpack",
  underwear: "Underwear",
};

enum Gender {
  Male = "male",
  Female = "female",
  Other = "plural",
}

type CharacterProfile = {
  name: string;
};

type AssetWithIcon = {
  icon: string;
  value: string;
};

type PreferencesMenuData = {
  character_preview_view: string;
  character_profiles: (CharacterProfile | null)[];

  real_name: string;

  character_preferences: {
    clothing: Record<string, AssetWithIcon>;

    misc: {
      gender: Gender;
    };
  };

  generated_preference_values?: Record<string, Record<string, string>>;
};

const createSetPreference = (
  act: typeof sendAct,
  preference: string
) => (value: string) => {
  act("set_preference", {
    preference,
    value,
  });
};

const CharacterProfiles = (props: {
  activeName: string,
  onClick: (index: number) => void,
  profiles: (CharacterProfile | null)[],
}) => {
  const { profiles } = props;

  return (
    <Stack justify="center" wrap>
      {profiles.map((profile, index) => (
        <Stack.Item key={index}>
          <Button
            selected={profile && profile.name === props.activeName}
            onClick={() => {
              props.onClick(index);
            }} fluid>{profile ? profile.name : "New Character"}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
};

const CharacterControls = (props: {
  handleRotate: () => void,
}) => {
  return (
    <Stack>
      <Stack.Item>
        <Button
          onClick={props.handleRotate}
          fontSize="16px"
          icon="sync"
        />
      </Stack.Item>
    </Stack>
  );
};

const CharacterPreview = (props: {
  id: string,
}) => {
  return (
    <Stack>
      <Stack.Item>
        <ByondUi
          width="220px"
          height={`${CLOTHING_SIDEBAR_ROWS * CLOTHING_CELL_SIZE}px`}
          params={{
            id: props.id,
            type: "map",
          }}
        />
      </Stack.Item>
    </Stack>
  );
};

const ClothingSelection = (props: {
  name: string,
  catalog: Record<string, string>,
  selected: string,
  onSelect: (value: string) => void,
}) => {
  return (
    <Box style={{
      background: "white",
      padding: "5px",
      width: `${CLOTHING_SELECTION_CELL_SIZE * CLOTHING_SELECTION_WIDTH}px`,
      height:
        `${CLOTHING_SELECTION_CELL_SIZE * CLOTHING_SELECTION_MULTIPLIER}px`,
    }}>
      <Stack vertical fill>
        <Stack.Item>
          <Box style={{
            "border-bottom": "1px solid #888",
            "font-size": "14px",
            "text-align": "center",
          }}>Select {props.name}
          </Box>
        </Stack.Item>

        <Stack.Item overflowY="scroll">
          <Flex wrap>
            {Object.entries(props.catalog).map(([name, image], index) => {
              return (
                <Flex.Item
                  key={index}
                  basis={`${CLOTHING_SELECTION_CELL_SIZE}px`}
                  style={{
                    padding: "5px",
                  }}
                >
                  <Button
                    onClick={() => {
                      props.onSelect(name);
                    }}
                    selected={name === props.selected}
                    tooltip={name}
                    tooltipPosition="right"
                    style={{
                      height: `${CLOTHING_SELECTION_CELL_SIZE}px`,
                      width: `${CLOTHING_SELECTION_CELL_SIZE}px`,
                    }}
                  >
                    <Box className={classes(["preferences32x32", image, "centered-image"])} />
                  </Button>
                </Flex.Item>
              );
            })}
          </Flex>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

export const PreferencesMenu = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const [currentClothingMenu, setCurrentClothingMenu] = useLocalState(context, "currentClothingMenu", null);

  const requestPreferenceData = (key: string) => {
    act("request_values", {
      preference: key,
    });
  };

  return (
    <Window title="Character Preferences" width={640} height={770}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <CharacterProfiles activeName={data.real_name} onClick={(slot) => {
              act("change_slot", {
                slot: slot + 1,
              });
            }} profiles={data.character_profiles} />
          </Stack.Item>

          <Stack.Divider />

          <Stack.Item>
            <Stack fill>
              <Stack.Item>
                <Stack vertical>
                  <Stack.Item>
                    <CharacterControls handleRotate={() => {
                      act("rotate");
                    }} />
                  </Stack.Item>

                  <Stack.Item>
                    <CharacterPreview id={data.character_preview_view} />
                  </Stack.Item>
                </Stack>
              </Stack.Item>

              <Stack.Item>
                <Stack
                  vertical
                  fill
                  width={`${CLOTHING_CELL_SIZE}px`}
                >
                  {Object.entries(data.character_preferences.clothing)
                    .map(([clothingKey, clothing]) => {
                      // MOTHBLOCKS TODO: Better nude icons, rather than X
                      return (
                        <Stack.Item key={clothingKey}>
                          <Popper options={{
                            placement: "bottom-start",
                          }} popperContent={
                            (currentClothingMenu === clothingKey
                              && data.generated_preference_values
                              && data.generated_preference_values[clothingKey])
                            && <ClothingSelection
                              name={KEYS_TO_NAMES[clothingKey]
                                || `NO NAME FOR ${clothingKey}`}
                              catalog={
                                data.generated_preference_values[clothingKey]
                              }
                              selected={clothing.value}
                              onSelect={createSetPreference(act, clothingKey)}
                            />
                          }>
                            <Button onClick={() => {
                              setCurrentClothingMenu(
                                currentClothingMenu === clothingKey
                                  ? null
                                  : clothingKey
                              );

                              requestPreferenceData(clothingKey);
                            }} style={{
                              height: `${CLOTHING_CELL_SIZE}px`,
                              width: `${CLOTHING_CELL_SIZE}px`,
                            }} tooltip={clothing.value} tooltipPosition="right">
                              <Box
                                className={classes([
                                  "preferences32x32",
                                  clothing.icon,
                                  "centered-image",
                                ])} />
                            </Button>
                          </Popper>
                        </Stack.Item>
                      );
                    })}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
