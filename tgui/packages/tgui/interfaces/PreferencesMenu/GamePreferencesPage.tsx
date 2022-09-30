import { binaryInsertWith, sortBy } from "common/collections";
import { InfernoNode } from "inferno";
import { useBackend } from "../../backend";
import { Box, Flex, Tooltip } from "../../components";
import { PreferencesMenuData } from "./data";
import features from "./preferences/features";
import { FeatureValueInput } from "./preferences/features/base";
import { TabbedMenu } from "./TabbedMenu";

type PreferenceChild = {
  name: string,
  children: InfernoNode,
};

const binaryInsertPreference = binaryInsertWith<PreferenceChild>(
  (child) => child.name,
);

const sortByName = sortBy<[string, PreferenceChild[]]>(([name]) => name);

export const GamePreferencesPage = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  const gamePreferences: Record<string, PreferenceChild[]> = {};

  for (const [featureId, value] of Object.entries(
    data.character_preferences.game_preferences
  )) {
    const feature = features[featureId];

    let nameInner: InfernoNode = feature?.name || featureId;

    if (feature?.description) {
      nameInner = (
        <Box as="span" style={{
          "border-bottom": "2px dotted rgba(255, 255, 255, 0.8)",
        }}>
          {nameInner}
        </Box>
      );
    }

    let name: InfernoNode = (
      <Flex.Item grow={1} pr={2} basis={0} ml={2}>
        {nameInner}
      </Flex.Item>
    );

    if (feature?.description) {
      name = (
        <Tooltip content={feature.description} position="bottom-start">
          {name}
        </Tooltip>
      );
    }

    const child = (
      <Flex align="center" key={featureId} pb={2}>
        {name}

        <Flex.Item grow={1} basis={0}>
          {feature && <FeatureValueInput
            feature={feature}
            featureId={featureId}
            value={value}
            act={act}
          /> || (
            <Box as="b" color="red">
              ...is not filled out properly!!!
            </Box>
          )}
        </Flex.Item>
      </Flex>
    );

    const entry = {
      name: feature?.name || featureId,
      children: child,
    };

    const category = feature?.category || "ERROR";

    gamePreferences[category]
      = binaryInsertPreference(gamePreferences[category] || [], entry);
  }

  const gamePreferenceEntries: [string, InfernoNode][] = sortByName(
    Object.entries(gamePreferences)
  ).map(
    ([category, preferences]) => {
      return [category, preferences.map(entry => entry.children)];
    });

  return (
    <TabbedMenu
      categoryEntries={gamePreferenceEntries}
      contentProps={{
        fontSize: 1.5,
      }}
    />
  );
};
