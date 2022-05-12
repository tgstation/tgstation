import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { BooleanLike, classes } from 'common/react';
import { useBackend } from '../backend';
import { Button, Dimmer, Icon, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

type RawRecipe = {
  name: string;
  ref: string;
  req_text: string;
  catalyst_text: string;
  tool_text: string;
};

type RawData = {
  // Dynamic data
  busy: BooleanLike | null;
  category: string;
  subcategory: string;
  display_craftable_only: BooleanLike;
  display_compact: BooleanLike;
  craftability: Record<string, BooleanLike>;
  // Static data
  crafting_recipes: Record<
    string,
    // That's the weirdest piece of type I had to write in my life.
    // Yes, that's how subcategories are sent here.
    RawRecipe[] | (Record<string, RawRecipe[]> & { has_subcats: 1 })
  >;
};

type Recipe = RawRecipe & {
  craftable: boolean;
  dm_category: string;
  dm_subcategory?: string;
};

type Category = {
  name: string;
  dm_category: string;
  dm_subcategory?: string;
};

type Group = {
  name: string;
  categories: Category[];
};

type Data = RawData & {
  dm_category: string;
  dm_subcategory: string;
  recipes: Recipe[];
  groups: Group[];
};

const GENERAL_GROUP = 'General';

const remapData = (rawData: RawData): Data => {
  const craftability_by_ref = rawData.craftability;
  const dm_categories = rawData.crafting_recipes || {};

  const recipes: Recipe[] = [];
  const generalGroup: Group = {
    name: GENERAL_GROUP,
    categories: [],
  };
  const groups: Group[] = [generalGroup];

  for (const dm_category of Object.keys(dm_categories)) {
    const dm_categories_item = dm_categories[dm_category];

    // This is a nested part of the tree containing subcategories
    if ('has_subcats' in dm_categories_item) {
      // Create a new group for these categories
      const group: Group = {
        name: dm_category,
        categories: [],
      };
      groups.push(group);
      for (const dm_subcategory of Object.keys(dm_categories_item)) {
        // Skip even more nested subcats, they shouldn't exist
        if (dm_subcategory === 'has_subcats') {
          continue;
        }
        // Push category
        group.categories.push({
          name: dm_subcategory,
          dm_category,
          dm_subcategory,
        });
        // Push recipes
        const dm_recipes = dm_categories_item[dm_subcategory];
        for (const dm_recipe of dm_recipes) {
          recipes.push({
            ...dm_recipe,
            dm_category,
            dm_subcategory,
            craftable: Boolean(craftability_by_ref[dm_recipe.ref]),
          });
        }
      }
      continue;
    }

    // This is a flat part of the tree where simple categories are located.
    // We group these categories under the "General" group.
    if (Array.isArray(dm_categories_item)) {
      // Push category
      generalGroup.categories.push({
        name: dm_category,
        dm_category,
      });
      // Push recipes
      for (const dm_recipe of dm_categories_item) {
        recipes.push({
          ...dm_recipe,
          dm_category,
          craftable: Boolean(craftability_by_ref[dm_recipe.ref]),
        });
      }
      continue;
    }

    throw new Error(`Invalid entry in 'crafting_recipes', neither '{ has_subcats: 1 }' nor 'Recipe[]'`);
  }

  return {
    ...rawData,
    dm_category: rawData.category,
    dm_subcategory: rawData.subcategory,
    recipes,
    groups,
  };
};

const isCategorySelected = (data: Data, item: Category | Recipe) => (
  data.dm_category === item.dm_category
  && (!data.dm_subcategory || data.dm_subcategory === item.dm_subcategory)
);

export const PersonalCrafting = (props, context) => {
  const { act, data: rawData } = useBackend<RawData>(context);
  const data = remapData(rawData);

  const {
    busy,
    display_craftable_only,
    display_compact,
    recipes,
    groups,
  } = data;

  const shownRecipes = flow([
    filter<Recipe>((recipe) => (
      // Show selected category only
      isCategorySelected(data, recipe)
      // If craftable only is selected, then filter by craftability
      && (!display_craftable_only || recipe.craftable)
    )),
    sortBy<Recipe>((recipe) => [
      -recipe.craftable,
      recipe.name,
    ]),
  ])(recipes);

  return (
    <Window title="Crafting Menu" width={700} height={700}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="150px">
            <Section fill scrollable title="Category">
              {groups.map((group) => (
                <Section key={group.name} title={group.name}>
                  {group.categories.map((category) => (
                    <Button
                      key={category.name}
                      fluid
                      color="transparent"
                      selected={isCategorySelected(data, category)}
                      onClick={() => act('set_category', {
                        category: category.dm_category,
                        subcategory: category.dm_subcategory,
                      })}>
                      {category.name}
                    </Button>
                  ))}
                </Section>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow={3}>
            <Section
              fill
              title="Recipes"
              buttons={
                <>
                  <Button.Checkbox
                    content="Compact"
                    checked={display_compact}
                    onClick={() => act('toggle_compact')}
                  />
                  <Button.Checkbox
                    content="Craftable Only"
                    checked={display_craftable_only}
                    onClick={() => act('toggle_recipes')}
                  />
                </>
              }>
              <Section fill scrollable>
                {busy ? (
                  <Dimmer fontSize="32px">
                    <Icon name="cog" spin={1} />
                    {' Crafting...'}
                  </Dimmer>
                ) : (
                  <CraftingList
                    recipes={shownRecipes}
                    compact={Boolean(display_compact)} />
                )}
              </Section>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type CraftingListProps = {
  recipes: Recipe[];
  // eslint-disable-next-line react/no-unused-prop-types
  compact?: boolean;
};

const CraftingList = (props: CraftingListProps, context) => {
  const { recipes = [], compact } = props;
  const { act } = useBackend<RawData>(context);

  if (compact) {
    return <CompactCraftingList recipes={recipes} />;
  }

  return recipes.map((recipe) => (
    <div
      key={recipe.ref}
      className={classes([
        'PersonalCraftingGridItem',
        recipe.craftable && 'PersonalCraftingGridItem--craftable',
      ])}
      onClick={() => {
        if (recipe.craftable) {
          act('make', {
            recipe: recipe.ref,
          });
        }
      }}>
      <div className="PersonalCraftingGridItem__content">
        <div className="PersonalCraftingGridItem__name">
          {recipe.name}
        </div>
        {!!recipe.req_text && (
          recipe.req_text.split(', ').map((req, i) => (
            <div key={req + i} className="PersonalCraftingGridItem__prereq">
              {req}
            </div>
          ))
        )}
        {!!recipe.catalyst_text && (
          <div className="PersonalCraftingGridItem__extra">
            <b>Catalyst:</b> {recipe.catalyst_text}
          </div>
        )}
        {!!recipe.tool_text && (
          <div className="PersonalCraftingGridItem__extra">
            <b>Tools:</b> {recipe.tool_text}
          </div>
        )}
        <div className="PersonalCraftingGridItem__craftability">
          {recipe.craftable ? 'Craft' : 'Uncraftable'}
        </div>
      </div>
    </div>
  )) as any;
};

const CompactCraftingList = (props: CraftingListProps, context) => {
  const { recipes = [] } = props;
  const { act } = useBackend<RawData>(context);

  return (
    <table>
      {recipes.map((recipe) => (
        <tr key={recipe.ref} className="candystripe">
          <Table.Cell bold maxWidth="250px">
            {recipe.name}
          </Table.Cell>
          <Table.Cell opacity={0.6}>
            {recipe.req_text}
          </Table.Cell>
          <Table.Cell collapsing>
            <Button
              icon="cog"
              content="Craft"
              disabled={!recipe.craftable}
              tooltip={
                recipe.tool_text && 'Tools needed: ' + recipe.tool_text
              }
              tooltipPosition="left"
              onClick={() => act('make', {
                recipe: recipe.ref,
              })} />
          </Table.Cell>
        </tr>
      ))}
    </table>
  );
};
