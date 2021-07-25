import { binaryInsertWith } from "common/collections";
import { classes } from "common/react";
import { Box, Divider, Flex, Section, Stack, Tooltip } from "../../components";
import { logger } from "../../logging";
import { Antagonist, Category } from "./antagonists/base";

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
}) => {
  const className = "PreferencesMenu__Antags__antagSelection";

  return (
    <Section title={props.name}>
      <Flex className={className}>
        {props.antagonists.map(antagonist => {
          return (
            <Flex.Item
              className={classes([
                `${className}__antagonist`,
                `${className}__antagonist--off`,
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
                    <Box className={"antagonist-icon-parent"}>
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
