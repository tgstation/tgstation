import { BooleanLike, classes } from 'common/react';
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Box, Input, Section, Table, NoticeBox } from '../components';
import { Window } from '../layouts';

type Recipe = {
  key: string;
  name: string;
  icon: string;
};

type Data = {
  // Dynamic
  busy: BooleanLike;
  // Static
  recipes: Recipe[];
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
  return (
    <Window width={1080} height={400}>
      <Window.Content scrollable>
        <Section>
          <Input
            autoFocus
            placeholder={'Search...'}
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
            fluid
          />
        </Section>
        {recipes.length > 0 &&
          recipes.map((item) => (
            <Section key={item.name}>
              <Box className={classes(['food32x32', item.icon])} />
              {item.name}
            </Section>
          ))}
        {recipes.length === 0 && (
          <NoticeBox m={1} p={1}>
            No recipes found.
          </NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
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
