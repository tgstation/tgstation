import { BooleanLike, classes } from 'common/react';
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { map, filter, sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Divider, Button, Section, Tabs, Stack, Box, Input, NoticeBox, Icon, Tooltip } from '../components';
import { Window } from '../layouts';
import { Food } from './PreferencesMenu/data';

const TYPE_ICONS = {
  'Can Make': 'utensils',
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
} as const;

const CATEGORY_ICONS = {
  'Can Make': 'utensils',
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
} as const;

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
  non_craftable: BooleanLike;
  is_reaction: BooleanLike;
  steps: string[];
  tool_paths: Ingredient[];
  catalysts: Ingredient[];
  machinery: Ingredient[];
};

type Diet = {
  liked_food: string[];
  disliked_food: string[];
  toxic_food: string[];
};

type Data = {
  // Dynamic
  busy: BooleanLike;
  display_compact: BooleanLike;
  display_craftable_only: BooleanLike;
  craftability: Record<string, BooleanLike>;
  // Static
  recipes: Recipe[];
  categories: string[];
  foodtypes: string[];
  diet: Diet;
};

export const PersonalCooking = (props, context) => {
  const {
    act,
    data: {
      busy,
      display_compact,
      display_craftable_only,
      craftability,
      recipes,
      categories,
      foodtypes,
      diet,
    },
  } = useBackend<Data>(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [activeCategory, setCategory] = useLocalState(
    context,
    'category',
    Object.keys(craftability).length ? 'Can Make' : categories[0]
  );
  const [activeType, setType] = useLocalState(
    context,
    'foodtype',
    Object.keys(craftability).length ? 'Can Make' : foodtypes[0]
  );
  const [typeMode, setTypeMode] = useLocalState(context, 'typeMode', false);
  const searchName = createSearch(searchText, (item: Recipe) => item.name);
  const craftabilityByRef = craftability;
  let recipes_filtered = flow([
    filter<Recipe>(
      (recipe) =>
        // If craftable only is selected, then filter by craftability
        (!display_craftable_only || Boolean(craftabilityByRef[recipe.ref])) &&
        // Ignore categories and types when searching
        (searchText.length > 0 ||
          // Is type mode and the active type matches
          (typeMode &&
            ((activeType === 'Can Make' &&
              Boolean(craftabilityByRef[recipe.ref])) ||
              recipe.foodtypes?.includes(activeType))) ||
          // Is category mode and the active categroy matches
          (!typeMode &&
            ((activeCategory === 'Can Make' &&
              Boolean(craftabilityByRef[recipe.ref])) ||
              recipe.category === activeCategory)))
    ),
    sortBy<Recipe>((recipe) => [
      -Number(craftabilityByRef[recipe.ref]),
      recipe.name,
    ]),
  ])(recipes);
  if (searchText.length > 0) {
    recipes_filtered = recipes_filtered.filter(searchName);
  }
  const canMake = ['Can Make'];
  const categories_combined = canMake.concat(categories.sort());
  const foodtypes_combined = canMake.concat(foodtypes.sort());
  const displayLimit = display_compact ? 299 : 99;
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
              <Divider />
              <Tabs mt={1} fluid textAlign="center">
                <Tabs.Tab
                  selected={!typeMode}
                  onClick={() => {
                    setTypeMode(false);
                    setCategory(
                      Object.keys(craftability).length
                        ? 'Can Make'
                        : categories[0]
                    );
                  }}>
                  Category
                </Tabs.Tab>
                <Tabs.Tab
                  selected={typeMode}
                  onClick={() => {
                    setTypeMode(true);
                    setType(
                      Object.keys(craftability).length
                        ? 'Can Make'
                        : foodtypes[0]
                    );
                  }}>
                  Type
                </Tabs.Tab>
              </Tabs>
              <Tabs vertical>
                {typeMode
                  ? foodtypes_combined.map((foodtype) => (
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
                      <TypeContent
                        type={foodtype}
                        diet={diet}
                        craftableCount={Object.keys(craftability).length}
                      />
                    </Tabs.Tab>
                  ))
                  : categories_combined.map((category) => (
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
                        {category === 'Can Make' && (
                          <Stack.Item>
                            {Object.keys(craftability).length}
                          </Stack.Item>
                        )}
                      </Stack>
                    </Tabs.Tab>
                  ))}
              </Tabs>
              <Divider />
              <Button.Checkbox
                fluid
                content="Can make only"
                checked={display_craftable_only}
                onClick={() => {
                  act('toggle_recipes');
                }}
              />
              <Button.Checkbox
                fluid
                content="Compact list"
                checked={display_compact}
                onClick={() => act('toggle_compact')}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {recipes_filtered.length > 0 ? (
              recipes_filtered
                .slice(0, displayLimit)
                .map((item) =>
                  display_compact ? (
                    <RecipeContentCompact
                      key={item.ref}
                      item={item}
                      craftable={Boolean(craftabilityByRef[item.ref])}
                      busy={busy}
                    />
                  ) : (
                    <RecipeContent
                      key={item.ref}
                      item={item}
                      diet={diet}
                      craftable={Boolean(craftabilityByRef[item.ref])}
                      busy={busy}
                    />
                  )
                )
            ) : (
              <NoticeBox m={1} p={1}>
                No recipes found.
              </NoticeBox>
            )}
            {recipes_filtered.length > displayLimit && (
              <Section textAlign="right">
                And {recipes_filtered.length - displayLimit} more...
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TypeContent = (props) => {
  const { type, diet, craftableCount } = props;
  return (
    <Stack>
      <Stack.Item width="14px" textAlign="center">
        <Icon name={TYPE_ICONS[type]} />
      </Stack.Item>
      <Stack.Item grow style={{ 'text-transform': 'capitalize' }}>
        {type.toLowerCase()}
      </Stack.Item>
      <Stack.Item>
        {type === 'Can Make' ? (
          craftableCount
        ) : diet.liked_food.includes(type) ? (
          <Icon name="face-laugh-beam" color={'good'} />
        ) : diet.disliked_food.includes(type) ? (
          <Icon name="face-tired" color={'average'} />
        ) : (
          diet.toxic_food.includes(type) && (
            <Icon name="skull-crossbones" color={'bad'} />
          )
        )}
      </Stack.Item>
    </Stack>
  );
};

const RecipeContentCompact = ({ item, craftable, busy }, context) => {
  const { act } = useBackend<Data>(context);
  return (
    <Section my={0.5}>
      <Stack my={-0.75}>
        <Stack.Item>
          <Box
            className={classes([
              'cooking32x32',
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
              <Box style={{ 'text-transform': 'capitalize' }} color={'gray'}>
                {Array.from(
                  item.reqs.map((ingredient) =>
                    ingredient.is_reagent
                      ? ingredient.name + '\xa0' + ingredient.amount + 'u'
                      : ingredient.amount > 1
                        ? ingredient.name + '\xa0' + ingredient.amount + 'x'
                        : ingredient.name
                  )
                ).join(', ')}
                {item.catalysts &&
                  ' | ' +
                    item.catalysts
                      .map((ingredient) =>
                        ingredient.is_reagent
                          ? ingredient.name + '\xa0' + ingredient.amount + 'u'
                          : ingredient.amount > 1
                            ? ingredient.name + '\xa0' + ingredient.amount + 'x'
                            : ingredient.name
                      )
                      .join(', ')}
                {item.tool_paths &&
                  ' | ' + item.tool_paths.map((item) => item.name).join(', ')}
                {item.machinery &&
                  ' | ' + item.machinery.map((item) => item.name).join(', ')}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {!item.non_craftable ? (
                <Button
                  my={0.3}
                  lineHeight={2.5}
                  align="center"
                  content="Make"
                  disabled={!craftable || busy}
                  icon={busy ? 'circle-notch' : 'utensils'}
                  iconSpin={busy ? 1 : 0}
                  onClick={() =>
                    act('make', {
                      recipe: item.ref,
                    })
                  }
                />
              ) : (
                item.steps && (
                  <Tooltip
                    content={item.steps.map((step) => (
                      <Box key={step}>{step}</Box>
                    ))}>
                    <Box fontSize={1.5} p={1}>
                      <Icon name="circle-question-o" />
                    </Box>
                  </Tooltip>
                )
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const RecipeContent = ({ item, diet, craftable, busy }, context) => {
  const { act } = useBackend<Data>(context);
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
                'cooking32x32',
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
              {item.desc && <Box color={'gray'}>{item.desc}</Box>}
              <Box style={{ 'text-transform': 'capitalize' }}>
                {item.reqs && (
                  <Box>
                    <Stack my={1}>
                      <Stack.Item grow>
                        <Divider />
                      </Stack.Item>
                      <Stack.Item color={'gray'}>Ingredients</Stack.Item>
                      <Stack.Item grow>
                        <Divider />
                      </Stack.Item>
                    </Stack>
                    {flow([
                      sortBy((item: Ingredient) => item.path),
                      map((item: Ingredient) => (
                        <AtomContent key={item.path} item={item} />
                      )),
                    ])(item.reqs)}
                  </Box>
                )}
                {item.catalysts && (
                  <Box>
                    <Stack my={1}>
                      <Stack.Item grow>
                        <Divider />
                      </Stack.Item>
                      <Stack.Item color={'gray'}>Catalysts</Stack.Item>
                      <Stack.Item grow>
                        <Divider />
                      </Stack.Item>
                    </Stack>
                    {flow([
                      sortBy((item: Ingredient) => item.path),
                      map((item: Ingredient) => (
                        <AtomContent key={item.path} item={item} />
                      )),
                    ])(item.catalysts)}
                  </Box>
                )}
                {item.tool_paths && (
                  <Box>
                    <Stack my={1}>
                      <Stack.Item grow>
                        <Divider />
                      </Stack.Item>
                      <Stack.Item color={'gray'}>Tools</Stack.Item>
                      <Stack.Item grow>
                        <Divider />
                      </Stack.Item>
                    </Stack>
                    {item.tool_paths.map((item) => (
                      <AtomContent key={item.path} item={item} />
                    ))}
                  </Box>
                )}
                {item.machinery && (
                  <Box>
                    <Stack my={1}>
                      <Stack.Item grow>
                        <Divider />
                      </Stack.Item>
                      <Stack.Item color={'gray'}>Machinery</Stack.Item>
                      <Stack.Item grow>
                        <Divider />
                      </Stack.Item>
                    </Stack>
                    {item.machinery.map((item) => (
                      <AtomContent key={item.path} item={item} />
                    ))}
                  </Box>
                )}
              </Box>
              {!!item.steps?.length && (
                <Box>
                  <Stack my={1}>
                    <Stack.Item grow>
                      <Divider />
                    </Stack.Item>
                    <Stack.Item color={'gray'}>Steps</Stack.Item>
                    <Stack.Item grow>
                      <Divider />
                    </Stack.Item>
                  </Stack>
                  <ul style={{ 'padding-left': '20px' }}>
                    {item.steps.map((step) => (
                      <li key={step}>{step}</li>
                    ))}
                  </ul>
                </Box>
              )}
            </Stack.Item>
            <Stack.Item pl={1}>
              {!item.non_craftable && (
                <Button
                  width="104px"
                  lineHeight={2.5}
                  align="center"
                  content="Make"
                  disabled={!craftable || busy}
                  icon={busy ? 'circle-notch' : 'utensils'}
                  iconSpin={busy ? 1 : 0}
                  onClick={() =>
                    act('make', {
                      recipe: item.ref,
                    })
                  }
                />
              )}
              {item.foodtypes?.length > 0 && (
                <Box color={'gray'} width={'104px'} lineHeight={1.5} mt={1}>
                  {item.foodtypes.map((foodtype) => (
                    <TypeContent key={item.ref} type={foodtype} diet={diet} />
                  ))}
                </Box>
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AtomContent = ({ item: { name, amount, path, is_reagent } }) => {
  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={classes(['cooking32x32', path.replace(/[/_]/gi, '')])}
      />
      <Box inline verticalAlign="middle">
        {name}
        {is_reagent
          ? '\xa0' + amount + 'u'
          : amount > 1 && '\xa0' + amount + 'x'}
      </Box>
    </Box>
  ) as any;
};
