import { BooleanLike, classes } from 'common/react';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { Section, Tabs, Button, Stack, Box } from '../components';
import { ColorItem, LayerSelect } from './RapidPipeDispenser';
import { capitalizeAll } from 'common/string';

type Data = {
  layer_icon: string;
  categories: Category[];
  selected_category: string;
};

type Category = {
  cat_name: string;
  recipes: Recipe[];
  active: BooleanLike;
};

type Recipe = {
  index: number;
  icon: string;
  selected: BooleanLike;
  name: string;
};

const PlumbingTypeSection = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { categories = [], selected_category } = data;
  const [categoryName, setCategoryName] = useLocalState(
    context,
    'categoryName',
    selected_category
  );
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];
  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category) => (
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
        <Button
          key={recipe.index}
          fluid
          ellipsis
          color="transparent"
          selected={recipe.selected}
          onClick={() =>
            act('recipe', {
              id: recipe.index,
            })
          }>
          <Stack>
            <Stack.Item>
              <Box
                className={classes(['plumbing-tgui32x32', recipe.icon])}
                style={{
                  transform: 'scale(1.5) translate(9%, 9.5%)',
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <span style={{ width: '7px' }} />
            </Stack.Item>
            <Stack.Item>
              <Section verticalAlign="middle">
                {capitalizeAll(recipe.name)}
              </Section>
            </Stack.Item>
          </Stack>
        </Button>
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

const LayerIconSection = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { layer_icon } = data;
  return (
    <Section
      backgroundColor="green"
      style={{
        width: '50px',
        height: '50px',
      }}>
      <Box
        className={classes(['plumbing-tgui32x32', layer_icon])}
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
                    <LayerIconSection />
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
