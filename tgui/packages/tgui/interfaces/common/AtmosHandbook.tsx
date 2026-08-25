import { atom, useAtom } from 'jotai';
import { type ReactNode, useState } from 'react';
import {
  Button,
  Flex,
  Input,
  LabeledList,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';
import { useBackend } from '../../backend';

/**
 * This describes something that influences a particular reaction
 * E.G.
 * factor_id = 'oxygen'
 * factor_id_type = 'gas'
 * factor_name = 'Oxygen
 * reaction_id = 'plasmafire'
 * desc = 'Influences the burn rate and consumption ratio.'
 */

type Factor = {
  factor_id?: string;
  factor_type: 'gas' | 'misc';
  factor_name: string;

  desc: string;
  tooltip?: string;
};

type Reaction = {
  id: string;
  name: string;
  description: string;
  factors: Factor[];
};

type Gas = {
  id: string;
  name: string;
  description: string;
  specific_heat: number;
  export_value: number;
  reactions: Record<string, string> | [];
};

type GasSearchProps = {
  title: ReactNode;
  placeholder?: string;
  inputText?: string;
  onEnter: (inputValue: string) => void;
  onChange: (inputValue: string) => void;
  activeInput: boolean;
  setActiveInput: (toggle: boolean) => void;
};

enum HandbookTab {
  Gases = 1,
  Reactions = 2,
}

type Data = {
  gasInfo: Gas[];
  reactionInfo: Reaction[];
  moneySymbol: string;
  moneyName: string;
};

const activeGasAtom = atom('');
const activeReactionAtom = atom('');

function GasSearchBar(props: GasSearchProps) {
  const {
    title,
    placeholder,
    inputText,
    onChange,
    onEnter,
    activeInput,
    setActiveInput,
  } = props;

  return (
    <Flex align="center">
      <Flex.Item grow>
        <Input
          fluid
          placeholder={placeholder}
          value={inputText}
          onBlur={(value) => {
            setActiveInput(false);
            onEnter(value);
          }}
          onChange={(value) => {
            onChange(value);
          }}
        />
      </Flex.Item>
      <Flex.Item>
        <Button icon="search" onClick={() => setActiveInput(!activeInput)} />
      </Flex.Item>
    </Flex>
  );
}

function getSpecificHeatColor(specificHeat: number) {
  if (specificHeat <= 10) {
    return 'red';
  } else if (specificHeat <= 20) {
    return 'orange';
  } else if (specificHeat <= 100) {
    return 'yellow';
  } else if (specificHeat <= 200) {
    return 'green';
  } else {
    return 'blue';
  }
}

function getExportValueColor(exportValue: number) {
  if (exportValue <= 0.2) {
    return 'red';
  } else if (exportValue <= 0.5) {
    return 'orange';
  } else if (exportValue <= 2.5) {
    return 'yellow';
  } else if (exportValue <= 5) {
    return 'green';
  } else {
    return 'blue';
  }
}

type GasHandbookProps = {
  setTab?: (tab: number) => void;
};

function GasHandbook(props: GasHandbookProps) {
  const { act, data } = useBackend<Data>();
  const { gasInfo, moneySymbol, moneyName } = data;
  const { setTab } = props;
  const [activeGasId, setActiveGasId] = useAtom(activeGasAtom);
  const [activeReactionId, setActiveReactionId] = useAtom(activeReactionAtom);
  const [gasActiveInput, setGasActiveInput] = useState(false);
  const relevantGas = gasInfo.find((gas) => gas.id === activeGasId);

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: gasInfo,
    matchStrategy: 'smart',
    getSearchString: (item) => item.name,
  });

  return (
    <Section
      fill
      title={
        <GasSearchBar
          title="Gas Lookup"
          inputText={query}
          onChange={(keyword) => setQuery(keyword)}
          onEnter={(keyword) => {
            const foundGas = gasInfo.find((gas) =>
              gas.name.toLowerCase().startsWith(keyword.toLowerCase()),
            );
            if (foundGas) {
              setActiveGasId(foundGas.id);
            }
          }}
          activeInput={gasActiveInput}
          setActiveInput={setGasActiveInput}
        />
      }
    >
      <Stack fill>
        <Stack.Item width="60%" mr="0.2em">
          <Stack vertical fill>
            {relevantGas ? (
              <>
                <Stack.Item fontSize="1.2em" bold>
                  &gt; {relevantGas.name}
                </Stack.Item>
                <Stack.Item mb="0.5em" italic>
                  {relevantGas.description}
                </Stack.Item>
                <Stack.Item mb="0.5em">
                  <Stack>
                    <Stack.Item
                      style={{ borderBottom: 'dotted 2px' }}
                      color="label"
                      shrink
                    >
                      <Tooltip
                        content={
                          <Stack vertical>
                            <Stack.Item>
                              The amount of energy required to raise the
                              temperature of one mole of gas by one Kelvin.
                            </Stack.Item>
                            <Stack.Item>
                              In simpler terms: The lower the specific heat of
                              the gas, the harder it will be to heat it up.
                            </Stack.Item>
                          </Stack>
                        }
                        position="top"
                      >
                        Specific Heat:
                      </Tooltip>
                    </Stack.Item>
                    <Stack.Item
                      color={getSpecificHeatColor(relevantGas.specific_heat)}
                    >{`${relevantGas.specific_heat}`}</Stack.Item>
                    <Stack.Item italic>J/(mol * K)</Stack.Item>
                  </Stack>
                </Stack.Item>
                {relevantGas.export_value > 0 && (
                  <Stack.Item mb="0.5em">
                    <Stack>
                      <Stack.Item
                        style={{ borderBottom: 'dotted 2px' }}
                        color="label"
                        shrink
                      >
                        <Tooltip
                          content={`The amount of ${moneyName} gained per mol of gas exported.`}
                          position="top"
                        >
                          Export Value:
                        </Tooltip>
                      </Stack.Item>
                      <Stack.Item
                        color={getExportValueColor(relevantGas.export_value)}
                      >{`${relevantGas.export_value}`}</Stack.Item>
                      <Stack.Item italic>{`${moneySymbol}/mol`}</Stack.Item>
                    </Stack>
                  </Stack.Item>
                )}
                {Object.entries(relevantGas.reactions).length > 0 && (
                  <Stack.Item mb="0.5em" grow>
                    <Section scrollable fill title="Relevant Reactions">
                      <Stack vertical>
                        {Object.entries(relevantGas.reactions)
                          .sort((a, b) => (a[1] > b[1] ? 1 : -1))
                          .map(([reaction_id, reaction_name]) => (
                            <Stack.Item key={reaction_id}>
                              <Button
                                fluid
                                ellipsis
                                onClick={() => {
                                  setActiveReactionId(reaction_id);
                                  setTab?.(HandbookTab.Reactions);
                                }}
                              >
                                {reaction_name}
                              </Button>
                            </Stack.Item>
                          ))}
                      </Stack>
                    </Section>
                  </Stack.Item>
                )}
              </>
            ) : (
              <Stack.Item
                fontSize="1.5rem"
                mt={2}
                align="center"
                textAlign="center"
                italic
                color="label"
              >
                No Gas Selected
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
        <Stack.Item grow ml="0.2em">
          <Section scrollable fill>
            <Stack vertical>
              {(query ? results : gasInfo)
                .sort((a, b) => (a.name > b.name ? 1 : -1))
                .map((gas) => (
                  <Stack.Item key={gas.id}>
                    <Button fluid onClick={() => setActiveGasId(gas.id)}>
                      {gas.name}
                    </Button>
                  </Stack.Item>
                ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type ReactionHandbookProps = {
  setTab?: (tab: number) => void;
};

function ReactionHandbook(props: ReactionHandbookProps) {
  const { data } = useBackend<Data>();
  const { reactionInfo } = data;
  const { setTab } = props;
  const [activeGasId, setActiveGasId] = useAtom(activeGasAtom);
  const [activeReactionId, setActiveReactionId] = useAtom(activeReactionAtom);
  const [reactionActiveInput, setReactionActiveInput] = useState(false);
  const relevantReaction = reactionInfo?.find(
    (reaction) => reaction.id === activeReactionId,
  );

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: reactionInfo,
    matchStrategy: 'smart',
    getSearchString: (item) => item.name,
  });

  return (
    <Section
      fill
      title={
        <GasSearchBar
          title="Reaction Lookup"
          onChange={(keyword) => setQuery(keyword)}
          onEnter={(keyword) => {
            const foundReaction = reactionInfo.find((reaction) =>
              reaction.name.toLowerCase().startsWith(keyword.toLowerCase()),
            );
            if (foundReaction) {
              setActiveReactionId(foundReaction.id);
            }
          }}
          inputText={query}
          activeInput={reactionActiveInput}
          setActiveInput={setReactionActiveInput}
        />
      }
    >
      <Stack fill>
        <Stack.Item width="60%" mr="0.2em">
          <Stack vertical fill>
            {relevantReaction ? (
              <>
                <Stack.Item fontSize="1.2em" bold>
                  &gt; {relevantReaction.name}
                </Stack.Item>
                <Stack.Item mb="0.5em" italic>
                  {relevantReaction.description}
                </Stack.Item>
                <Stack.Item mb="0.5em" grow>
                  <Section scrollable fill>
                    <LabeledList>
                      {relevantReaction.factors.map((factor) => (
                        <LabeledList.Item
                          key={`${relevantReaction.id}_${factor.factor_name}`}
                          label={
                            factor.factor_type === 'gas' && factor.factor_id ? (
                              <Button
                                onClick={() => {
                                  setActiveGasId(String(factor.factor_id));
                                  setTab?.(HandbookTab.Gases);
                                }}
                                fluid
                              >
                                {factor.factor_name}
                              </Button>
                            ) : factor.tooltip ? (
                              <Tooltip content={factor.tooltip} position="top">
                                <Stack>
                                  <Stack.Item
                                    style={{ borderBottom: 'dotted 2px' }}
                                    shrink
                                  >
                                    {`${factor.factor_name}:`}
                                  </Stack.Item>
                                </Stack>
                              </Tooltip>
                            ) : (
                              factor.factor_name
                            )
                          }
                        >
                          {factor.desc}
                        </LabeledList.Item>
                      ))}
                    </LabeledList>
                  </Section>
                </Stack.Item>
              </>
            ) : (
              <Stack.Item
                fontSize="1.5rem"
                mt={2}
                align="center"
                textAlign="center"
                italic
                color="label"
              >
                No reaction selected
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
        <Stack.Item grow ml="0.2em">
          <Section scrollable fill>
            <Stack vertical>
              {(query ? results : reactionInfo)
                .sort((a, b) => (a.name > b.name ? 1 : -1))
                .map((reaction) => (
                  <Stack.Item key={reaction.id}>
                    <Button
                      fluid
                      ellipsis
                      onClick={() => setActiveReactionId(reaction.id)}
                    >
                      {reaction.name}
                    </Button>
                  </Stack.Item>
                ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

export function AtmosHandbookContent() {
  const [tab, setTab] = useState(HandbookTab.Gases);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            selected={tab === HandbookTab.Gases}
            onClick={() => setTab(HandbookTab.Gases)}
          >
            Gases
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === HandbookTab.Reactions}
            onClick={() => setTab(HandbookTab.Reactions)}
          >
            Reactions
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        {tab === HandbookTab.Reactions ? (
          <ReactionHandbook setTab={setTab} />
        ) : (
          <GasHandbook setTab={setTab} />
        )}
      </Stack.Item>
    </Stack>
  );
}

export function atmosHandbookHooks() {
  const [_activeGasId, setActiveGasId] = useAtom(activeGasAtom);
  const [_activeReactionId, setActiveReactionId] = useAtom(activeReactionAtom);

  return [setActiveGasId, setActiveReactionId];
}
