import { useBackend } from "../backend";
import { Box, Button, ByondUi, Icon, Stack } from "../components";
import { Window } from "../layouts";

const CLOTHING_CELL_SIZE = 32;
const CLOTHING_ROWS = 9;

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

const CharacterPreview = (props: {
  id: string,
}) => {
  return (
    <Stack>
      <Stack.Item>
        <ByondUi
          width="220px"
          height={`${CLOTHING_ROWS * CLOTHING_CELL_SIZE}px`}
          params={{
            zoom: 0,
            id: props.id,
            type: "map",
          }}
        />
      </Stack.Item>
    </Stack>
  );
};

export const PreferencesMenu = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

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
                <Stack
                  vertical
                  fill
                  style={{ width: `${CLOTHING_CELL_SIZE}px` }}
                >
                  {Object.entries(data.character_preferences.clothing)
                    .map(([clothingKey, clothing]) => {
                      // MOTHBLOCKS TODO: Better nude icons, rather than X
                      return (
                        <Stack.Item key={clothingKey}>
                          <Button style={{
                            height: `${CLOTHING_CELL_SIZE}px`,
                            width: `${CLOTHING_CELL_SIZE}px`,
                          }} tooltip={clothing.value}>
                            <Box as="img" src={clothing.icon} style={{
                              // CODE REVIEW: This is copied and pasted from
                              // StripMenu, should this be a class? What would
                              // it be called?
                              position: "absolute",
                              height: "100%",
                              left: "50%",
                              top: "50%",
                              transform:
                                "translateX(-50%) translateY(-50%) scale(0.8)",
                            }} />
                          </Button>
                        </Stack.Item>
                      );
                    })}
                </Stack>
              </Stack.Item>

              <Stack.Item>
                <CharacterPreview id={data.character_preview_view} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
