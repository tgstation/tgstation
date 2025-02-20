import { useState } from 'react';
import {
  Button,
  Collapsible,
  ImageButton,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
import { createSearch, toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { SearchBar } from './common/SearchBar';

type Recipe = {
  ref: unknown | null;
  req_amount: number;
  icon: string;
  icon_state: string;
  image?: string;

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

      // Sort items so that lists are on top and recipes underneath.
      // Plus everything is in alphabetical order.
      .sort(([aKey, aValue], [bKey, bValue]) =>
        isRecipeList(aValue) !== isRecipeList(bValue)
          ? isRecipeList(aValue)
            ? -1
            : 1
          : aKey.localeCompare(bKey),
      ),
  );

  return Object.keys(filteredList).length ? filteredList : undefined;
};

export const StackCrafting = (_props) => {
  const { data } = useBackend<StackCraftingProps>();
  const { amount, recipes = {} } = data;

  const [searchText, setSearchText] = useState('');
  const testSearch = createSearch(searchText, (item: string) => item);
  const filteredRecipes = filterRecipeList(recipes, testSearch);

  const height: number = clamp(96 + Object.keys(recipes).length * 37, 250, 500);

  return (
    <Window width={400} height={height}>
      <Window.Content>
        <Section
          fill
          scrollable
          title={'Amount: ' + amount}
          buttons={
            <SearchBar
              style={{ width: '15em' }}
              query={searchText}
              onSearch={(value) => setSearchText(value)}
            />
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
            <Collapsible
              key={title}
              title={toTitleCase(title || '')}
              child_mt={0}
              childStyles={{
                padding: '0.5em',
                backgroundColor: 'rgba(62, 97, 137, 0.15)',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                borderTop: 'none',
                borderRadius: '0 0 0.33em 0.33em',
              }}
            >
              <RecipeListBox recipes={recipe} />
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
          bold
          color={'transparent'}
          fontSize={0.75}
          width={'32px'}
          onClick={() =>
            act('make', {
              ref: recipe.ref,
              multiplier: multiplier,
            })
          }
        >
          {multiplier * recipe.res_amount + 'x'}
        </Button>,
      );
    }
  }

  if (multipliers.indexOf(maxM) === -1) {
    finalResult.push(
      <Button
        bold
        color={'transparent'}
        fontSize={0.75}
        width={'32px'}
        onClick={() =>
          act('make', {
            ref: recipe.ref,
            multiplier: maxM,
          })
        }
      >
        {maxM * recipe.res_amount + 'x'}
      </Button>,
    );
  }

  return <>{finalResult.map((x) => x)}</>;
};

const RecipeBox = (props: RecipeBoxProps) => {
  const { act, data } = useBackend<StackCraftingProps>();
  const { amount } = data;
  const { recipe, title } = props;
  const {
    res_amount,
    max_res_amount,
    req_amount,
    ref,
    icon,
    icon_state,
    image,
  } = recipe;

  const resAmountLabel = res_amount > 1 ? `${res_amount}x ` : '';
  const sheetSuffix = req_amount > 1 ? 's' : '';
  const buttonName = `${resAmountLabel}${title}`;
  const reqSheets = `${req_amount} sheet${sheetSuffix}`;

  const maxMultiplier = buildMultiplier(recipe, amount);

  return (
    <ImageButton
      fluid
      base64={
        image
      } /* Use base64 image if we have it. DmIcon cannot paint grayscale images yet */
      dmIcon={icon}
      dmIconState={icon_state}
      imageSize={32}
      disabled={!maxMultiplier}
      buttons={
        max_res_amount > 1 &&
        maxMultiplier > 1 && (
          <Multipliers recipe={recipe} maxMultiplier={maxMultiplier} />
        )
      }
      onClick={() =>
        act('make', {
          ref: ref,
          multiplier: 1,
        })
      }
    >
      <Stack textAlign={'left'}>
        <Stack.Item grow>{toTitleCase(buttonName)}</Stack.Item>
        <Stack.Item align={'center'} fontSize={0.8} color={'gray'}>
          {reqSheets}
        </Stack.Item>
      </Stack>
    </ImageButton>
  );
};
