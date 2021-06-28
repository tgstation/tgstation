import { exhaustiveCheck } from "common/exhaustive";
import { classes } from "common/react";
import { sendAct, useBackend, useLocalState } from "../../backend";
import { Box, Button, ByondUi, Flex, Icon, Popper, Stack } from "../../components";
import { Window } from "../../layouts";
import { CharacterProfile, PreferencesMenuData } from "./data";
import { MainPage } from "./MainPage";
import { SpeciesPage } from "./SpeciesPage";

enum Page {
  Main,
  Species,
}

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

export const PreferencesMenu = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const [currentPage, setCurrentPage] = useLocalState(context, "currentPage", Page.Main);

  let page;

  switch (currentPage) {
    case Page.Main:
      page = <MainPage />;
      break;
    case Page.Species:
      page = <SpeciesPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Window title="Character Preferences" width={640} height={770}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            {/* MOTHBLOCKS TODO: Change activeName to slot indexes */}
            <CharacterProfiles activeName={data.real_name} onClick={(slot) => {
              act("change_slot", {
                slot: slot + 1,
              });
            }} profiles={data.character_profiles} />
          </Stack.Item>

          <Stack.Divider />

          <Stack.Item>
            {page}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
