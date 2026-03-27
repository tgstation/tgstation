import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  VirtualList,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { CATEGORY_ICONS_COOKING, CATEGORY_ICONS_CRAFTING } from './constants';
import { FoodtypeContent } from './content/FoodtypeContent';
import { MaterialContent } from './content/MaterialContent';
import { RecipeContent, RecipeContentCompact } from './content/RecipeContent';
import { SubGroupTitle } from './GroupTitle';
import { getFAIcon, toggleArrayItem } from './helpers';
import {
  type CraftingData,
  type Material,
  MODE,
  type Recipe,
  TABS,
} from './types';

export function PersonalCrafting(props: any) {
  const { act, data } = useBackend<CraftingData>();
  const {
    mode,
    busy,
    forced_mode,
    display_compact,
    display_craftable_only,
    craftability,
    diet,
    atom_data,
  } = data;

  const [searchText, setSearchText] = useState('');
  const [pages, setPages] = useState(1);

  const DEFAULT_CAT_CRAFTING = Object.keys(CATEGORY_ICONS_CRAFTING)[1];
  const DEFAULT_CAT_COOKING = Object.keys(CATEGORY_ICONS_COOKING)[1];

  const [activeCategory, setCategory] = useState(
    Object.keys(craftability).length
      ? 'Can Make'
      : mode === MODE.cooking
        ? DEFAULT_CAT_COOKING
        : DEFAULT_CAT_CRAFTING,
  );

  const allFoodCuisines = data.recipes
    .reduce((acc: string[], recipe) => {
      if (recipe.cuisine_category && !acc.includes(recipe.cuisine_category)) {
        acc.push(recipe.cuisine_category);
      }
      return acc;
    }, [])
    .sort((a, b) => (a > b ? 1 : -1));

  const allDishCategories = data.recipes
    .reduce((acc: string[], recipe) => {
      if (recipe.dish_category && !acc.includes(recipe.dish_category)) {
        acc.push(recipe.dish_category);
      }
      return acc;
    }, [])
    .sort((a, b) => (a > b ? 1 : -1));

  const allMealCategories = data.recipes
    .reduce((acc: string[], recipe) => {
      if (recipe.meal_category && !acc.includes(recipe.meal_category)) {
        acc.push(recipe.meal_category);
      }
      return acc;
    }, [])
    .sort((a, b) => (a > b ? 1 : -1));

  const [activeFoodCuisine, setFoodCuisine] = useState<string[]>();
  const [activeDishCategory, setDishCategory] = useState<string[]>();
  const [activeMealCategory, setMealCategory] = useState<string[]>();

  const [activeType, setFoodType] = useState(
    Object.keys(craftability).length ? 'Can Make' : data.foodtypes[0],
  );
  const material_occurences = sortBy(data.material_occurences, [
    (material) => -material.occurences,
  ]);
  const [activeMaterial, setMaterial] = useState(
    material_occurences[0].atom_id,
  );
  const [tabMode, setTabMode] = useState(TABS.category);

  const searchName = createSearch(searchText, (item: Recipe) => item.name);

  const getMaterialName = (atomId: string): string => {
    const idNum = Number(atomId);
    const atom = atom_data[idNum - 1];
    return atom?.name || atomId;
  };

  const searchMaterial = createSearch(searchText, (material: Material) => {
    return getMaterialName(material.atom_id);
  });

  const filteredMaterials =
    searchText.length > 0 && tabMode === TABS.material
      ? filter(material_occurences, searchMaterial)
      : material_occurences;

  function categoryMatch(recipe: Recipe): boolean {
    if (tabMode === TABS.material) {
      return Object.keys(recipe.reqs).includes(activeMaterial);
    } else if (tabMode === TABS.category) {
      if (activeCategory === 'Can Make') {
        return Boolean(craftability[recipe.ref]);
      }
      if (activeCategory === 'Foods') {
        if (
          activeFoodCuisine?.length &&
          !activeFoodCuisine.includes(recipe.cuisine_category || '')
        ) {
          return false;
        }
        if (
          activeDishCategory?.length &&
          !activeDishCategory.includes(recipe.dish_category || '')
        ) {
          return false;
        }
        if (
          activeMealCategory?.length &&
          !activeMealCategory.includes(recipe.meal_category || '')
        ) {
          return false;
        }
      }
      return recipe.category === activeCategory;
    } else if (tabMode === TABS.foodtype && mode === MODE.cooking) {
      if (activeType === 'Can Make') {
        return Boolean(craftability[recipe.ref]);
      }
      if (recipe.foodtypes) {
        return recipe.foodtypes.includes(activeType);
      }
      return false;
    }
    return true;
  }

  let recipes = filter(
    data.recipes,
    (recipe) =>
      // If craftable only is selected, then filter by craftability
      (!display_craftable_only || Boolean(craftability[recipe.ref])) &&
      // Ignore categories and types when searching
      (searchText.length > 0 || categoryMatch(recipe)),
  );
  recipes = sortBy(recipes, [
    (recipe) => [
      activeCategory === 'Can Make'
        ? 99 - Object.keys(recipe.reqs).length
        : Number(craftability[recipe.ref]),
      recipe.name.toLowerCase(),
    ],
  ]);
  if (searchText.length > 0) {
    recipes = filter(recipes, searchName);
  }

  const canMake = ['Can Make'];
  const categories = canMake
    .concat(data.categories.sort())
    .filter((i) => (i === 'Weaponry' ? true : i));
  const foodtypes = canMake.concat(data.foodtypes.sort());

  const pageSize =
    searchText.length > 0
      ? display_compact
        ? 20
        : 10
      : display_compact
        ? 60
        : 30;
  const displayLimit = pageSize * pages;
  const content = document.getElementById('content');

  return (
    <Window width={700} height={720}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="200px">
            <Section fill>
              <Stack fill vertical justify={'space-between'}>
                <Stack.Item>
                  <Input
                    autoFocus
                    expensive
                    placeholder={
                      'Search in ' +
                      data.recipes.length +
                      (mode === MODE.cooking ? ' recipes...' : ' designs...')
                    }
                    value={searchText}
                    onChange={(value) => {
                      setPages(1);
                      setSearchText(value);
                    }}
                    fluid
                  />
                </Stack.Item>
                <Stack.Item>
                  <Tabs fluid textAlign="center">
                    <Tabs.Tab
                      selected={tabMode === TABS.category}
                      onClick={() => {
                        if (tabMode === TABS.category) {
                          return;
                        }
                        setTabMode(TABS.category);
                        setPages(1);
                        setCategory(
                          Object.keys(craftability).length
                            ? 'Can Make'
                            : data.categories[0],
                        );
                      }}
                    >
                      Category
                    </Tabs.Tab>
                    {mode === MODE.cooking && (
                      <Tabs.Tab
                        selected={tabMode === TABS.foodtype}
                        onClick={() => {
                          if (tabMode === TABS.foodtype) {
                            return;
                          }
                          setTabMode(TABS.foodtype);
                          setPages(1);
                          setFoodType(
                            Object.keys(craftability).length
                              ? 'Can Make'
                              : data.foodtypes[0],
                          );
                        }}
                      >
                        Type
                      </Tabs.Tab>
                    )}
                    <Tabs.Tab
                      selected={tabMode === TABS.material}
                      onClick={() => {
                        if (tabMode === TABS.material) {
                          return;
                        }
                        setTabMode(TABS.material);
                        setPages(1);
                        setMaterial(material_occurences[0].atom_id);
                      }}
                    >
                      {mode === MODE.cooking ? 'Ingredient' : 'Material'}
                    </Tabs.Tab>
                  </Tabs>
                </Stack.Item>
                <Stack.Item grow m={-1} style={{ overflowY: 'auto' }}>
                  <Box height={'100%'} p={1}>
                    <Tabs vertical>
                      {tabMode === TABS.foodtype &&
                        mode === MODE.cooking &&
                        foodtypes.map((foodtype) => (
                          <Tabs.Tab
                            key={foodtype}
                            selected={
                              activeType === foodtype && searchText.length === 0
                            }
                            onClick={(e) => {
                              setFoodType(foodtype);
                              setPages(1);
                              if (content) {
                                content.scrollTop = 0;
                              }
                              if (searchText.length > 0) {
                                setSearchText('');
                              }
                            }}
                          >
                            <FoodtypeContent
                              type={foodtype}
                              diet={diet}
                              craftableCount={Object.keys(craftability).length}
                            />
                          </Tabs.Tab>
                        ))}
                      {tabMode === TABS.material &&
                        filteredMaterials.map((material) => (
                          <Tabs.Tab
                            key={material.atom_id}
                            selected={
                              activeMaterial === material.atom_id &&
                              searchText.length === 0
                            }
                            onClick={(e) => {
                              setMaterial(material.atom_id);
                              setPages(1);
                              if (content) {
                                content.scrollTop = 0;
                              }
                              if (searchText.length > 0) {
                                setSearchText('');
                              }
                            }}
                          >
                            <MaterialContent
                              atom_id={material.atom_id}
                              occurences={(material as Material).occurences}
                            />
                          </Tabs.Tab>
                        ))}
                      {tabMode === TABS.category &&
                        categories.map((category) => (
                          <Tabs.Tab
                            key={category}
                            selected={
                              activeCategory === category &&
                              searchText.length === 0
                            }
                            onClick={(e) => {
                              setCategory(category);
                              setPages(1);
                              if (content) {
                                content.scrollTop = 0;
                              }
                              if (searchText.length > 0) {
                                setSearchText('');
                              }
                            }}
                          >
                            <Stack vertical>
                              <Stack.Item>
                                <Stack
                                  // hack, for some reason the standard padding
                                  // disappears with the extra food category
                                  // rendering, so i'm manually doing it here
                                  pt={
                                    category === 'Foods' &&
                                    activeCategory === category
                                      ? 0.75
                                      : 0
                                  }
                                >
                                  <Stack.Item width="14px" textAlign="center">
                                    <Icon
                                      color={
                                        category === 'Blood Cult'
                                          ? 'red'
                                          : 'default'
                                      }
                                      name={getFAIcon(category, mode)}
                                    />
                                  </Stack.Item>
                                  <Stack.Item
                                    grow
                                    color={
                                      category === 'Blood Cult'
                                        ? 'red'
                                        : 'default'
                                    }
                                  >
                                    {category}
                                  </Stack.Item>
                                  {category === 'Can Make' && (
                                    <Stack.Item>
                                      {Object.keys(craftability).length}
                                    </Stack.Item>
                                  )}
                                </Stack>
                              </Stack.Item>
                              {/* Foods are further categorized by cuisine and dish type */}
                              {category === 'Foods' &&
                                activeCategory === category && (
                                  <Stack.Item fontSize="0.95em">
                                    <Stack vertical pb={1}>
                                      <Stack.Item>
                                        <SubGroupTitle title="Cuisines" />
                                      </Stack.Item>
                                      {allFoodCuisines.map((cuisine) => (
                                        <Stack.Item key={cuisine}>
                                          <Button.Checkbox
                                            fluid
                                            color="transparent"
                                            checked={activeFoodCuisine?.includes(
                                              cuisine,
                                            )}
                                            onClick={() => {
                                              toggleArrayItem(
                                                activeFoodCuisine,
                                                cuisine,
                                              );
                                              setPages(1);
                                            }}
                                          >
                                            <Icon
                                              name={getFAIcon(cuisine, mode)}
                                              mr={1}
                                              ml={0.5}
                                            />
                                            {cuisine}
                                          </Button.Checkbox>
                                        </Stack.Item>
                                      ))}
                                      <Stack.Item>
                                        <SubGroupTitle title="Dishes" />
                                      </Stack.Item>
                                      {allDishCategories.map((dish) => (
                                        <Stack.Item key={dish}>
                                          <Button.Checkbox
                                            fluid
                                            checked={activeDishCategory?.includes(
                                              dish,
                                            )}
                                            onClick={() => {
                                              toggleArrayItem(
                                                activeDishCategory,
                                                dish,
                                              );
                                              setPages(1);
                                            }}
                                          >
                                            <Icon
                                              name={getFAIcon(dish, mode)}
                                              mr={1}
                                              ml={0.5}
                                            />
                                            {dish}
                                          </Button.Checkbox>
                                        </Stack.Item>
                                      ))}
                                      <Stack.Item>
                                        <SubGroupTitle title="Meals" />
                                      </Stack.Item>
                                      {allMealCategories.map((meal) => (
                                        <Stack.Item key={meal}>
                                          <Button.Checkbox
                                            fluid
                                            checked={activeMealCategory?.includes(
                                              meal,
                                            )}
                                            onClick={() => {
                                              toggleArrayItem(
                                                activeMealCategory,
                                                meal,
                                              );
                                              setPages(1);
                                            }}
                                          >
                                            <Icon
                                              name={getFAIcon(meal, mode)}
                                              mr={1}
                                              ml={0.5}
                                            />
                                            {meal}
                                          </Button.Checkbox>
                                        </Stack.Item>
                                      ))}
                                    </Stack>
                                  </Stack.Item>
                                )}
                            </Stack>
                          </Tabs.Tab>
                        ))}
                    </Tabs>
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Divider />
                  <Button.Checkbox
                    fluid
                    checked={display_craftable_only}
                    onClick={() => {
                      act('toggle_recipes');
                    }}
                  >
                    Can make only
                  </Button.Checkbox>
                  <Button.Checkbox
                    fluid
                    checked={display_compact}
                    onClick={() => act('toggle_compact')}
                  >
                    Compact list
                  </Button.Checkbox>
                </Stack.Item>
                {!forced_mode && (
                  <Stack.Item>
                    <Stack textAlign="center">
                      <Stack.Item grow>
                        <Button.Checkbox
                          fluid
                          lineHeight={2}
                          checked={mode === MODE.crafting}
                          icon="hammer"
                          style={{
                            border:
                              '2px solid ' +
                              (mode === MODE.crafting ? '#20b142' : '#333'),
                          }}
                          onClick={() => {
                            if (mode === MODE.crafting) {
                              return;
                            }
                            setTabMode(TABS.category);
                            setCategory(DEFAULT_CAT_CRAFTING);
                            act('toggle_mode');
                          }}
                        >
                          Craft
                        </Button.Checkbox>
                      </Stack.Item>
                      <Stack.Item grow>
                        <Button.Checkbox
                          fluid
                          lineHeight={2}
                          checked={mode === MODE.cooking}
                          icon="utensils"
                          style={{
                            border:
                              '2px solid ' +
                              (mode === MODE.cooking ? '#20b142' : '#333'),
                          }}
                          onClick={() => {
                            if (mode === MODE.cooking) {
                              return;
                            }
                            setTabMode(TABS.category);
                            setCategory(DEFAULT_CAT_COOKING);
                            act('toggle_mode');
                          }}
                        >
                          Cook
                        </Button.Checkbox>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow my={-1}>
            <Box
              height="100%"
              pr={1}
              pt={1}
              mr={-1}
              style={{ overflowY: 'auto' }}
            >
              {recipes.length > 0 ? (
                <VirtualList>
                  {recipes
                    .slice(0, displayLimit)
                    .map((item) =>
                      display_compact ? (
                        <RecipeContentCompact
                          key={item.ref}
                          item={item}
                          craftable={
                            !item.non_craftable &&
                            Boolean(craftability[item.ref])
                          }
                          busy={busy}
                          mode={mode}
                        />
                      ) : (
                        <RecipeContent
                          key={item.ref}
                          item={item}
                          craftable={
                            !item.non_craftable &&
                            Boolean(craftability[item.ref])
                          }
                          busy={busy}
                          mode={mode}
                          diet={diet}
                        />
                      ),
                    )}
                </VirtualList>
              ) : (
                <NoticeBox m={1} p={1}>
                  No recipes found.
                </NoticeBox>
              )}
              {recipes.length > displayLimit && (
                <Section
                  mb={1}
                  textAlign="center"
                  style={{ cursor: 'pointer' }}
                  onClick={() => setPages(pages + 1)}
                >
                  Load {Math.min(pageSize, recipes.length - displayLimit)}{' '}
                  more...
                </Section>
              )}
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
