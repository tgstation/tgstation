import { useBackend } from "../../../../backend";
import { Button, Stack } from "../../../../components";
import { PreferencesMenuData, RandomSetting } from "../../data";
import { RandomizationButton } from "../../RandomizationButton";
import { Feature } from "./base";

export const random_body: Feature<RandomSetting> = {
  name: "Random body",
  component: (props) => {
    return (
      <Stack>
        <Stack.Item>
          <RandomizationButton
            setValue={(newValue) => props.handleSetValue(newValue)}
            value={props.value}
          />
        </Stack.Item>

        {/* MOTHBLOCKS TODO:
          This probably warrants an actual context component */}
        <Stack.Item>
          <Button>
            Randomize
          </Button>
        </Stack.Item>
      </Stack>
    );
  },
};

export const random_species: Feature<RandomSetting> = {
  name: "Random species",
  component: (props, context) => {
    const { act, data } = useBackend<PreferencesMenuData>(context);

    const species = data.character_preferences.randomization["species"];

    return (
      <RandomizationButton
        setValue={(newValue) => act("set_random_preference", {
          preference: "species",
          value: newValue,
        })}
        value={species || RandomSetting.Disabled}
      />
    );
  },
};
