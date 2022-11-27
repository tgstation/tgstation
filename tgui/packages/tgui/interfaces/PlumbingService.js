import { classes } from 'common/react';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { Section, Tabs, Button, Stack, Box } from '../components';
import { ColorItem, LayerSelect } from './RapidPipeDispenser';

const PlumbingTypeSection = (props, context) => {
  const { act, data } = useBackend(context);
  const { categories = [] } = data;
  const [categoryName, setCategoryName] = useLocalState(
    context,
    'categoryName'
  );
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];
  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category, i) => (
          <Tabs.Tab
            fluid
            key={category.cat_name}
            selected={category.cat_name === shownCategory.cat_name}
            onClick={() => setCategoryName(category.cat_name)}>
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.recipes.map((recipe) => (
        <Button.Checkbox
          key={recipe.index}
          fluid
          ellipsis
          checked={recipe.selected}
          content={recipe.name}
          title={recipe.name}
          onClick={() =>
            act('recipe', {
              id: recipe.index,
            })
          }
        />
      ))}
    </Section>
  );
};

const ColorSection = (props, context) => {
  return (
    <Section>
      <ColorItem />
    </Section>
  );
};

const LayerSection = (props, context) => {
  return (
    <Section>
      <LayerSelect />
    </Section>
  );
};

const IconSection = (props, context) => {
  const { data } = useBackend(context);
  const { icon } = data;
  return (
    <Section
      backgroundColor="green"
      style={{
        width: '50px',
        height: '50px',
      }}>
      <Box
        className={classes(['pservice32x32', icon])}
        style={{
          transform: 'scale(1.5) translate(9%, 9.5%)',
        }}
      />
    </Section>
  );
};

export const PlumbingService = (props, context) => {
  return (
    <Window width={450} height={575}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <ColorSection />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item>
                <Stack vertical fill>
                  <Stack.Item>
                    <LayerSection />
                  </Stack.Item>
                  <Stack.Item grow>
                    <IconSection />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <PlumbingTypeSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
