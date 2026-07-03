import { useSessionStorage } from '@uidotdev/usehooks';
import { useEffect, useRef, useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Divider,
  Icon,
  ImageButton,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { CharacterPreview } from '../../common/CharacterPreview';
import { LoadingScreen } from '../../common/LoadingScreen';
import {
  createSetPreference,
  Food,
  type Perk,
  type PreferencesMenuData,
  type ServerData,
  type Species,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';

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
  [Food.Stone]: 'gem',
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
  [Food.Stone]: 'Rocks',
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

function notIn<T>(set: Set<T>) {
  return (value: T) => {
    return !set.has(value);
  };
}

type FoodListProps = {
  food: Food[];
  icon: string;
  name: string;
  className: string;
};

function FoodList(props: FoodListProps) {
  const { food = [], icon, name, className } = props;
  if (food.length === 0) {
    return null;
  }

  return (
    <Tooltip
      position="bottom-end"
      content={
        <Box>
          <Icon name={icon} /> <b>{name}</b>
          <Divider />
          <Box>
            {food
              .reduce((names, food) => {
                const foodName = FOOD_NAMES[food];
                return foodName ? names.concat(foodName) : names;
              }, [])
              .join(', ')}
          </Box>
        </Box>
      }
    >
      <Stack.Item>
        <Stack>
          {food.map((food) => {
            return (
              FOOD_ICONS[food] && (
                <Stack.Item>
                  <Icon
                    className={className}
                    size={1.4}
                    key={food}
                    name={FOOD_ICONS[food]}
                  />
                </Stack.Item>
              )
            );
          })}
        </Stack>
      </Stack.Item>
    </Tooltip>
  );
}

type DietProps = {
  diet: Species['diet'];
};

function Diet(props: DietProps) {
  const { diet } = props;
  if (!diet) {
    return null;
  }

  const { liked_food, disliked_food, toxic_food } = diet;
  return (
    <Stack g={4}>
      <FoodList
        food={liked_food}
        icon="heart"
        name="Любимая пища"
        className="color-pink"
      />
      <FoodList
        food={disliked_food.filter(notIn(IGNORE_UNLESS_LIKED))}
        icon="thumbs-down"
        name="Нелюбимая пища"
        className="color-red"
      />
      <FoodList
        food={toxic_food.filter(notIn(IGNORE_UNLESS_LIKED))}
        icon="biohazard"
        name="Токсичная пища"
        className="color-olive"
      />
    </Stack>
  );
}

type SpeciesPerkProps = {
  color: string;
  perk: Perk;
};

function SpeciesPerk(props: SpeciesPerkProps) {
  const { color, perk } = props;

  return (
    <Tooltip
      position="right-start"
      content={<Section title={perk.name}>{perk.description}</Section>}
    >
      <Stack className={classes([color, 'PreferencesMenu__Species__Perk'])}>
        <Icon name={perk.ui_icon} size={1.5} />
      </Stack>
    </Tooltip>
  );
}

type SpeciesPerksProps = {
  perks: Species['perks'];
};

function SpeciesPerks(props: SpeciesPerksProps) {
  const { positive, negative, neutral } = props.perks;
  const empty =
    positive.length === 0 && negative.length === 0 && neutral.length === 0;
  if (empty) {
    return null;
  }

  return (
    <Stack.Item>
      <Section fill scrollable className="PreferencesMenu__Species__Perks">
        <Stack fill vertical justify="center">
          {positive.map((perk) => {
            return <SpeciesPerk key={perk.name} perk={perk} color="green" />;
          })}
          <Stack.Divider />
          {neutral.map((perk) => {
            return <SpeciesPerk key={perk.name} perk={perk} color="grey" />;
          })}
          {negative.length > 0 && <Stack.Divider />}
          {negative.map((perk) => {
            return <SpeciesPerk key={perk.name} perk={perk} color="red" />;
          })}
        </Stack>
      </Section>
    </Stack.Item>
  );
}

type SpeciesPageInnerProps = {
  handleClose: () => void;
  species: ServerData['species'];
};

function SpeciesPageInner(props: SpeciesPageInnerProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const setSpecies = createSetPreference(act, 'species');

  const species: [string, Species][] = Object.entries(props.species).map(
    ([species, data]) => {
      return [species, data];
    },
  );

  // Humans are always the top of the list
  const humanIndex = species.findIndex(([species]) => species === 'human');
  const swapWith = species[0];
  species[0] = species[humanIndex];
  species[humanIndex] = swapWith;

  const currentSpecies = species.filter(([speciesKey]) => {
    return speciesKey === data.character_preferences.misc.species;
  })[0][1];

  function SpeciesInfo(props) {
    return (
      <Stack fill>
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item basis="33%">
              <Section
                fill
                scrollable
                title={
                  <Stack fill align="center">
                    <Stack.Item>
                      <Button icon="arrow-left" onClick={props.onHandleClose} />
                    </Stack.Item>
                    <Stack.Item grow>{currentSpecies.name}</Stack.Item>
                    {currentSpecies.diet && (
                      <Stack.Item>
                        <Diet diet={currentSpecies.diet} />
                      </Stack.Item>
                    )}
                  </Stack>
                }
              >
                {currentSpecies.desc}
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill scrollable title="История">
                {currentSpecies.lore.map((text, index) => (
                  <Box
                    key={index}
                    className="PreferencesMenu__Species__History"
                  >
                    {text}
                  </Box>
                ))}
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <SpeciesPerks perks={currentSpecies.perks} />
      </Stack>
    );
  }

  function SpeciesSelection(props) {
    const scrollRef = useRef<HTMLDivElement>(null);
    const [canScrollLeft, setCanScrollLeft] = useState(false);
    const [canScrollRight, setCanScrollRight] = useState(false);
    const [savedScroll, setSavedScroll] = useSessionStorage(
      'species-scroll',
      0,
    );

    function makeScroll(amount: number, fast?: boolean) {
      const speciesContainer = scrollRef.current;
      speciesContainer?.scrollBy({
        left: amount,
        behavior: fast ? 'instant' : 'smooth',
      });
    }

    useEffect(() => {
      const speciesContainer = scrollRef.current;
      makeScroll(savedScroll, true);
      checkScroll();

      function checkScroll() {
        if (!speciesContainer) {
          return;
        }

        setCanScrollLeft(speciesContainer.scrollLeft > 0);
        setCanScrollRight(
          speciesContainer.scrollLeft + speciesContainer.clientWidth <
            speciesContainer.scrollWidth,
        );
        setSavedScroll(speciesContainer.scrollLeft || 0);
      }

      speciesContainer?.addEventListener('scrollend', checkScroll);
      return () => {
        speciesContainer?.removeEventListener('scrollend', checkScroll);
      };
    }, []);

    const scrollSize = 220;
    return (
      <Stack justify="center">
        {canScrollLeft && (
          <Stack.Item
            className="PreferencesMenu__Species__OverflowButton left"
            onClick={() => makeScroll(-scrollSize)}
          >
            <Icon name="angle-left" size={5} />
          </Stack.Item>
        )}
        <div ref={scrollRef} className="PreferencesMenu__Species">
          {species.map(([speciesKey, species]) => {
            return (
              <Stack.Item key={speciesKey}>
                <ImageButton
                  tooltip={species.name}
                  selected={
                    data.character_preferences.misc.species === speciesKey
                  }
                  asset={['species64x64', species.icon]}
                  assetSize={64}
                  imageSize={72}
                  onClick={() => setSpecies(speciesKey)}
                >
                  {species.name}
                </ImageButton>
              </Stack.Item>
            );
          })}
        </div>
        {canScrollRight && (
          <Stack.Item
            className="PreferencesMenu__Species__OverflowButton right"
            onClick={() => makeScroll(scrollSize)}
          >
            <Icon name="angle-right" size={5} />
          </Stack.Item>
        )}
      </Stack>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <SpeciesInfo onHandleClose={props.handleClose} />
          </Stack.Item>
          <Stack.Item>
            <CharacterPreview id={data.character_preview_view} height="100%" />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section fill overflow="hidden">
          <SpeciesSelection />
        </Section>
      </Stack.Item>
    </Stack>
  );
}

type SpeciesPageProps = {
  closeSpecies: () => void;
};

export function SpeciesPage(props: SpeciesPageProps) {
  const serverData = useServerPrefs();
  if (!serverData) {
    return <LoadingScreen />;
  }

  return (
    <SpeciesPageInner
      handleClose={props.closeSpecies}
      species={serverData.species}
    />
  );
}
