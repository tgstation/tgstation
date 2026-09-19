import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Floating,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch, toTitleCase } from 'tgui-core/string';
import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { type Beaker, BeakerDisplay } from './common/BeakerDisplay';
import { bitflagInfo } from './Reagents/types';

enum DropdownState {
  NO_DROPDOWN = 0,
  DROPDOWN_CLOSED = 1,
  DROPDOWN_OPEN = 2,
}

type DispensableReagent = {
  title: string;
  id: string;
  pH: number;
  color: string;
  pHCol: string;
};

type TransferableBeaker = Beaker & {
  transferAmounts: number[];
};

type ReactionTypepath = string;
type ReagentTypepath = string;

type ReactionComponent = {
  name: string;
  amount: number;
  id: ReagentTypepath;
};

type Reaction = {
  id: ReactionTypepath;
  bitflags: number;
  lower_temperature: number;
  upper_temperature: number;
  lower_ph: number;
  upper_ph: number;
  required_reagents: ReactionComponent[];
  required_catalysts: ReactionComponent[];
  description: string;
  color: string; // hex
};

type ReagentReaction = {
  name: string;
  reaction: Reaction;
};

type Data = {
  showpH: BooleanLike;
  amount: number;
  energy: number;
  maxEnergy: number;
  displayedUnits: string;
  displayedMaxUnits: string;
  chemicals: DispensableReagent[];
  recipes: string[];
  recordingRecipe: string[];
  recipeReagents: string[];
  beaker: TransferableBeaker;
  hasBeakerInHand: BooleanLike;
  // static
  reaction_list: Record<string, Reaction>;
  all_bitflags: Record<string, number>;
};

function reagentListToArray(
  reagentList: Record<string, Reaction>,
): ReagentReaction[] {
  return Object.entries(reagentList).map(([name, reaction]) => ({
    name: name,
    reaction: reaction,
  }));
}

