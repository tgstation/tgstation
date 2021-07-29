import { binaryInsertWith } from "common/collections";
import { classes } from "common/react";
import { useBackend, useLocalState } from "../../backend";
import { Box, Button, Divider, Flex, Section, Stack, Tooltip } from "../../components";
import { PreferencesMenuData } from "./data";

export const GamePreferencesPage = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  return <b>hi</b>;
};
