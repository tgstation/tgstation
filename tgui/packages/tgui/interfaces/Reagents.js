import { useBackend, useLocalState } from '../backend';
import { Button, Icon, LabeledList, Section, Stack, Table } from '../components';
import { Window } from '../layouts';
import { ReagentLookup } from './common/ReagentLookup';
import { RecipeLookup } from './common/RecipeLookup';

const bookmarkedReactions = new Set();

const matchBitflag = (a, b) => (a & b) && (a | b) === b;

export const Reagents = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    beakerSync,
    reagent_mode_recipe,
    reagent_mode_reagent,
    bitflags = {},
  } = data;

  const flagIcons = [
    { flag: bitflags.BRUTE, icon: "gavel" },
    { flag: bitflags.BURN, icon: "burn" },
    { flag: bitflags.TOXIN, icon: "biohazard" },
    { flag: bitflags.OXY, icon: "wind" },
    { flag: bitflags.CLONE, icon: "male" },
    { flag: bitflags.HEALING, icon: "medkit" },
    { flag: bitflags.DAMAGING, icon: "skull-crossbones" },
    { flag: bitflags.EXPLOSIVE, icon: "bomb" },
    { flag: bitflags.OTHER, icon: "question" },
    { flag: bitflags.DANGEROUS, icon: "exclamation-triangle" },
    { flag: bitflags.EASY, icon: "chess-pawn" },
    { flag: bitflags.MODERATE, icon: "chess-knight" },
    { flag: bitflags.HARD, icon: "chess-queen" },
    { flag: bitflags.ORGAN, icon: "brain" },
    { flag: bitflags.DRINK, icon: "cocktail" },
    { flag: bitflags.FOOD, icon: "drumstick-bite" },
    { flag: bitflags.SLIME, icon: "microscope" },
    { flag: bitflags.DRUG, icon: "pills" },
    { flag: bitflags.UNIQUE, icon: "puzzle-piece" },
    { flag: bitflags.CHEMICAL, icon: "flask" },
    { flag: bitflags.PLANT, icon: "seedling" },
    { flag: bitflags.COMPETITIVE, icon: "recycle" },
  ];

  return (
    <Window
      width={720}
      height={850}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <Section
                  title="Recipe lookup"
                  minWidth="353px"
                  buttons={(
                    <>
                      <Button
                        content="Beaker Sync"
                        icon="atom"
                        color={beakerSync ? "green" : "red"}
                        tooltip="When enabled the displayed reaction will automatically display ongoing reactions in the associated beaker."
                        onClick={() => act('beaker_sync')} />
                      <Button
                        content="Search recipes"
                        icon="search"
                        color="purple"
                        onClick={() => act('search_recipe')} />
                    </>
                  )}>
                  <RecipeLookup
                    recipe={reagent_mode_recipe}
                    bookmarkedReactions={bookmarkedReactions} />
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Section
                  title="Reagent lookup"
                  minWidth="300px"
                  buttons={(
                    <Button
                      content="Search reagents"
                      icon="search"
                      onClick={() => act('search_reagents')} />
                  )}>
                  <ReagentLookup reagent={reagent_mode_reagent} />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section title="Tags">
              <TagBox
                bitflags={bitflags} />
            </Section>
          </Stack.Item>
          <Stack.Item grow={2} basis={0}>
            <RecipeLibrary
              flagIcons={flagIcons} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};


const TagBox = (props, context) => {
  const { act, data } = useBackend(context);
  const { bitflags } = props;
  const { selectedBitflags } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Affects">
        <Button
          color={selectedBitflags & bitflags.BRUTE ? "green" : "red"}
          icon="gavel"
          onClick={() => act('toggle_tag_brute')}>
          Brute
        </Button>
        <Button
          color={selectedBitflags & bitflags.BURN ? "green" : "red"}
          icon="burn"
          onClick={() => act('toggle_tag_burn')}>
          Burn
        </Button>
        <Button
          color={selectedBitflags & bitflags.TOXIN ? "green" : "red"}
          icon="biohazard"
          onClick={() => act('toggle_tag_toxin')}>
          Toxin
        </Button>
        <Button
          color={selectedBitflags & bitflags.OXY ? "green" : "red"}
          icon="wind"
          onClick={() => act('toggle_tag_oxy')}>
          Suffocation
        </Button>
        <Button
          color={selectedBitflags & bitflags.CLONE ? "green" : "red"}
          icon="male"
          onClick={() => act('toggle_tag_clone')}>
          Clone
        </Button>
        <Button
          color={selectedBitflags & bitflags.ORGAN ? "green" : "red"}
          icon="brain"
          onClick={() => act('toggle_tag_organ')}>
          Organ
        </Button>
        <Button
          icon="flask"
          color={selectedBitflags & bitflags.CHEMICAL ? "green" : "red"}
          onClick={() => act('toggle_tag_chemical')}>
          Chemical
        </Button>
        <Button
          icon="seedling"
          color={selectedBitflags & bitflags.PLANT ? "green" : "red"}
          onClick={() => act('toggle_tag_plant')}>
          Plants
        </Button>
        <Button
          icon="question"
          color={selectedBitflags & bitflags.OTHER ? "green" : "red"}
          onClick={() => act('toggle_tag_other')}>
          Other
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Type">
        <Button
          color={selectedBitflags & bitflags.DRINK ? "green" : "red"}
          icon="cocktail"
          onClick={() => act('toggle_tag_drink')}>
          Drink
        </Button>
        <Button
          color={selectedBitflags & bitflags.FOOD ? "green" : "red"}
          icon="drumstick-bite"
          onClick={() => act('toggle_tag_food')}>
          Food
        </Button>
        <Button
          color={selectedBitflags & bitflags.HEALING ? "green" : "red"}
          icon="medkit"
          onClick={() => act('toggle_tag_healing')}>
          Healing
        </Button>
        <Button
          icon="skull-crossbones"
          color={selectedBitflags & bitflags.DAMAGING ? "green" : "red"}
          onClick={() => act('toggle_tag_damaging')}>
          Toxic
        </Button>
        <Button
          icon="pills"
          color={selectedBitflags & bitflags.DRUG ? "green" : "red"}
          onClick={() => act('toggle_tag_drug')}>
          Drugs
        </Button>
        <Button
          icon="microscope"
          color={selectedBitflags & bitflags.SLIME ? "green" : "red"}
          onClick={() => act('toggle_tag_slime')}>
          Slime
        </Button>
        <Button
          icon="bomb"
          color={selectedBitflags & bitflags.EXPLOSIVE ? "green" : "red"}
          onClick={() => act('toggle_tag_explosive')}>
          Explosive
        </Button>
        <Button
          icon="puzzle-piece"
          color={selectedBitflags & bitflags.UNIQUE ? "green" : "red"}
          onClick={() => act('toggle_tag_unique')}>
          Unique
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Difficulty">
        <Button
          icon="chess-pawn"
          color={selectedBitflags & bitflags.EASY ? "green" : "red"}
          onClick={() => act('toggle_tag_easy')}>
          Easy
        </Button>
        <Button
          icon="chess-knight"
          color={selectedBitflags & bitflags.MODERATE ? "green" : "red"}
          onClick={() => act('toggle_tag_moderate')}>
          Moderate
        </Button>
        <Button
          icon="chess-queen"
          color={selectedBitflags & bitflags.HARD ? "green" : "red"}
          onClick={() => act('toggle_tag_hard')}>
          Hard
        </Button>
        <Button
          icon="exclamation-triangle"
          color={selectedBitflags & bitflags.DANGEROUS ? "green" : "red"}
          onClick={() => act('toggle_tag_dangerous')}>
          Dangerous
        </Button>
        <Button
          icon="recycle"
          color={selectedBitflags & bitflags.COMPETITIVE ? "green" : "red"}
          onClick={() => act('toggle_tag_competitive')}>
          Competitive
        </Button>
      </LabeledList.Item>
    </LabeledList>
  );
};

