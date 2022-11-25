import { BooleanLike, classes } from 'common/react';
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Tabs, Stack, Box, Input, NoticeBox, Icon } from '../components';
import { Window } from '../layouts';
import { Food } from './PreferencesMenu/data';

const FOOD_ICONS = {
  [Food.Alcohol]: 'wine-glass',
  [Food.Breakfast]: 'sun',
  [Food.Bugs]: 'bug',
  [Food.Cloth]: 'tshirt',
  [Food.Dairy]: 'cheese',
  [Food.Fried]: 'fire',
  [Food.Fruit]: 'apple-alt',
  [Food.Gore]: 'skull',
  [Food.Grain]: 'wheat-awn',
  [Food.Gross]: 'trash',
  [Food.Junkfood]: 'pizza-slice',
  [Food.Meat]: 'bacon',
  [Food.Nuts]: 'seedling',
  [Food.Oranges]: 'apple-alt',
  [Food.Pineapple]: 'apple-alt',
  [Food.Raw]: 'drumstick-bite',
  [Food.Seafood]: 'fish',
  [Food.Sugar]: 'candy-cane',
  [Food.Toxic]: 'biohazard',
  [Food.Vegetables]: 'carrot',
};

const CATEGORY_ICONS = {
  'Breads': 'bread-slice',
  'Burgers': 'burger',
  'Cakes': 'cake-candles',
  'Egg-Based Food': 'egg',
  'Frozen': 'ice-cream',
  'Lizard Food': 'dragon',
  'Meats': 'bacon',
  'Mexican Food': 'pepper-hot',
  'Misc. Food': 'bowl-food',
  'Mothic Food': 'shirt',
  'Pastries': 'cookie',
  'Pies': 'chart-pie',
  'Pizzas': 'pizza-slice',
  'Salads': 'leaf',
  'Sandwiches': 'hotdog',
  'Seafood': 'fish',
  'Soups': 'mug-saucer',
  'Spaghettis': 'wheat-awn',
};

type Ingredient = {
  path: string;
  name: string;
  amount: number;
  is_reagent: BooleanLike;
};

type Recipe = {
  ref: string;
  result: string;
  name: string;
  desc: string;
  reqs: Ingredient[];
  category: string;
  foodtypes: string[];
};

type Diet = {
  liked_food: string[];
  disliked_food: string[];
  toxic_food: string[];
};

type Data = {
  // Dynamic
  busy: BooleanLike;
  compact: BooleanLike;
  craftable_only: BooleanLike;
  // Static
  recipes: Recipe[];
  categories: string[];
  foodtypes: string[];
  diet: Diet;
};

