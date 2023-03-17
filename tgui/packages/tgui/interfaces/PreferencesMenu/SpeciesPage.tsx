import { classes } from 'common/react';
import { useBackend } from '../../backend';
import { BlockQuote, Box, Button, Divider, Icon, Section, Stack, Tooltip } from '../../components';
import { CharacterPreview } from '../common/CharacterPreview';
import { createSetPreference, Food, Perk, PreferencesMenuData, ServerData, Species } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const FOOD_ICONS = {
  [Food.Bugs]: 'bug',
  [Food.Cloth]: 'tshirt',
  [Food.Dairy]: 'cheese',
  [Food.Fried]: 'bacon',
  [Food.Fruit]: 'apple-alt',
  [Food.Gore]: 'skull',
  [Food.Grain]: 'bread-slice',
  [Food.Gross]: 'trash',
  [Food.Junkfood]: 'pizza-slice',
  [Food.Meat]: 'hamburger',
  [Food.Nuts]: 'seedling',
  [Food.Raw]: 'drumstick-bite',
  [Food.Seafood]: 'fish',
  [Food.Sugar]: 'candy-cane',
  [Food.Toxic]: 'biohazard',
  [Food.Vegetables]: 'carrot',
};

const FOOD_NAMES: Record<keyof typeof FOOD_ICONS, string> = {
  [Food.Bugs]: 'Bugs',
  [Food.Cloth]: 'Clothing',
  [Food.Dairy]: 'Dairy',
  [Food.Fried]: 'Fried food',
  [Food.Fruit]: 'Fruit',
  [Food.Gore]: 'Gore',
  [Food.Grain]: 'Grain',
  [Food.Gross]: 'Gross food',
  [Food.Junkfood]: 'Junk food',
  [Food.Meat]: 'Meat',
  [Food.Nuts]: 'Nuts',
  [Food.Raw]: 'Raw',
  [Food.Seafood]: 'Seafood',
  [Food.Sugar]: 'Sugar',
  [Food.Toxic]: 'Toxic food',
  [Food.Vegetables]: 'Vegetables',
};

const IGNORE_UNLESS_LIKED: Set<Food> = new Set([
  Food.Bugs,
  Food.Cloth,
  Food.Gross,
  Food.Toxic,
]);

const notIn = function <T>(set: Set<T>) {
  return (value: T) => {
    return !set.has(value);
  };
};

const FoodList = (props: {
  food: Food[];
  icon: string;
  name: string;
  className: string;
}) => {
  if (props.food.length === 0) {
    return null;
  }

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Icon name={props.icon} /> <b>{props.name}</b>
          <Divider />
          <Box>
            {props.food
              .reduce((names, food) => {
                const foodName = FOOD_NAMES[food];
                return foodName ? names.concat(foodName) : names;
              }, [])
              .join(', ')}
          </Box>
        </Box>
      }>
      <Stack ml={2}>
        {props.food.map((food) => {
          return (
            FOOD_ICONS[food] && (
              <Stack.Item>
                <Icon
                  className={props.className}
                  size={1.4}
                  key={food}
                  name={FOOD_ICONS[food]}
                />
              </Stack.Item>
            )
          );
        })}
      </Stack>
    </Tooltip>
  );
};

const Diet = (props: { diet: Species['diet'] }) => {
  if (!props.diet) {
    return null;
  }

  const { liked_food, disliked_food, toxic_food } = props.diet;

  return (
    <Stack>
      <Stack.Item>
        <FoodList
          food={liked_food}
          icon="heart"
          name="Liked food"
          className="color-pink"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={disliked_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="thumbs-down"
          name="Disliked food"
          className="color-red"
        />
      </Stack.Item>

      <Stack.Item>
        <FoodList
          food={toxic_food.filter(notIn(IGNORE_UNLESS_LIKED))}
          icon="biohazard"
          name="Toxic food"
          className="color-olive"
        />
      </Stack.Item>
    </Stack>
  );
};

const SpeciesPerk = (props: { className: string; perk: Perk }) => {
  const { className, perk } = props;

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Box as="b">{perk.name}</Box>
          <Divider />
          <Box>{perk.description}</Box>
        </Box>
      }>
      <Box class={className} width="32px" height="32px">
        <Icon
          name={perk.ui_icon}
          size={1.5}
          ml={0}
          mt={1}
          style={{
            'text-align': 'center',
            height: '100%',
            width: '100%',
          }}
        />
      </Box>
    </Tooltip>
  );
};

