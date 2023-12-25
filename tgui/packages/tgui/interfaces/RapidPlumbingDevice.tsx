import { BooleanLike, classes } from 'common/react';
import { capitalizeAll } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { MatterItem, SiloItem } from './RapidConstructionDevice';
import { ColorItem, LayerSelect } from './RapidPipeDispenser';

type Data = {
  silo_upgraded: BooleanLike;
  layer_icon: string;
  categories: Category[];
  selected_category: string;
  selected_recipe: string;
};

type Category = {
  cat_name: string;
  recipes: Recipe[];
  active: BooleanLike;
};

type Recipe = {
  icon: string;
  selected: BooleanLike;
  name: string;
};

const PlumbingTypeSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [], selected_category, selected_recipe } = data;
  const [categoryName, setCategoryName] = useState(selected_category);
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];

  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            key={category.cat_name}
            selected={category.cat_name === shownCategory.cat_name}
            onClick={() => setCategoryName(category.cat_name)}
          >
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.recipes.map((recipe, index) => (
        <Button
          key={index}
          fluid
          color="transparent"
          selected={recipe.name === selected_recipe}
          onClick={() =>
            act('recipe', {
              category: shownCategory.cat_name,
              id: index,
            })
          }
        >
          <Box
            inline
            verticalAlign="middle"
            mr="20px"
            mb="10px"
            className={classes(['plumbing-tgui32x32', recipe.icon])}
            style={{
              transform: 'scale(1.3) translate(9.5%, 11.2%)',
            }}
          />
          <span>{capitalizeAll(recipe.name)}</span>
        </Button>
      ))}
    </Section>
  );
};

const LayerIconSection = (props) => {
  const { data } = useBackend<Data>();
  const { layer_icon } = data;
  return (
    <Box
      m={1}
      className={classes(['plumbing-tgui32x32', layer_icon])}
      style={{
        transform: 'scale(2)',
      }}
    />
  );
};

export const RapidPlumbingDevice = (props) => {
  const { data } = useBackend<Data>();
  const { silo_upgraded } = data;
  return (
    <Window width={480} height={575}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item>
                  <ColorItem />
                  <LayerSelect />
                  <MatterItem />
                  {!!silo_upgraded && <SiloItem />}
                </Stack.Item>
                <Stack.Item>
                  <LayerIconSection />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <PlumbingTypeSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
