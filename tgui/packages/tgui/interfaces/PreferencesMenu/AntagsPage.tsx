import { binaryInsertWith } from "common/collections";
import { classes } from "common/react";
import { useBackend, useLocalState } from "../../backend";
import { Box, Button, Divider, Flex, Section, Stack, Tooltip } from "../../components";
import { logger } from "../../logging";
import { Antagonist, Category } from "./antagonists/base";
import { PreferencesMenuData } from "./data";

const requireAntag = require.context("./antagonists/antagonists", false, /.ts$/);

const antagsByCategory = new Map<Category, Antagonist[]>();

const binaryInsertAntag = binaryInsertWith((antag: Antagonist) => {
  return antag.priority || 1;
});

for (const antagKey of requireAntag.keys()) {
  const antag = requireAntag<{
    default?: Antagonist,
  }>(antagKey).default;

  if (!antag) {
    continue;
  }

  antagsByCategory.set(
    antag.category,
    binaryInsertAntag(
      antagsByCategory.get(antag.category) || [],
      {
        key: antagKey,
        ...antag,
      },
    )
  );
}

const AntagSelection = (props: {
  antagonists: Antagonist[],
  name: string,
}, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const className = "PreferencesMenu__Antags__antagSelection";

  const [predictedState, setPredictedState]
    = useLocalState(
      context,
      "AntagSelection_predictedState",
      new Set(data.selected_antags),
    );

  const enableAntags = (antags: string[]) => {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.add(antag);
    }

    setPredictedState(newState);

    act("set_antags", {
      antags,
      toggled: true,
    });
  };

  const disableAntags = (antags: string[]) => {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.delete(antag);
    }

    setPredictedState(newState);

    act("set_antags", {
      antags,
      toggled: false,
    });
  };

  const antagonistKeys = props.antagonists.map(antagonist => antagonist.key);

  return (
    <Section title={props.name} buttons={(
      <>
        <Button
          color="good"
          onClick={() => enableAntags(antagonistKeys)}
        >
          Enable All
        </Button>

        <Button
          color="bad"
          onClick={() => disableAntags(antagonistKeys)}
        >
          Disable All
        </Button>
      </>
    )}>
      <Flex className={className}>
        {props.antagonists.map(antagonist => {
          return (
            <Flex.Item
              className={classes([
                `${className}__antagonist`,
                `${className}__antagonist--${
                  predictedState.has(antagonist.key) ? "on" : "off"
                }`,
              ])}
              key={antagonist.key}
            >
              <Stack vertical>
                <Stack.Item style={{
                  "font-weight": "bold",
                  "max-width": "100px",
                  "text-align": "center",
                }}>
                  {antagonist.name}
                </Stack.Item>

                <Stack.Item>
                  <Tooltip content={
                    <>
                      {antagonist.description.map((text, index) => {
                        return (
                          <div key={index}>
                            {text}
                            {
                              index !== antagonist.description.length - 1
                               && <Divider />
                            }
                          </div>
                        );
                      })}
                    </>
                  } position="bottom">
                    <Box
                      className={"antagonist-icon-parent"}
                      onClick={() => {
                        if (predictedState.has(antagonist.key)) {
                          disableAntags([antagonist.key]);
                        } else {
                          enableAntags([antagonist.key]);
                        }
                      }}
                    >
                      <Box className={classes([
                        "antagonists96x96",
                        antagonist.key,
                        "antagonist-icon",
                      ])} />
                    </Box>
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </Flex.Item>
          );
        })}
      </Flex>
    </Section>
  );
};

export const AntagsPage = (props, context) => {
  return (
    <Stack className="PreferencesMenu__Antags" vertical fill>
      <Stack.Item>
        <AntagSelection
          name="Roundstart"
          antagonists={antagsByCategory.get(Category.Roundstart)}
        />
      </Stack.Item>

      <Stack.Item>
        <AntagSelection
          name="Midround"
          antagonists={antagsByCategory.get(Category.Midround)}
        />
      </Stack.Item>

      <Stack.Item>
        <AntagSelection
          name="Latejoin"
          antagonists={antagsByCategory.get(Category.Latejoin)}
        />
      </Stack.Item>
    </Stack>
  );
};
