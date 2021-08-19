import { classes } from "common/react";
import { createDropdownInput, createNumberInput, Feature } from "../base";
import { Box, Button, Dropdown, Flex, NumberInput, Stack } from "../../../../../components";
import { AssetWithIcon } from "../../../data";

const UIStyleInput = (props: {
  name: string;
}) => {
  return (
    <Flex>
      <Flex.Item grow={1}>
        {props.name}
      </Flex.Item>

      <Flex.Item>
        <Box className={classes([
          "preferences64x32",
          `UI_style___${props.name}`,
        ])} style={{
          "transform": "scale(0.8)",
        }} />
      </Flex.Item>
    </Flex>
  );
};

export const UI_style: Feature<string, string> = {
  name: "UI Style",
  category: "UI",

  // MOTHBLOCKS TODO: available_ui_styles.
  // MOTHBLOCKS TODO: We don't need the server telling us the icons, we
  // can figure that out just from this fixed list.
  createComponent: createDropdownInput({
    Clockwork: <UIStyleInput name="Clockwork" />,
    Glass: <UIStyleInput name="Glass" />,
    Midnight: <UIStyleInput name="Midnight" />,
    Operative: <UIStyleInput name="Operative" />,
    Plasmafire: <UIStyleInput name="Plasmafire" />,
    Retro: <UIStyleInput name="Retro" />,
    Slimecore: <UIStyleInput name="Slimecore" />,
  }, {
    clipSelectedText: false,
  }),
};
