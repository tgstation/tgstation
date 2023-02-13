import { createSearch } from 'common/string';
import { filter, map, reduce, sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, NoticeBox, Section, Collapsible, Table } from '../components';
import { Window } from '../layouts';
import { clamp } from 'common/math';
import { flow } from 'common/fp';

type Recipe = {
  ref: unknown | null;
  req_amount: number;

  // for multiplier buttons
  res_amount: number;
  max_res_amount: number;
};

type RecipeList = {
  [key: string]: Recipe | RecipeList;
};

type StackCraftingProps = {
  amount: number;
  recipes: RecipeList;
};

type RecipeListProps = {
  recipes: RecipeList;
};

type MultiplierProps = {
  recipe: Recipe;
  maxMultiplier: number;
};

type RecipeBoxProps = {
  title: string;
  recipe: Recipe;
};

// RecipeList converted via Object.entries() for filterRecipeList
type RecipeListEntry = [string, RecipeList | Recipe];
type RecipeListFilterableEntry = [string, RecipeList | Recipe | undefined];

/**
 * Type guard for recipe vs recipe list
 * @param value the value to test
 * @returns type guard boolean
 */
// eslint-disable-next-line func-style
function isRecipeList(value: Recipe | RecipeList): value is RecipeList {
  return (value as Recipe).ref === undefined;
}

/**
 * Filter recipe list by keys, resursing into subcategories.
 * Returns the filtered list, or undefined, if there is no list left.
 * @param list the recipe list to filter
 * @param filter the filter function for recipes
 */
const filterRecipeList = (
  list: RecipeList,
  keyFilter: (key: string) => boolean
) => {
  const filteredList: RecipeList = flow([
    map((entry: RecipeListEntry): RecipeListFilterableEntry => {
      const [key, recipe] = entry;

      if (isRecipeList(recipe)) {
        // If category name matches, return the whole thing.
        if (keyFilter(key)) {
          return entry;
        }

        // otherwise, filter sub-entries.
        return [key, filterRecipeList(recipe, keyFilter)];
      }

      return keyFilter(key) ? entry : [key, undefined];
    }),
    filter((entry: RecipeListFilterableEntry) => entry[1] !== undefined),
    sortBy((entry: RecipeListEntry) => entry[0].toLowerCase()),
    reduce((obj: RecipeList, entry: RecipeListEntry) => {
      obj[entry[0]] = entry[1];
      return obj;
    }, {}),
  ])(Object.entries(list));

  return Object.keys(filteredList).length ? filteredList : undefined;
};

export const StackCrafting = (_props, context) => {
  const { data } = useBackend<StackCraftingProps>(context);
  const { amount, recipes = {} } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const testSearch = createSearch(searchText, (item: string) => item);
  const filteredRecipes = filterRecipeList(recipes, testSearch);

  const height: number = clamp(94 + Object.keys(recipes).length * 26, 250, 500);

  return (
    <Window width={400} height={height}>
      <Window.Content scrollable>
        <Section
          title={'Amount: ' + amount}
          buttons={
            <>
              Search
              <Input
                autoFocus
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
                mx={1}
              />
            </>
          }>
          {filteredRecipes ? (
            <RecipeListBox recipes={filteredRecipes} />
          ) : (
            <NoticeBox>No recipes found.</NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const RecipeListBox = (props: RecipeListProps) => {
  const { recipes } = props;

  return (
    <>
      {Object.keys(recipes).map((title) => {
        const recipe = recipes[title];
        if (isRecipeList(recipe)) {
          return (
            <Collapsible ml={1} color="label" title={title}>
              <Box ml={2}>
                <RecipeListBox recipes={recipe} />
              </Box>
            </Collapsible>
          );
        } else {
          return <RecipeBox title={title} recipe={recipe} />;
        }
      })}
    </>
  );
};

const buildMultiplier = (recipe: Recipe, amount: number) => {
  if (recipe.req_amount > amount) {
    return 0;
  }

  return Math.floor(amount / recipe.req_amount);
};

const Multipliers = (props: MultiplierProps, context) => {
  const { act } = useBackend(context);

  const { recipe, maxMultiplier } = props;

  const maxM = Math.min(
    maxMultiplier,
    Math.floor(recipe.max_res_amount / recipe.res_amount)
  );

  const multipliers = [5, 10, 25];

  const finalResult: JSX.Element[] = [];

  for (const multiplier of multipliers) {
    if (maxM >= multiplier) {
      finalResult.push(
        <Button
          content={multiplier * recipe.res_amount + 'x'}
          onClick={() =>
            act('make', {
              ref: recipe.ref,
              multiplier: multiplier,
            })
          }
        />
      );
    }
  }

  if (multipliers.indexOf(maxM) === -1) {
    finalResult.push(
      <Button
        content={maxM * recipe.res_amount + 'x'}
        onClick={() =>
          act('make', {
            ref: recipe.ref,
            multiplier: maxM,
          })
        }
      />
    );
  }

  return <>{finalResult.map((x) => x)}</>;
};

const RecipeBox = (props: RecipeBoxProps, context) => {
  const { act, data } = useBackend<StackCraftingProps>(context);

  const { amount } = data;

  const { recipe, title } = props;

  const { res_amount, max_res_amount, req_amount, ref } = recipe;

  const resAmountLabel = res_amount > 1 ? `${res_amount}x ` : '';
  const sheetSuffix = req_amount > 1 ? 's' : '';
  const buttonName = `${resAmountLabel}${title} (${req_amount} sheet${sheetSuffix})`;

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
              onClick={() =>
                act('make', {
                  ref: ref,
                  multiplier: 1,
                })
              }
            />
          </Table.Cell>
          {max_res_amount > 1 && maxMultiplier > 1 && (
            <Table.Cell collapsing>
              <Multipliers recipe={recipe} maxMultiplier={maxMultiplier} />
            </Table.Cell>
          )}
        </Table.Row>
      </Table>
    </Box>
  );
};