export const PersonalCooking = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortField, setSortField] = useLocalState(context, 'sortField', 'name');
  const [activeCategory, setCategory] = useLocalState(
    context,
    'category',
    data.categories[0]
  );
  const [activeType, setType] = useLocalState(
    context,
    'foodtype',
    data.foodtypes[0]
  );
  const [typeMode, setTypeMode] = useLocalState(context, 'typeMode', false);
  const searchName = createSearch(searchText, (item: Recipe) => item.name);
  const searchCategory = createSearch(
    activeCategory,
    (item: Recipe) => item.category
  );
  const searchType = createSearch(
    activeType,
    (item: Recipe) => item.foodtypes?.join() // Some foods don't have types
  );
  const recipes_filtered =
    searchText.length > 0
      ? data.recipes.filter(searchName)
      : typeMode
        ? data.recipes.filter(searchType)
        : data.recipes.filter(searchCategory);
  const recipes = flow([
    sortBy((item: Recipe) => item[sortField as keyof Recipe]),
  ])(recipes_filtered || []);
  const categories = data.categories.sort();
  const foodtypes = data.foodtypes.sort();
  const displayLimit = searchText.length > 0 ? 30 : 299;
  return (
    <Window width={700} height={700}>
      <Window.Content id="content" scrollable>
        <Stack>
          <Stack.Item width={'140px'}>
            <Section width={'140px'} style={{ 'position': 'fixed' }}>
              <Input
                autoFocus
                placeholder={'Search...'}
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
                fluid
              />
              <hr style={{ 'border-color': '#111' }} />
              <Tabs mt={1} fluid textAlign="center">
                <Tabs.Tab
                  selected={!typeMode}
                  onClick={(e) => setTypeMode(false)}>
                  Category
                </Tabs.Tab>
                <Tabs.Tab
                  selected={typeMode}
                  onClick={(e) => setTypeMode(true)}>
                  Type
                </Tabs.Tab>
              </Tabs>
              <Tabs vertical>
                {typeMode
                  ? foodtypes.map((foodtype) => (
                    <Tabs.Tab
                      key={foodtype}
                      selected={
                        activeType === foodtype && searchText.length === 0
                      }
                      onClick={(e) => {
                        setType(foodtype);
                        document.getElementById('content').scrollTop = 0;
                        if (searchText.length > 0) {
                          setSearchText('');
                        }
                      }}>
                      <TypeContent type={foodtype} diet={data.diet} />
                    </Tabs.Tab>
                  ))
                  : categories.map((category) => (
                    <Tabs.Tab
                      key={category}
                      selected={
                        activeCategory === category && searchText.length === 0
                      }
                      onClick={(e) => {
                        setCategory(category);
                        document.getElementById('content').scrollTop = 0;
                        if (searchText.length > 0) {
                          setSearchText('');
                        }
                      }}>
                      <Stack>
                        <Stack.Item width="14px" textAlign="center">
                          <Icon name={CATEGORY_ICONS[category]} />
                        </Stack.Item>
                        <Stack.Item grow>{category}</Stack.Item>
                      </Stack>
                    </Tabs.Tab>
                  ))}
              </Tabs>
              <hr style={{ 'border-color': '#111' }} />
              <Button.Checkbox
                fluid
                content="Craftable only"
                checked={data.craftable_only}
                onClick={() => act('toggle_craftable_only')}
              />
              <Button.Checkbox
                fluid
                content="Compact list"
                checked={data.compact}
                onClick={() => act('toggle_compact')}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {recipes.length > 0 ? (
              recipes
                .slice(0, displayLimit)
                .map((item) =>
                  data.compact ? (
                    <RecipeContentCompact key item={item} />
                  ) : (
                    <RecipeContent key item={item} diet={data.diet} />
                  )
                )
            ) : (
              <NoticeBox m={1} p={1}>
                No recipes found.
              </NoticeBox>
            )}
            {recipes.length > displayLimit && (
              <Section textAlign="right">
                And {recipes.length - displayLimit} more...
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TypeContent = (props) => {
  return (
    <Stack>
      <Stack.Item width="14px" textAlign="center">
        <Icon name={FOOD_ICONS[props.type]} />
      </Stack.Item>
      <Stack.Item grow style={{ 'text-transform': 'capitalize' }}>
        {props.type.toLowerCase()}
      </Stack.Item>
      <Stack.Item>
        {props.diet.liked_food.includes(props.type) ? (
          <Icon name="face-laugh-beam" color={'good'} />
        ) : props.diet.disliked_food.includes(props.type) ? (
          <Icon name="face-tired" color={'average'} />
        ) : (
          props.diet.toxic_food.includes(props.type) && (
            <Icon name="skull-crossbones" color={'bad'} />
          )
        )}
      </Stack.Item>
    </Stack>
  );
};

const RecipeContentCompact = (props, context) => {
  const { act } = useBackend<Data>(context);
  const item = props.item;
  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Box
            className={classes([
              'food32x32',
              item.result?.replace(/[/_]/gi, ''),
            ])}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box bold mb={0.5} style={{ 'text-transform': 'capitalize' }}>
                {item.name}
              </Box>
              <Box style={{ 'text-transform': 'capitalize' }}>
                {Array.from(
                  item.reqs.map((i) =>
                    i.is_reagent
                      ? i.name + '\xa0' + i.amount + 'u'
                      : i.amount > 1
                        ? i.name + '\xa0' + i.amount + 'x'
                        : i.name
                  )
                ).join(', ')}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                lineHeight={2.5}
                align="center"
                content="Make"
                disabled
                icon="utensils"
                onClick={() =>
                  act('make', {
                    recipe: item.ref,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RecipeContent = (props, context) => {
  const { act } = useBackend<Data>(context);
  const item = props.item;
  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Box width={'64px'} height={'64px'} mr={1}>
            <Box
              width={'32px'}
              height={'32px'}
              style={{
                'transform': 'scale(2)',
              }}
              m={'16px'}
              className={classes([
                'food32x32',
                item.result?.replace(/[/_]/gi, ''),
              ])}
            />
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box bold mb={0.5} style={{ 'text-transform': 'capitalize' }}>
                {item.name}
              </Box>
              <Box color={'gray'}>{item.desc}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                width="104px"
                lineHeight={2.5}
                align="center"
                content="Make"
                disabled
                icon="utensils"
                onClick={() =>
                  act('make', {
                    recipe: item.ref,
                  })
                }
              />
            </Stack.Item>
          </Stack>
          <hr style={{ 'border-color': '#111' }} />
          <Stack>
            <Stack.Item grow style={{ 'text-transform': 'capitalize' }}>
              {item.reqs &&
                item.reqs
                  .sort((a, b) => (a.path > b.path ? 1 : -1))
                  .map((item) => <IngredientContent key item={item} />)}
            </Stack.Item>
            <Stack.Item color={'gray'} width={'104px'} lineHeight={1.5}>
              {item.foodtypes?.length > 0 &&
                item.foodtypes.map((foodtype) => (
                  <TypeContent key type={foodtype} diet={props.diet} />
                ))}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const IngredientContent = (props) => {
  const i = props.item;
  return (
    i.path.includes('/obj/item/food/') ? (
      <Box my={1}>
        <Box
          verticalAlign="middle"
          inline
          my={-1}
          className={classes(['food32x32', i.path.replace(/[/_]/gi, '')])}
        />
        <Box inline verticalAlign="middle">
          {i.name}
          {i.amount > 1 && '\xa0' + i.amount + 'x'}
        </Box>
      </Box>
    ) : (
      <Box my={1} verticalAlign="middle">
        <Icon
          name={
            i.is_reagent
              ? 'droplet'
              : i.path.includes('/obj/item/reagent_containers/')
                ? 'whiskey-glass'
                : 'box'
          }
          width={'32px'}
          textAlign="center"
        />
        <Box inline>
          {i.is_reagent
            ? i.name + '\xa0' + i.amount + 'u'
            : i.amount > 1
              ? i.name + '\xa0' + i.amount + 'x'
              : i.name}
        </Box>
      </Box>
    )
  ) as any;
};
