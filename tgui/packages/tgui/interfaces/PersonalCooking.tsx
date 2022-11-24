import { BooleanLike, classes } from 'common/react';
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Section, Tabs, Stack, Box, Input, Table, NoticeBox, Tooltip, Icon } from '../components';
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
    <Window width={600} height={600}>
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
              recipes.map((item) => <RecipeContent key item={item} />)
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
          <Box
            style={{ 'background-color': '#111' }}
            className={classes([
              'food32x32',
              item.result?.replace(/[/_]/gi, ''),
            ])}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Box bold mb={0.5}>
            {item.name}
          </Box>
          <Box color={'gray'}>{item.desc}</Box>
          <hr style={{ 'border-color': '#111' }} />
          <Box>
            {item.reqs &&
              item.reqs.map((item) => <Ingredient key item={item} />)}
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Ingredient = (props) => {
  return (
    <Tooltip content={props.item.name}>
      {props.item.path.includes('/obj/item/food/') ? (
        <Box mx={1} inline>
          <Box
            verticalAlign="middle"
            inline
            className={classes([
              'food32x32',
              props.item.path.replace(/[/_]/gi, ''),
            ])}
          />
          <Box inline>{props.item.amount > 1 && 'x' + props.item.amount}</Box>
        </Box>
      ) : props.item.path.includes('/datum/reagent/') ? (
        <Box mx={1} inline verticalAlign="middle">
          <Icon name="droplet" />
          <Box inline>
            &nbsp;{props.item.amount > 1 && props.item.amount + 'u'}
          </Box>
        </Box>
      ) : props.item.path.includes('/obj/item/reagent_containers/') ? (
        <Box mx={1} inline verticalAlign="middle">
          <Icon name="prescription-bottle" />
          <Box inline>
            &nbsp;{props.item.amount > 1 && 'x' + props.item.amount}
          </Box>
        </Box>
      ) : (
        <Box mx={1} inline verticalAlign="middle">
          {props.item.name}&nbsp;
          {props.item.amount > 1 && 'x' + props.item.amount}
        </Box>
      )}
    </Tooltip>
  ) as any;
};

const ReagentTooltip = (props) => {
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>Reagents</Table.Cell>
      </Table.Row>
      {props.reagents?.map((reagent) => (
        <Table.Row key="">
          <Table.Cell>{reagent.name}</Table.Cell>
          <Table.Cell py={0.5} pl={2} textAlign={'right'}>
            {Math.max(
              Math.round(reagent.rate * props.potency * props.volume_mod),
              1
            )}
            u
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
