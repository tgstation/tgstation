import { useState } from 'react';
import {
  Button,
  Icon,
  NumberInput,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { bookmarkedReactions } from '.';
import { ReagentsData, ReagentsProps } from './types';

function matchBitflag(a: number, b: number) {
  return a & b && (a | b) === b;
}

export function RecipeLibrary(props: ReagentsProps) {
  const { act, data } = useBackend<ReagentsData>();

  const [page, setPage] = props.pageState;

  const {
    bitflags = {},
    currentReagents = [],
    linkedBeaker,
    master_reaction_list = [],
    selectedBitflags,
  } = data;

  const [reagentFilter, setReagentFilter] = useState(true);
  const [bookmarkMode, setBookmarkMode] = useState(false);

  function matchReagents(reaction) {
    if (!reagentFilter || currentReagents === null) {
      return true;
    }
    let matches = reaction.reactants.filter((reactant) =>
      currentReagents.includes(reactant.id),
    ).length;
    return matches === currentReagents.length;
  }

  const bookmarkArray = Array.from(bookmarkedReactions);

  const startIndex = 50 * (page - 1);

  const endIndex = 50 * page;

  const visibleReactions = bookmarkMode
    ? bookmarkArray
    : master_reaction_list.filter(
        (reaction) =>
          (selectedBitflags
            ? matchBitflag(selectedBitflags, reaction.bitflags)
            : true) && matchReagents(reaction),
      );

  const pageIndexMax = Math.ceil(visibleReactions.length / 50);

  const flagIcons = [
    { flag: bitflags.BRUTE, icon: 'gavel' },
    { flag: bitflags.BURN, icon: 'burn' },
    { flag: bitflags.TOXIN, icon: 'biohazard' },
    { flag: bitflags.OXY, icon: 'wind' },
    { flag: bitflags.HEALING, icon: 'medkit' },
    { flag: bitflags.DAMAGING, icon: 'skull-crossbones' },
    { flag: bitflags.EXPLOSIVE, icon: 'bomb' },
    { flag: bitflags.OTHER, icon: 'question' },
    { flag: bitflags.DANGEROUS, icon: 'exclamation-triangle' },
    { flag: bitflags.EASY, icon: 'chess-pawn' },
    { flag: bitflags.MODERATE, icon: 'chess-knight' },
    { flag: bitflags.HARD, icon: 'chess-queen' },
    { flag: bitflags.ORGAN, icon: 'brain' },
    { flag: bitflags.DRINK, icon: 'cocktail' },
    { flag: bitflags.FOOD, icon: 'drumstick-bite' },
    { flag: bitflags.SLIME, icon: 'microscope' },
    { flag: bitflags.DRUG, icon: 'pills' },
    { flag: bitflags.UNIQUE, icon: 'puzzle-piece' },
    { flag: bitflags.CHEMICAL, icon: 'flask' },
    { flag: bitflags.PLANT, icon: 'seedling' },
    { flag: bitflags.COMPETITIVE, icon: 'recycle' },
  ];

  return (
    <Section
      fill
      scrollable
      title={bookmarkMode ? 'Bookmarked recipes' : 'Possible recipes'}
      buttons={
        <>
          Beaker: {linkedBeaker + '  '}
          <Button
            icon="search"
            disabled={bookmarkMode}
            color={reagentFilter ? 'green' : 'red'}
            onClick={() => {
              setReagentFilter(!reagentFilter);
              setPage(1);
            }}
          >
            Filter by reagents in beaker
          </Button>
          <Button
            icon="book"
            color={bookmarkMode ? 'green' : 'red'}
            onClick={() => {
              setBookmarkMode(!bookmarkMode);
              setPage(1);
            }}
          >
            Bookmarks
          </Button>
          <Button
            icon="minus"
            disabled={page === 1}
            onClick={() => setPage(Math.max(page - 1, 1))}
          />
          <NumberInput
            width="25px"
            step={1}
            stepPixelSize={3}
            value={page}
            minValue={1}
            maxValue={pageIndexMax}
            onDrag={(value) => setPage(value)}
          />
          <Button
            icon="plus"
            disabled={page === pageIndexMax}
            onClick={() => setPage(Math.min(page + 1, pageIndexMax))}
          />
        </>
      }
    >
      <Table>
        <Table.Row>
          <Table.Cell bold color="label">
            Reaction
          </Table.Cell>
          <Table.Cell bold color="label">
            Required reagents
          </Table.Cell>
          <Table.Cell bold color="label">
            Tags
          </Table.Cell>
          <Table.Cell bold color="label" width="20px">
            {!bookmarkMode ? 'Save' : 'Del'}
          </Table.Cell>
        </Table.Row>
        {visibleReactions.slice(startIndex, endIndex).map((reaction) => (
          <Table.Row key={reaction.id} className="candystripe">
            <Table.Cell bold color="label">
              <Button
                mt={0.5}
                icon="flask"
                color="purple"
                onClick={() =>
                  act('recipe_click', {
                    id: reaction.id,
                  })
                }
              >
                {reaction.name}
              </Button>
            </Table.Cell>
            <Table.Cell>
              {reaction.reactants.map((reactant) => (
                <Button
                  key={reactant.id}
                  mt={0.1}
                  icon="vial"
                  textColor="white"
                  color={currentReagents?.includes(reactant.id) && 'green'} // check here
                  onClick={() =>
                    act('reagent_click', {
                      id: reactant.id,
                    })
                  }
                >
                  {reactant.name}
                </Button>
              ))}
            </Table.Cell>
            <Table.Cell width="60px">
              {flagIcons
                .filter((meta) => reaction.bitflags & meta.flag)
                .map((meta) => (
                  <Icon key={meta.flag} name={meta.icon} mr={1} />
                ))}
            </Table.Cell>
            <Table.Cell width="20px">
              {!bookmarkMode ? (
                <Button
                  icon="book"
                  color="green"
                  disabled={bookmarkedReactions.has(reaction)}
                  onClick={() => {
                    bookmarkedReactions.add(reaction);
                    act('update_ui');
                  }}
                />
              ) : (
                <Button
                  icon="trash"
                  color="red"
                  onClick={() => bookmarkedReactions.delete(reaction)}
                />
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}