export const ChemDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const recording = !!data.recordingRecipe;
  const {
    recipes = [],
    beaker,
    hasBeakerInHand,
    reaction_list,
    all_bitflags,
    chemicals,
  } = data;
  const [showPhCol, setShowPhCol] = useSharedState('showbaseph', false);
  const [showReactionList, setShowReactionList] = useSharedState(
    'showreactions',
    false,
  );
  const [searchTerm, setSearchTerm] = useSharedState('searchterm', '');
  const [filterByBitflag, setFilterByBitflag] = useSharedState<number>(
    'filterbitflag',
    0,
  );
  const [pinnedReactions, setPinnedReactions] = useSharedState<string[]>(
    'pinnedreactions',
    [],
  );

  const beakerTransferAmounts = beaker ? beaker.transferAmounts : [];
  const recordedContents =
    recording &&
    Object.keys(data.recordingRecipe).map((id) => ({
      id,
      name: toTitleCase(id.replace(/_/, ' ')),
      volume: data.recordingRecipe[id],
    }));

  // convert reagent list record to list of ReagentReaction
  const reactionReagentList = reagentListToArray(reaction_list);

  const reactionSearch = createSearch(
    searchTerm,
    (reaction: ReagentReaction) => reaction.name,
  );

  // filter the reaction list first by whitelist bitflags, then by search term
  const filteredReactions = reactionReagentList
    .filter((reaction) => {
      // filter by whitelist bitflags
      if (
        filterByBitflag !== 0 &&
        (reaction.reaction.bitflags & filterByBitflag) !== filterByBitflag
      )
        return false;
      // filter base reagents
      if (chemicals.find((chem) => chem.title === reaction.name)) return false;
      // filter by search term
      return reactionSearch(reaction);
    })
    .sort((a, b) => (a.name > b.name ? 1 : -1))
    .sort((a, b) => {
      // pinned reactions go first
      const aPinned = pinnedReactions.includes(a.name);
      const bPinned = pinnedReactions.includes(b.name);
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });

  const mainWidth = 565;
  const reactionWidth = 245;
  const windowWidth = mainWidth + (showReactionList ? reactionWidth : 0);

  return (
    <Window width={windowWidth} height={620}>
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item width={mainWidth} gr>
            <Stack vertical fill>
              <Stack.Item>
                <Section
                  title="Status"
                  buttons={
                    <>
                      {recording && (
                        <Box inline mx={1} color="red">
                          <Icon name="circle" mr={1} />
                          Recording
                        </Box>
                      )}
                      <Button
                        icon="cog"
                        tooltip="Color code the reagents by pH"
                        tooltipPosition="bottom-start"
                        selected={showPhCol}
                        onClick={() => setShowPhCol(!showPhCol)}
                      />
                      <Button
                        icon="book"
                        disabled={!beaker}
                        tooltip={
                          beaker
                            ? 'Look up recipes and reagents!'
                            : 'Please insert a beaker!'
                        }
                        tooltipPosition="bottom-start"
                        onClick={() => act('reaction_lookup')}
                      >
                        Reactions
                      </Button>
                      <Button
                        icon={showReactionList ? 'arrow-left' : 'arrow-right'}
                        tooltipPosition="bottom-start"
                        onClick={() => setShowReactionList(!showReactionList)}
                      >
                        Recipes
                      </Button>
                    </>
                  }
                >
                  <LabeledList>
                    <LabeledList.Item label="Energy">
                      <ProgressBar value={data.energy / data.maxEnergy}>
                        {data.displayedUnits +
                          ' / ' +
                          data.displayedMaxUnits +
                          ' units'}
                      </ProgressBar>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Custom Recipes"
                  buttons={
                    <>
                      {!recording && (
                        <Box inline mx={1}>
                          <Button
                            color="transparent"
                            onClick={() => act('clear_recipes')}
                          >
                            Clear recipes
                          </Button>
                        </Box>
                      )}
                      {!recording && (
                        <Button
                          icon="circle"
                          disabled={!beaker}
                          onClick={() => act('record_recipe')}
                        >
                          Record
                        </Button>
                      )}
                      {recording && (
                        <Button
                          icon="ban"
                          color="transparent"
                          onClick={() => act('cancel_recording')}
                        >
                          Discard
                        </Button>
                      )}
                      {recording && (
                        <Button
                          icon="save"
                          color="green"
                          onClick={() => act('save_recording')}
                        >
                          Save
                        </Button>
                      )}
                    </>
                  }
                >
                  <Box mr={-1}>
                    {Object.keys(recipes).map((recipe) => (
                      <Button
                        key={recipe}
                        icon="tint"
                        width="129.5px"
                        lineHeight={1.75}
                        onClick={() =>
                          act('dispense_recipe', {
                            recipe: recipe,
                          })
                        }
                      >
                        {recipe}
                      </Button>
                    ))}
                    {recipes.length === 0 && (
                      <Box color="light-gray">No recipes.</Box>
                    )}
                  </Box>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Dispense"
                  buttons={beakerTransferAmounts.map((amount) => (
                    <Button
                      key={amount}
                      icon="plus"
                      selected={amount === data.amount}
                      onClick={() =>
                        act('amount', {
                          target: amount,
                        })
                      }
                    >
                      {amount}
                    </Button>
                  ))}
                >
                  <Stack wrap>
                    {data.chemicals.map((chemical) => (
                      <Stack.Item width="24.5%" key={chemical.id} mr={-0.5}>
                        <ReagentDispenseButton
                          chemical={chemical}
                          showPhCol={showPhCol}
                          mainscreen={true}
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section
                  fill
                  title="Beaker"
                  buttons={beakerTransferAmounts.map((amount) => (
                    <Button
                      key={amount}
                      icon="minus"
                      disabled={recording}
                      onClick={() => act('remove', { amount })}
                    >
                      {amount}
                    </Button>
                  ))}
                >
                  {beaker || recording ? (
                    <BeakerDisplay
                      beaker={beaker}
                      title_label={recording && 'Virtual beaker'}
                      replace_contents={recordedContents}
                      showpH={data.showpH}
                    />
                  ) : (
                    <Box
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                      }}
                    >
                      <Box color="label">No beaker loaded.</Box>
                      <Button
                        icon="eject"
                        onClick={() => act('insert')}
                        disabled={!hasBeakerInHand}
                        tooltip={
                          !hasBeakerInHand &&
                          'You need to hold a container in your hand!'
                        }
                        tooltipPosition="left-start"
                      >
                        Insert
                      </Button>
                    </Box>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {showReactionList && (
            <Stack.Item width={reactionWidth}>
              <Section title="Recipes" fill>
                <Stack vertical fill>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow>
                        <Input
                          placeholder="Search reactions..."
                          value={searchTerm}
                          fluid
                          onChange={(value) => setSearchTerm(value)}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="times"
                          disabled={searchTerm === ''}
                          onClick={() => setSearchTerm('')}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="thumbtack"
                          disabled={pinnedReactions.length === 0}
                          onClick={() => setPinnedReactions([])}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Divider />
                  <Stack.Item>
                    <Stack wrap>
                      {Object.entries(all_bitflags).map(([readable, flag]) => (
                        <Stack.Item key={readable} grow>
                          <Button
                            fluid
                            align="center"
                            fontSize="0.9em"
                            onClick={() =>
                              setFilterByBitflag(flag ^ filterByBitflag)
                            }
                            tooltip={
                              <Box fontSize="0.9em">
                                {bitflagInfo.find((bf) => bf.flag === readable)
                                  ?.tooltip || ''}
                              </Box>
                            }
                            selected={(filterByBitflag & flag) !== 0}
                          >
                            {readable}
                          </Button>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Stack.Item>
                  <Stack.Divider />
                  <Stack.Item grow mt={1}>
                    <Section scrollable fill>
                      <Stack vertical>
                        {filteredReactions.length > 0 ? (
                          filteredReactions.map((reaction) => (
                            <Stack.Item key={reaction.name}>
                              <ReactionDisplay
                                dropdownState={
                                  pinnedReactions.includes(reaction.name)
                                    ? DropdownState.DROPDOWN_OPEN
                                    : DropdownState.DROPDOWN_CLOSED
                                }
                                reaction={reaction}
                                pinnedReactions={pinnedReactions}
                                setPinnedReactions={setPinnedReactions}
                              />
                            </Stack.Item>
                          ))
                        ) : (
                          <NoticeBox>No reactions found.</NoticeBox>
                        )}
                      </Stack>
                    </Section>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

type ReagentDispenseButtonProps = {
  chemical: DispensableReagent;
  showPhCol?: boolean;
  mainscreen?: boolean;
  prefix?: string;
};

const ReagentDispenseButton = (props: ReagentDispenseButtonProps) => {
  const { chemical, showPhCol, mainscreen, prefix } = props;
  const { act, data } = useBackend<Data>();
  const { recipeReagents = [] } = data;

  return (
    <Button
      key={chemical.id}
      icon="tint"
      fluid
      textColor={showPhCol ? chemical.pHCol : chemical.color}
      lineHeight={1.75}
      tooltip={mainscreen ? `pH: ${chemical.pH}` : undefined}
      style={{
        textShadow: '1px 1px 0 black',
        textOverflow: 'ellipsis',
        overflow: 'hidden',
      }}
      selected={mainscreen && recipeReagents.includes(chemical.id)}
      onClick={() =>
        act('dispense', {
          reagent: chemical.id,
        })
      }
    >
      <span
        style={{
          color: 'white',
          textShadow: 'none',
          textOverflow: 'ellipsis',
          overflow: 'hidden',
        }}
      >
        {prefix}
        {chemical.title}
      </span>
    </Button>
  );
};

type ReactionDisplayProps = {
  /// Determines how the collapsible/dropdown is displayed.
  /// NO_DROPDOWN: no dropdown is displayed, just the recipe list is shown
  /// DROPDOWN_CLOSED: dropdown is displayed, but closed by default
  /// DROPDOWN_OPEN: dropdown is displayed and open by default
  /// If undefined, the default behavior is DROPDOWN_CLOSED.
  dropdownState?: DropdownState;
  /// The reaction to display.
  reaction: ReagentReaction;
  /// List of reactions that are pinned to the top of the list.
  pinnedReactions: ReactionTypepath[];
  /// Callback to update the list of pinned reactions.
  setPinnedReactions: (reactions: ReactionTypepath[]) => void;
  /// Callback to force the parent component to keep their floating window open.
  setParentForceFloating?: (force: boolean) => void;
};

const ReactionDisplay = (props: ReactionDisplayProps) => {
  const {
    dropdownState,
    reaction,
    pinnedReactions,
    setPinnedReactions,
    setParentForceFloating,
  } = props;

  const recipeList = (
    <BlockQuote>
      <Stack vertical>
        <Stack.Item>
          <HorizontalBarWithText text="Formula" />
        </Stack.Item>
        {reaction.reaction.required_reagents.map((reagent) => (
          <Stack.Item key={`${reaction.name}-${reagent.name}-req`}>
            <ReactionComponentDisplay
              reagentComponent={reagent}
              pinnedReactions={pinnedReactions}
              setPinnedReactions={setPinnedReactions}
              setParentForceFloating={setParentForceFloating}
            />
          </Stack.Item>
        ))}
        {reaction.reaction.required_catalysts.length > 0 && (
          <>
            <Stack.Item>
              <HorizontalBarWithText
                text={`Catalyst${reaction.reaction.required_reagents.length === 1 ? '' : 's'}`}
              />
            </Stack.Item>
            {reaction.reaction.required_catalysts.map((catalyst) => (
              <Stack.Item key={`${reaction.name}-${catalyst.name}-cat`}>
                <ReactionComponentDisplay
                  reagentComponent={catalyst}
                  pinnedReactions={pinnedReactions}
                  setPinnedReactions={setPinnedReactions}
                  setParentForceFloating={setParentForceFloating}
                />
              </Stack.Item>
            ))}
          </>
        )}
        <Stack.Item>
          <HorizontalBarWithText text="Optimal temperature" />
        </Stack.Item>
        <Stack.Item fontSize="0.9em">
          {getTemperatureMessage(
            reaction.reaction.lower_temperature,
            reaction.reaction.upper_temperature,
          )}
        </Stack.Item>
        <Stack.Item>
          <HorizontalBarWithText text="Optimal pH range" />
        </Stack.Item>
        <Stack.Item fontSize="0.9em">
          {getPHMessage(reaction.reaction.lower_ph, reaction.reaction.upper_ph)}
        </Stack.Item>
      </Stack>
    </BlockQuote>
  );

  return (
    <Stack
      p={1}
      style={{
        borderRadius: '4px',
        flexDirection: 'column',
        backgroundColor: 'black',
      }}
    >
      <Stack.Item>
        <Stack align="center">
          <Stack.Item>
            <Button
              icon="thumbtack"
              onClick={() => {
                if (pinnedReactions.includes(reaction.name)) {
                  setPinnedReactions(
                    pinnedReactions.filter((rid) => rid !== reaction.name),
                  );
                } else {
                  setPinnedReactions([...pinnedReactions, reaction.name]);
                }
              }}
              onContextMenu={() => {
                setPinnedReactions([reaction.name]);
              }}
              selected={pinnedReactions.includes(reaction.name)}
            />
          </Stack.Item>
          <Stack.Item
            grow
            style={{
              overflow: 'hidden',
              whiteSpace: 'nowrap',
            }}
          >
            <Tooltip
              content={
                <Box fontSize="0.9rem">{reaction.reaction.description}</Box>
              }
              position="top"
            >
              <Stack fill>
                <Stack.Item
                  grow
                  style={{
                    textOverflow: 'ellipsis',
                    overflow: 'hidden',
                  }}
                >
                  {reaction.name}
                </Stack.Item>
                <Stack.Item
                  backgroundColor={reaction.reaction.color}
                  p={1.25}
                  style={{ borderRadius: '8px' }}
                />
              </Stack>
            </Tooltip>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        {dropdownState === DropdownState.NO_DROPDOWN ? (
          recipeList
        ) : (
          <Collapsible
            title="Recipe"
            open={dropdownState === DropdownState.DROPDOWN_OPEN}
          >
            {recipeList}
          </Collapsible>
        )}
      </Stack.Item>
    </Stack>
  );
};

// if lower and upper are the same, return "at X degrees"
// if lower and upper are >300, return "heat to between X and Y degrees"
// if lower and upper are <300, return "cool to between X and Y degrees"
// if lower is <300 and upper is >300, return "keep between X and Y degrees"
function getTemperatureMessage(lower: number, upper: number): string {
  if (lower === upper) {
    return `Forms at ${lower}°K`;
  } else if (lower > 300 && upper > 300) {
    return `Heat between ${lower}°K-${upper}°K`;
  } else if (lower < 300 && upper < 300) {
    return `Cool between ${Math.min(upper, lower)}°K-${Math.max(upper, lower)}°K`;
  } else {
    return `Keep between ${lower}°K-${upper}°K`;
  }
}

// if lower and upper are the same, return "keep at pH X"
// else return "keep between pH X and Y"
function getPHMessage(lower: number, upper: number): string {
  if (lower === upper) {
    return `Keep at pH ${lower}`;
  } else {
    return `Keep between pH ${lower}-${upper}`;
  }
}

type ReactionComponentDisplayProps = {
  /// What component of the reaction is being displayed.
  reagentComponent: ReactionComponent;
  /// List of reactions that are pinned to the top of the list.
  pinnedReactions: ReactionTypepath[];
  /// Callback to update the list of pinned reactions.
  setPinnedReactions: (reactions: ReactionTypepath[]) => void;
  /// Callback to force the parent component to keep their floating window open.
  setParentForceFloating?: (force: boolean) => void;
};

// linkifies a reagent name in the reaction display
// if it's a base reagent, it will dispense it when clicked
// if it's another recipe, it will put that recipe in the search box
// if it's nothing, it's not a button
const ReactionComponentDisplay = (props: ReactionComponentDisplayProps) => {
  const {
    reagentComponent,
    pinnedReactions,
    setPinnedReactions,
    setParentForceFloating,
  } = props;
  const { data } = useBackend<Data>();
  const { chemicals, reaction_list } = data;

  // check if it's a base reagent
  const baseReagent = chemicals.find(
    (chem) => chem.title === reagentComponent.name,
  );

  if (baseReagent) {
    return (
      <ReagentDispenseButton
        chemical={baseReagent}
        prefix={formatReagentName(reagentComponent.amount)}
      />
    );
  }

  const reactionReagentList = reagentListToArray(reaction_list);

  // check if it's a recipe
  const foundRecipe = reactionReagentList
    .filter((reaction) => {
      return reaction.name === reagentComponent.name;
    })
    .find((reaction) => reaction.name === reagentComponent.name);

  if (!foundRecipe)
    return (
      <Button fluid ellipsis disabled icon="question">
        {formatReagentName(reagentComponent.amount, reagentComponent.name)}
      </Button>
    );

  const [forceFloating, setForceFloating] = useState(false);

  return (
    <Floating
      // `|| undefined` is used to avoid passing `false`.
      // The component treats `false` as `closed`,
      // whereas `undefined` means "not controlled",
      // allowing it to open and close normally.
      handleOpen={forceFloating || undefined}
      // No similar handling is necessary for `disabled`.
      // If we don't disable it it will close on unhover, for some reason.
      disabled={forceFloating}
      placement="left"
      closeAfterInteract={false}
      // `hoverOpen` is obvious, but `hoverSafePolygon` is what is needed
      // to allow the user to move their mouse over to the floating window.
      hoverOpen={true}
      hoverSafePolygon={true}
      // When the window state changes, we go up the chain to inform the parent.
      // At the same time we *always* reset forced state on close,
      // to prevent it from being stuck in limbo if it somehow closes otherwise.
      onOpenChange={(state) => {
        if (setParentForceFloating) {
          setParentForceFloating(state);
        }
        if (!state) {
          setForceFloating(false);
        }
      }}
      content={
        <Box
          p={0.5}
          backgroundColor={`hsl(0, 0%, 15%)`}
          style={{
            borderRadius: '4px',
            backdropFilter: 'blur(12px)',
          }}
        >
          <Stack
            backgroundColor="black"
            p={1}
            style={{
              borderRadius: '4px',
              flexDirection: 'column',
            }}
          >
            <Stack.Item>
              <ReactionDisplay
                dropdownState={DropdownState.NO_DROPDOWN}
                reaction={foundRecipe}
                pinnedReactions={pinnedReactions}
                setPinnedReactions={setPinnedReactions}
                setParentForceFloating={setForceFloating}
              />
            </Stack.Item>
          </Stack>
        </Box>
      }
    >
      <Button icon="book" fluid ellipsis backgroundColor="default">
        {formatReagentName(reagentComponent.amount, reagentComponent.name)}
      </Button>
    </Floating>
  );
};

function formatReagentName(amount: number, name?: string) {
  if (!name) return `${amount} part `;

  return `${amount} part${amount === 1 ? '' : 's'} ${name}`;
}

const HorizontalBarWithText = (props: { text: string }) => {
  const { text } = props;
  return (
    <Stack>
      <Stack.Item grow>
        <hr />
      </Stack.Item>
      <Stack.Item fontSize="0.95em">{text}</Stack.Item>
      <Stack.Item grow>
        <hr />
      </Stack.Item>
    </Stack>
  );
};
