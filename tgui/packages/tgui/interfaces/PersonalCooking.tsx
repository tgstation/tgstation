import { BooleanLike, classes } from 'common/react';
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Tabs, Stack, Box, Input, NoticeBox, Icon } from '../components';
import { Window } from '../layouts';

const TOOL_ICONS = {
  wirecutter: 'scissors',
  screwdriver: 'screwdriver',
  welder: 'fire-flame-curved',
  wrench: 'wrench',
  crowbar: 'screwdriver',
  multitool: 'mobile-retro',
  knife: 'utensils',
  bible: 'book-bible',
  'follower hoodie': 'shirt',
  'egyptian staff': 'ankh',
  'bike horn': 'bullhorn',
};

type Category = {
  id: string;
  name: string;
};

type Recipe = {
  result: string;
  name: string;
  desc: string;
  reqs: number[];
  category: Category;
};

type Data = {
  // Dynamic
  busy: BooleanLike;
  // Static
  recipes: Recipe[];
  categories: string[];
};

export const PersonalCooking = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortField, setSortField] = useLocalState(context, 'sortField', 'name');
  const [action, toggleAction] = useLocalState(context, 'action', true);
  const search = createSearch(searchText, (item: Recipe) => item.name);
  const recipes_filtered =
    searchText.length > 0 ? data.recipes.filter(search) : data.recipes;
  const recipes = flow([
    sortBy((item: Recipe) => item[sortField as keyof Recipe]),
  ])(recipes_filtered || []);
  const categories = data.categories.sort();
  return (
    <Window width={700} height={700}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item width={'120px'}>
            <Section width={'120px'} style={{ 'position': 'fixed' }}>
              <Input
                autoFocus
                placeholder={'Search...'}
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
                fluid
              />
              <Tabs vertical mt={1}>
                <Tabs.Tab key={null} selected>
                  All
                </Tabs.Tab>
                {categories.map((category) => (
                  <Tabs.Tab key={category}>{category}</Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {recipes.length > 0 ? (
              recipes
                .slice(0, 30)
                .map((item) => <RecipeContent key item={item} />)
            ) : (
              <NoticeBox m={1} p={1}>
                No recipes found.
              </NoticeBox>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RecipeContent = (props) => {
  let item = props.item;
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
              <Box bold mb={0.5}>
                {item.name}
              </Box>
              <Box color={'gray'}>{item.desc}</Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                ml={3}
                width={6}
                lineHeight={2.5}
                align="center"
                content="Make"
                disabled
                icon="utensils"
              />
            </Stack.Item>
          </Stack>

          <hr style={{ 'border-color': '#111' }} />
          <Box>
            {item.reqs &&
              item.reqs
                .sort((a, b) => (a.path > b.path ? 1 : -1))
                .map((item) => <Ingredient key item={item} />)}
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Ingredient = (props) => {
  return (
    props.item.path.includes('/obj/item/food/') ? (
      <Box my={1}>
        <Box
          verticalAlign="middle"
          inline
          my={-1}
          className={classes([
            'food32x32',
            props.item.path.replace(/[/_]/gi, ''),
          ])}
        />
        <Box
          inline
          verticalAlign="middle"
          style={{ 'text-transform': 'capitalize' }}>
          {props.item.name}&nbsp;
          {props.item.amount > 1 && props.item.amount + 'x'}
        </Box>
      </Box>
    ) : (
      <Box my={1} verticalAlign="middle">
        <Icon
          name={
            props.item.path.includes('/datum/reagent/')
              ? 'droplet'
              : props.item.path.includes('/obj/item/reagent_containers/')
                ? 'whiskey-glass'
                : 'box'
          }
          width={'32px'}
          textAlign="center"
        />
        <Box inline style={{ 'text-transform': 'capitalize' }}>
          {props.item.name}&nbsp;
          {props.item.path.includes('/datum/reagent/')
            ? props.item.amount + 'u'
            : props.item.amount > 1 && props.item.amount + 'x'}
        </Box>
      </Box>
    )
  ) as any;
};
