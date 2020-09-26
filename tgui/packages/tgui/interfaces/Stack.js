import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { sortBy } from 'common/collections';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Input, NoticeBox, Section, Collapsible, Table } from "../components";
import { Window } from "../layouts";

export const Stack = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    amount,
    recipes = [],
  } = data;

  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  const testSearch = createSearch(searchText, item => {
    return item;
  });

  const items = searchText.length > 0
   && Object.keys(recipes)
     .filter(testSearch)
     .reduce((obj, key) => {
       obj[key] = recipes[key];
       return obj;
     }, {})
    || recipes;

  const height = Math.max(94 + Object.keys(recipes).length * 26, 250);

  return (
    <Window
      width={400}
      height={Math.min(height, 500)}
      resizable>
      <Window.Content scrollable>
        <Section
          title={"Amount: " + amount}
          buttons={(
            <Fragment>
              Search
              <Input
                autoFocus
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
                mx={1} />
            </Fragment>
          )}>
          {items.length === 0 && (
            <NoticeBox>
              No recipes found.
            </NoticeBox>
          ) || (
            <RecipeList recipes={items} />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const RecipeList = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    recipes,
  } = props;

  const sortedKeys = sortBy(key => key.toLowerCase())(Object.keys(recipes));

  return sortedKeys.map(title => {
    const recipe = recipes[title];
    if (recipe.ref === undefined) {
      return (
        <Collapsible
          ml={1}
          color="label"
          title={title}>
          <Box ml={1}>
            <RecipeList recipes={recipe} />
          </Box>
        </Collapsible>
      );
    } else {
      return (
        <Recipe
          title={title}
          recipe={recipe} />
      );
    }
  });
};

const buildMultiplier = (recipe, amount) => {
  if (recipe.req_amount > amount) {
    return 0;
  }

  return Math.floor(amount / recipe.req_amount);
};

const Multipliers = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    recipe,
    maxMultiplier,
  } = props;

  const maxM = Math.min(maxMultiplier,
    Math.floor(recipe.max_res_amount / recipe.res_amount));

  const multipliers = [5, 10, 25];

  let finalResult = [];

  for (const multiplier of multipliers) {
    if (maxM >= multiplier) {
      finalResult.push((
        <Button
          content={multiplier * recipe.res_amount + "x"}
          onClick={() => act("make", {
            ref: recipe.ref,
            multiplier: multiplier,
          })} />
      ));
    }
  }

  if (multipliers.indexOf(maxM) === -1) {
    finalResult.push((
      <Button
        content={maxM * recipe.res_amount + "x"}
        onClick={() => act("make", {
          ref: recipe.ref,
          multiplier: maxM,
        })} />
    ));
  }

  return finalResult;
};

const Recipe = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    amount,
  } = data;

  const {
    recipe,
    title,
  } = props;

  const {
    res_amount,
    max_res_amount,
    req_amount,
    ref,
  } = recipe;

  let buttonName = title;
  buttonName += " (";
  buttonName += req_amount + " ";
  buttonName += ("sheet" + (req_amount > 1 ? "s" : ""));
  buttonName += ")";

  if (res_amount > 1) {
    buttonName = res_amount + "x " + buttonName;
  }

  const maxMultiplier = buildMultiplier(recipe, amount);

  return (
    <Box mb={1}>
      <Table>
        <Table.Row>
          <Table.Cell>
            <Button
              fluid
              disabled={!maxMultiplier}
              icon="wrench"
              content={buttonName}
              onClick={() => act("make", {
                ref: recipe.ref,
                multiplier: 1,
              })} />
          </Table.Cell>
          {max_res_amount > 1 && maxMultiplier > 1 && (
            <Table.Cell collapsing>
              <Multipliers
                recipe={recipe}
                maxMultiplier={maxMultiplier} />
            </Table.Cell>
          )}
        </Table.Row>
      </Table>
    </Box>
  );
};
