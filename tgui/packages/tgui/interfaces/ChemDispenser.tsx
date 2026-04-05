import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
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
                                reaction={reaction}
                                pinnedReactions={pinnedReactions}
                                setPinnedReactions={setPinnedReactions}
                                setSearchTerm={setSearchTerm}
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
  reaction: ReagentReaction;
  pinnedReactions: ReactionTypepath[];
  setPinnedReactions: (reactions: ReactionTypepath[]) => void;
  setSearchTerm: (term: string) => void;
};

const ReactionDisplay = (props: ReactionDisplayProps) => {
  const { reaction, pinnedReactions, setPinnedReactions } = props;
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
        <Collapsible
          title="Recipe"
          open={pinnedReactions.includes(reaction.name)}
        >
          <BlockQuote>
            <Stack vertical>
              <Stack.Item>
                <HorizontalBarWithText text="Formula" />
              </Stack.Item>
              {reaction.reaction.required_reagents.map((reagent) => (
                <Stack.Item key={`${reaction.name}-${reagent.name}-req`}>
                  <ReactionComponentDisplay
                    reagentComponent={reagent}
                    setSearchTerm={props.setSearchTerm}
                    pinnedReactions={pinnedReactions}
                    setPinnedReactions={props.setPinnedReactions}
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
                        setSearchTerm={props.setSearchTerm}
                        pinnedReactions={pinnedReactions}
                        setPinnedReactions={props.setPinnedReactions}
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
                {getPHMessage(
                  reaction.reaction.lower_ph,
                  reaction.reaction.upper_ph,
                )}
              </Stack.Item>
            </Stack>
          </BlockQuote>
        </Collapsible>
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
  reagentComponent: ReactionComponent;
  setSearchTerm: (term: string) => void;
  pinnedReactions: ReactionTypepath[];
  setPinnedReactions: (reactions: ReactionTypepath[]) => void;
};

// linkifies a reagent name in the reaction display
// if it's a base reagent, it will dispense it when clicked
// if it's another recipe, it will put that recipe in the search box
// if it's nothing, it's not a button
const ReactionComponentDisplay = (props: ReactionComponentDisplayProps) => {
  const {
    reagentComponent,
    setSearchTerm,
    pinnedReactions,
    setPinnedReactions,
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
  const isRecipe = reactionReagentList
    .filter((reaction) => {
      return reaction.name === reagentComponent.name;
    })
    .find((reaction) => reaction.name === reagentComponent.name);

  if (isRecipe) {
    return (
      <Button
        icon="book"
        fluid
        ellipsis
        backgroundColor="default"
        onContextMenu={() => {
          // put recipe name in search box
          setSearchTerm(reagentComponent.name);
        }}
        onClick={() => {
          // pin recipe
          setPinnedReactions([...pinnedReactions, isRecipe.name]);
        }}
        selected={pinnedReactions.includes(isRecipe.name)}
        tooltip={
          <Stack vertical>
            <Stack.Item fontSize="0.9em">
              Left click to pin this recipe.
            </Stack.Item>
            <Stack.Item fontSize="0.9em">
              Right click to search for this recipe.
            </Stack.Item>
          </Stack>
        }
      >
        {formatReagentName(reagentComponent.amount, reagentComponent.name)}
      </Button>
    );
  }

  // otherwise, just display the name
  return (
    <Button fluid ellipsis disabled icon="question">
      {formatReagentName(reagentComponent.amount, reagentComponent.name)}
    </Button>
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
