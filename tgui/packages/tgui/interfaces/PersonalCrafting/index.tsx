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
import { type CraftingData, MODE, type Recipe, TABS } from './types';

export function PersonalCrafting(props) {
  const { act, data } = useBackend<CraftingData>();
  const {
    mode,
    busy,
    forced_mode,
    display_compact,
    display_craftable_only,
    craftability,
    diet,
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

  let recipes = filter(
    data.recipes,
    (recipe) =>
      // If craftable only is selected, then filter by craftability
      (!display_craftable_only || Boolean(craftability[recipe.ref])) &&
      // Ignore categories and types when searching
      (searchText.length > 0 ||
        // Is foodtype mode and the active type matches
        (tabMode === TABS.foodtype &&
          mode === MODE.cooking &&
          ((activeType === 'Can Make' && Boolean(craftability[recipe.ref])) ||
            recipe.foodtypes?.includes(activeType))) ||
        // Is material mode and the active material or catalysts match
        (tabMode === TABS.material &&
          Object.keys(recipe.reqs).includes(activeMaterial)) ||
        // Is category mode and the active categroy matches
        (tabMode === TABS.category &&
          ((activeCategory === 'Can Make' &&
            Boolean(craftability[recipe.ref])) ||
            recipe.category === activeCategory))),
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
  const CATEGORY_ICONS =
    mode === MODE.cooking ? CATEGORY_ICONS_COOKING : CATEGORY_ICONS_CRAFTING;

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
                        material_occurences.map((material) => (
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
                              occurences={material.occurences}
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
                            <Stack>
                              <Stack.Item width="14px" textAlign="center">
                                <Icon
                                  color={
                                    category === 'Blood Cult'
                                      ? 'red'
                                      : 'default'
                                  }
                                  name={CATEGORY_ICONS[category] || 'circle'}
                                />
                              </Stack.Item>
                              <Stack.Item
                                grow
                                color={
                                  category === 'Blood Cult' ? 'red' : 'default'
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
