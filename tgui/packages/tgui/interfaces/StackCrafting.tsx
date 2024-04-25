import { clamp } from 'common/math';
import { createSearch } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Input,
  NoticeBox,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';

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
type RecipeListFilterableEntry = [string, RecipeList | Recipe];

/**
 * Type guard for recipe vs recipe list
 * @param value the value to test
 * @returns type guard boolean
 */
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
  keyFilter: (key: string) => boolean,
): RecipeList | undefined => {
  const filteredList = Object.fromEntries(
    Object.entries(list)
      .flatMap((entry): RecipeListFilterableEntry[] => {
        const [key, recipe] = entry;

        // If category name matches, return the whole thing.
        if (keyFilter(key)) {
          return [entry];
        }

        if (isRecipeList(recipe)) {
          // otherwise, filter sub-entries.
          const subEntries = filterRecipeList(recipe, keyFilter);
          if (subEntries !== undefined) {
            return [[key, subEntries]];
          }
        }

        return [];
      })
      .sort(([a], [b]) => (a < b ? -1 : a !== b ? 1 : 0)),
  );

  return Object.keys(filteredList).length ? filteredList : undefined;
};

export const StackCrafting = (_props) => {
  const { data } = useBackend<StackCraftingProps>();
  const { amount, recipes = {} } = data;

  const [searchText, setSearchText] = useState('');
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
          }
        >
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
      {Object.keys(recipes).map((title, index) => {
        const recipe = recipes[title];
        if (isRecipeList(recipe)) {
          return (
            <Collapsible key={title} ml={1} color="label" title={title}>
              <Box ml={2}>
                <RecipeListBox recipes={recipe} />
              </Box>
            </Collapsible>
          );
        } else {
          return <RecipeBox key={title} title={title} recipe={recipe} />;
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

const Multipliers = (props: MultiplierProps) => {
  const { act } = useBackend();

  const { recipe, maxMultiplier } = props;

  const maxM = Math.min(
    maxMultiplier,
    Math.floor(recipe.max_res_amount / recipe.res_amount),
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
        />,
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
      />,
    );
  }

  return <>{finalResult.map((x) => x)}</>;
};

const RecipeBox = (props: RecipeBoxProps) => {
  const { act, data } = useBackend<StackCraftingProps>();

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