const SpeciesPerks = (props: { perks: Species['perks'] }) => {
  const { positive, negative, neutral } = props.perks;

  return (
    <Stack fill justify="space-between">
      <Stack.Item>
        <Stack>
          {positive.map((perk) => {
            return (
              <Stack.Item key={perk.name}>
                <SpeciesPerk className="color-bg-green" perk={perk} />
              </Stack.Item>
            );
          })}
        </Stack>
      </Stack.Item>

      <Stack grow>
        {neutral.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-grey" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>

      <Stack>
        {negative.map((perk) => {
          return (
            <Stack.Item key={perk.name}>
              <SpeciesPerk className="color-bg-red" perk={perk} />
            </Stack.Item>
          );
        })}
      </Stack>
    </Stack>
  );
};

const SpeciesPageInner = (
  props: {
    handleClose: () => void;
    species: ServerData['species'];
  },
  context
) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const setSpecies = createSetPreference(act, 'species');

  let species: [string, Species][] = Object.entries(props.species).map(
    ([species, data]) => {
      return [species, data];
    }
  );

  // Humans are always the top of the list
  const humanIndex = species.findIndex(([species]) => species === 'human');
  const swapWith = species[0];
  species[0] = species[humanIndex];
  species[humanIndex] = swapWith;

  const currentSpecies = species.filter(([speciesKey]) => {
    return speciesKey === data.character_preferences.misc.species;
  })[0][1];

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Button
          icon="arrow-left"
          onClick={props.handleClose}
          content="Go Back"
        />
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <Box height="calc(100vh - 170px)" overflowY="auto" pr={3}>
              {species.map(([speciesKey, species]) => {
                return (
                  <Button
                    key={speciesKey}
                    onClick={() => setSpecies(speciesKey)}
                    selected={
                      data.character_preferences.misc.species === speciesKey
                    }
                    tooltip={species.name}
                    style={{
                      display: 'block',
                      height: '64px',
                      width: '64px',
                    }}>
                    <Box
                      className={classes(['species64x64', species.icon])}
                      ml={-1}
                    />
                  </Button>
                );
              })}
            </Box>
          </Stack.Item>

          <Stack.Item grow>
            <Box fill>
              <Box>
                <Stack fill>
                  <Stack.Item width="70%">
                    <Section
                      title={currentSpecies.name}
                      buttons={
                        // NOHUNGER species have no diet (diet = null),
                        // so we have nothing to show
                        currentSpecies.diet && (
                          <Diet diet={currentSpecies.diet} />
                        )
                      }>
                      <Section title="Description">
                        {currentSpecies.desc}
                      </Section>

                      <Section title="Features">
                        <SpeciesPerks perks={currentSpecies.perks} />
                      </Section>
                    </Section>
                  </Stack.Item>

                  <Stack.Item width="30%">
                    <CharacterPreview
                      id={data.character_preview_view}
                      height="100%"
                    />
                  </Stack.Item>
                </Stack>
              </Box>

              <Box mt={1}>
                <Section title="Lore">
                  <BlockQuote>
                    {currentSpecies.lore.map((text, index) => (
                      <Box key={index} maxWidth="100%">
                        {text}
                        {index !== currentSpecies.lore.length - 1 && (
                          <>
                            <br />
                            <br />
                          </>
                        )}
                      </Box>
                    ))}
                  </BlockQuote>
                </Section>
              </Box>
            </Box>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const SpeciesPage = (props: { closeSpecies: () => void }) => {
  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (serverData) {
          return (
            <SpeciesPageInner
              handleClose={props.closeSpecies}
              species={serverData.species}
            />
          );
        } else {
          return <Box>Loading species...</Box>;
        }
      }}
    />
  );
};
