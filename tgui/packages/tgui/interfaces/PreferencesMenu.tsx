import { useBackend } from "../backend";
import { Box, Button, ByondUi, Icon, Stack } from "../components";
import { Window } from "../layouts";

type CharacterProfile = {
  name: string;
};

type PreferencesMenuData = {
  character_preview_view: string,
  character_profiles: (CharacterProfile | null)[],
};

const CharacterProfiles = (props: {
  profiles: (CharacterProfile | null)[],
}) => {
  const { profiles } = props;

  return (
    <Stack justify="center" wrap>
      {profiles.map((profile, index) => (
        <Stack.Item key={index}>
          <Button fluid>{profile ? profile.name : "New Character"}</Button>
        </Stack.Item>
      ))}
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
            <CharacterProfiles profiles={data.character_profiles} />
          </Stack.Item>

          <Stack.Divider />

          <Stack.Item height="200px">
            <ByondUi
              height="100%"
              params={{
                zoom: 6,
                id: data.character_preview_view,
                type: "map",
              }}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
