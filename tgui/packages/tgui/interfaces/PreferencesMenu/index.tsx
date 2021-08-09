import { exhaustiveCheck } from "common/exhaustive";
import { sendAct, useBackend, useLocalState } from "../../backend";
import { CharacterProfile, PreferencesMenuData } from "./data";
import { CharacterPreferenceWindow } from "./CharacterPreferenceWindow";

enum Window {
  Character = "character",
  Game = "game",
}

export const PreferencesMenu = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  const window = Window.Character as Window;

  switch (window) {
    case Window.Character:
      return <CharacterPreferenceWindow />;
    case Window.Game:
      throw "NYI";
    default:
      exhaustiveCheck(window);
  }

  // return (
  //   <Window title={
  //     CHARACTER_PREFERENCE_PAGES.has(currentPage)
  //       ? "Character Preferences"
  //       : "Game Preferences"
  //   } width={920} height={770} scrollable>
  //     <Window.Content>
  //       <Stack vertical fill>
  //         {CHARACTER_PREFERENCE_PAGES.has(currentPage) && (
  //           <>
  //             <Stack.Item>
  //               <CharacterProfiles
  //                 activeName={data.active_name}
  //                 onClick={(slot) => {
  //                   act("change_slot", {
  //                     slot: slot + 1,
  //                   });
  //                 }} profiles={data.character_profiles} />
  //             </Stack.Item>
  //             <Stack.Divider />
  //           </>
  //         )}

  //         <Stack.Item>
  //           {page}
  //         </Stack.Item>
  //       </Stack>
  //     </Window.Content>
  //   </Window>
  // );
};