const RecipeLibrary = (props, context) => {
  const { act, data } = useBackend(context);
  const { flagIcons } = props;
  const {
    selectedBitflags,
    currentReagents = [],
    master_reaction_list = [],
    linkedBeaker,
  } = data;

  const [reagentFilter, setReagentFilter] = useLocalState(
    context, 'reagentFilter', true);
  const [bookmarkMode, setBookmarkMode] = useLocalState(
    context, 'bookmarkMode', false);

  const matchReagents = reaction => {
    if (!reagentFilter || currentReagents === null) {
      return true;
    }
    let matches = reaction.reactants
      .filter(reactant => currentReagents.includes(reactant.id))
      .length;
    return matches === currentReagents.length;
  };

  const bookmarkArray = Array.from(bookmarkedReactions);

  const visibleReactions = bookmarkMode
    ? bookmarkArray
    : master_reaction_list.filter(reaction => (
      (selectedBitflags
        ? matchBitflag(selectedBitflags, reaction.bitflags)
        : true)
      && matchReagents(reaction)
    ));

  const addBookmark = bookmark => {
    bookmarkedReactions.add(bookmark);
  };

  const removeBookmark = bookmark => {
    bookmarkedReactions.delete(bookmark);
  };

  return (
    <Section
      fill
      scrollable
      title={bookmarkMode ? "Bookmarked recipes" : "Possible recipes"}
      buttons={(
        <>
          Linked beaker: {linkedBeaker+"  "}
          <Button
            content="Filter by reagents in beaker"
            icon="search"
            disabled={bookmarkMode}
            color={reagentFilter ? "green" : "red"}
            onClick={() => setReagentFilter(!reagentFilter)} />
          <Button
            content="Bookmarks"
            icon="book"
            color={bookmarkMode ? "green" : "red"}
            onClick={() => setBookmarkMode(!bookmarkMode)} />
        </>
      )}>
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
            {!bookmarkMode ? "Save" : "Del"}
          </Table.Cell>
        </Table.Row>
        {visibleReactions.map(reaction => (
          <Table.Row key={reaction.id} className="candystripe">
            <>
              <Table.Cell bold color="label">
                <Button
                  mt={0.5}
                  icon="flask"
                  color="purple"
                  content={reaction.name}
                  onClick={() => act('recipe_click', {
                    id: reaction.id,
                  })} />
              </Table.Cell>
              <Table.Cell>
                {reaction.reactants.map(reactant => (
                  <Button
                    key={reactant.id}
                    mt={0.1}
                    icon="vial"
                    textColor="white"
                    color={currentReagents?.includes(reactant.id) && "green"} // check here
                    content={reactant.name}
                    onClick={() => act('reagent_click', {
                      id: reactant.id,
                    })} />
                ))}
              </Table.Cell>
              <Table.Cell width="60px">
                {flagIcons
                  .filter(meta => reaction.bitflags & meta.flag)
                  .map(meta => (
                    <Icon key={meta.flag} name={meta.icon} mr={1} />
                  ))}
              </Table.Cell>
              <Table.Cell width="20px">
                {!bookmarkMode && (
                  <Button
                    icon="book"
                    color="green"
                    disabled={bookmarkedReactions.has(reaction)}
                    onClick={() => {
                      addBookmark(reaction);
                      act('update_ui');
                    }} />
                ) || (
                  <Button
                    icon="trash"
                    color="red"
                    onClick={() => removeBookmark(reaction)} />
                )}
              </Table.Cell>
            </>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
