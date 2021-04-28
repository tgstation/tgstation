import { useBackend } from "../backend";
import { Box, Button, ByondUi, Icon, Stack } from "../components";
import { Window } from "../layouts";

type CharacterProfile = {
  name: string;
};

type PreferencesMenuData = {
  character_preview_view: string,
  character_profiles: (CharacterProfile | null)[],

  real_name: string,
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
          height="300px"
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
              <CharacterPreview id={data.character_preview_view} />
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
