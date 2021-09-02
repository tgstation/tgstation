import { Button, Stack } from "../../../../components";
import { RandomSetting } from "../../data";
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

        {/* MOTHBLOCKS TODO: */}
        <Stack.Item>
          <Button>
            Randomize
          </Button>
        </Stack.Item>
      </Stack>
    );
  },
};
