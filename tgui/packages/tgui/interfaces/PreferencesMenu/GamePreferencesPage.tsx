import { binaryInsertWith } from "common/collections";
import { classes } from "common/react";
import { useBackend, useLocalState } from "../../backend";
import { Box, Button, Divider, Flex, LabeledList, Section, Stack, Table, Tooltip } from "../../components";
import { PreferencesMenuData } from "./data";
import features from "./preferences/features";
import { FeatureValueInput } from "./preferences/features/base";

export const GamePreferencesPage = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  return (
    <Table fontSize={1.5}>
      {/* MOTHBLOCKS TODO: Sort in *literally* any way */}
      {/* Not ABC, since similar preferences should be together */}
      {/* Should also support dividers */}
      {Object.entries(data.character_preferences.game_preferences)
        .map(([featureId, value]) => {
          const feature = features[featureId];

          return (
            <Table.Row key={featureId}>
              <Table.Cell textAlign="right" width="50%" verticalAlign="middle">
                {feature.name}
              </Table.Cell>

              <Table.Cell verticalAlign="middle">
                <FeatureValueInput
                  feature={feature}
                  featureId={featureId}
                  value={value}
                  act={act}
                />
              </Table.Cell>
            </Table.Row>
          );
        })}
    </Table>
  );
};
