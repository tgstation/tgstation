import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useEffect, useState } from 'react';
import { logger } from 'tgui/logging';
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
import { fetchRetry } from 'tgui-core/http';
import { createSearch } from 'tgui-core/string';
import { resolveAsset } from 'tgui-panel/events/handlers/assets';
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
  type RecipeServerData,
  TABS,
} from './types';

export function PersonalCrafting(props: any) {
  const { act, data } = useBackend<CraftingData>();
  const {
    mode,
    forced_mode,
    display_compact,
    display_craftable_only,
    craftability,
    diet,
    json_to_use,
    material_occurences,
    visible_recipes,
  } = data;

  const [searchText, setSearchText] = useState('');
  const [pages, setPages] = useState(1);

  const [recipeData, setRecipeData] = useState<RecipeServerData>({
    categories: ['Loading...'],
    recipes: [],
    icon_data: {},
    atom_data: [],
  });

  useEffect(() => {
    fetchRetry(resolveAsset(json_to_use))
      .then((response) => response.json())
      .then(setRecipeData)
      .catch((error) => {
        logger.log(`Failed to fetch ${json_to_use}`, JSON.stringify(error));
      });
  }, [json_to_use]);

  const DEFAULT_CAT_CRAFTING = Object.keys(CATEGORY_ICONS_CRAFTING)[1];
  const DEFAULT_CAT_COOKING = Object.keys(CATEGORY_ICONS_COOKING)[1];

  const [activeCategory, setCategory] = useState(
    Object.keys(craftability).length
      ? 'Can Make'
      : mode === MODE.cooking
        ? DEFAULT_CAT_COOKING
        : DEFAULT_CAT_CRAFTING,
  );

  // filters recipes we can't see (due to lacking knowledge or whatever)
  const visibleRecipes = recipeData.recipes.filter((recipe) =>
    visible_recipes.includes(recipe.ref),
  );

  // filters out empty categories
  const visibleCategories = recipeData.categories.filter((category) =>
    visibleRecipes.some((recipe) => recipe.category === category),
  );

  const allFoodCuisines = visibleRecipes
    .reduce((acc: string[], recipe) => {
      if (recipe.cuisine_category && !acc.includes(recipe.cuisine_category)) {
        acc.push(recipe.cuisine_category);
      }
      return acc;
    }, [])
    .sort((a, b) => (a > b ? 1 : -1));

  const allDishCategories = visibleRecipes
    .reduce((acc: string[], recipe) => {
      if (recipe.dish_category && !acc.includes(recipe.dish_category)) {
        acc.push(recipe.dish_category);
      }
      return acc;
    }, [])
    .sort((a, b) => (a > b ? 1 : -1));

  const allMealCategories = visibleRecipes
    .reduce((acc: string[], recipe) => {
      if (recipe.meal_category && !acc.includes(recipe.meal_category)) {
        acc.push(recipe.meal_category);
      }
      return acc;
    }, [])
    .sort((a, b) => (a > b ? 1 : -1));

  const allFoodtypes = visibleRecipes
    .reduce((acc: string[], recipe) => {
      recipe.foodtypes?.forEach((foodtype) => {
        if (!acc.includes(foodtype)) {
          acc.push(foodtype);
        }
      });
      return acc;
    }, [])
    .sort((a, b) => (a > b ? 1 : -1));

  const [activeFoodCuisine, setFoodCuisine] = useState<string[]>();
  const [activeDishCategory, setDishCategory] = useState<string[]>();
  const [activeMealCategory, setMealCategory] = useState<string[]>();
  const [activeFoodType, setFoodType] = useState<string[]>();

  const sorted_material_occurences = sortBy(material_occurences, [
    (material) => -material.occurences,
  ]);
  const [activeMaterial, setMaterial] = useState(
    sorted_material_occurences[0].atom_id,
  );
  const [tabMode, setTabMode] = useState(TABS.category);

  const searchName = createSearch(searchText, (item: Recipe) => item.name);

  const getMaterialName = (atomId: string): string => {
    const idNum = Number(atomId);
    const atom = recipeData.atom_data[idNum - 1];
    return atom?.name || atomId;
  };

  const searchMaterial = createSearch(searchText, (material: Material) => {
    return getMaterialName(material.atom_id);
  });

  const filteredMaterials =
    searchText.length > 0 && tabMode === TABS.material
      ? filter(sorted_material_occurences, searchMaterial)
      : sorted_material_occurences;

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
        // only shows recipes with all the selected food types,
        // rather than any recipe with any selected food type
        if (
          activeFoodType?.length &&
          recipe.foodtypes?.filter((ft) => activeFoodType.includes(ft))
            .length !== activeFoodType.length
        ) {
          return false;
        }
      }
      return recipe.category === activeCategory;
    }
    return true;
  }

  let recipes = filter(
    visibleRecipes,
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
    .concat(visibleCategories.sort())
    .filter((i) => (i === 'Weaponry' ? true : i));

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
                      visibleRecipes.length +
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
                            : visibleCategories[0],
                        );
                      }}
                    >
                      Category
                    </Tabs.Tab>
                    <Tabs.Tab
                      selected={tabMode === TABS.material}
                      onClick={() => {
                        if (tabMode === TABS.material) {
                          return;
                        }
                        setTabMode(TABS.material);
                        setPages(1);
                        setMaterial(sorted_material_occurences[0].atom_id);
                      }}
                    >
                      {mode === MODE.cooking ? 'Ingredient' : 'Material'}
                    </Tabs.Tab>
                  </Tabs>
                </Stack.Item>
                <Stack.Item grow m={-1} style={{ overflowY: 'auto' }}>
                  <Box height={'100%'} p={1}>
                    <Tabs vertical>
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
                              iconData={recipeData.icon_data}
                              atomData={recipeData.atom_data}
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
                                              setFoodCuisine(
                                                toggleArrayItem(
                                                  activeFoodCuisine,
                                                  cuisine,
                                                ),
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
                                              setDishCategory(
                                                toggleArrayItem(
                                                  activeDishCategory,
                                                  dish,
                                                ),
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
                                              setMealCategory(
                                                toggleArrayItem(
                                                  activeMealCategory,
                                                  meal,
                                                ),
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

                                      <Stack.Item>
                                        <SubGroupTitle title="Type" />
                                      </Stack.Item>
                                      {allFoodtypes.map((foodType) => (
                                        <Stack.Item key={foodType}>
                                          <Button.Checkbox
                                            fluid
                                            checked={activeFoodType?.includes(
                                              foodType,
                                            )}
                                            onClick={() => {
                                              setFoodType(
                                                toggleArrayItem(
                                                  activeFoodType,
                                                  foodType,
                                                ),
                                              );
                                              setPages(1);
                                            }}
                                          >
                                            <Box inline>
                                              <FoodtypeContent
                                                type={foodType}
                                                diet={diet}
                                                craftableCount={
                                                  Object.keys(craftability)
                                                    .length
                                                }
                                              />
                                            </Box>
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
                          iconData={recipeData.icon_data}
                          atomData={recipeData.atom_data}
                        />
                      ) : (
                        <RecipeContent
                          key={item.ref}
                          item={item}
                          allRecipes={recipes}
                          iconData={recipeData.icon_data}
                          atomData={recipeData.atom_data}
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
