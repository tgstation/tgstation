import { atom, useAtom } from 'jotai';
import { type ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Input,
  LabeledList,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

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
  reactions: Record<string, string> | [];
};

type GasSearchProps = {
  title: ReactNode;
  onChange: (inputValue: string) => void;
  activeInput: boolean;
  setActiveInput: (toggle: boolean) => void;
};

type Data = {
  gasInfo: Gas[];
  reactionInfo: Reaction[];
};

const activeGasAtom = atom('');
const activeReactionAtom = atom('');

function GasSearchBar(props: GasSearchProps) {
  const { title, onChange, activeInput, setActiveInput } = props;

  return (
    <Flex align="center">
      <Flex.Item grow>
        {activeInput ? (
          <Input
            fluid
            onBlur={(value) => {
              setActiveInput(false);
              onChange(value);
            }}
          />
        ) : (
          title
        )}
      </Flex.Item>
      <Flex.Item>
        <Button icon="search" onClick={() => setActiveInput(!activeInput)} />
      </Flex.Item>
    </Flex>
  );
}

function GasHandbook(props) {
  const { act, data } = useBackend<Data>();
  const { gasInfo } = data;
  const [activeGasId, setActiveGasId] = useAtom(activeGasAtom);
  const [activeReactionId, setActiveReactionId] = useAtom(activeReactionAtom);
  const [gasActiveInput, setGasActiveInput] = useState(false);
  const relevantGas = gasInfo.find((gas) => gas.id === activeGasId);

  return (
    <Section
      title={
        <GasSearchBar
          title={relevantGas ? `Gas: ${relevantGas.name}` : 'Gas Lookup'}
          onChange={(keyword) =>
            setActiveGasId(
              gasInfo.find((gas) =>
                gas.name.toLowerCase().startsWith(keyword.toLowerCase()),
              )?.id || '',
            )
          }
          activeInput={gasActiveInput}
          setActiveInput={setGasActiveInput}
        />
      }
    >
      {relevantGas && (
        <>
          <Box mb="0.5em">{relevantGas.description}</Box>
          <Box mb="0.5em">
            {`Specific heat: ${relevantGas.specific_heat} Joule/KelvinMol`}
          </Box>
          <Box mb="0.5em">{'Relevant Reactions:'}</Box>
          {Object.entries(relevantGas.reactions).map(
            ([reaction_id, reaction_name]) => (
              <Box key={reaction_id} mb="0.5em">
                <Button
                  onClick={() => setActiveReactionId(reaction_id)}
                  content={reaction_name}
                />
              </Box>
            ),
          )}
        </>
      )}
    </Section>
  );
}

function ReactionHandbook(props) {
  const { data } = useBackend<Data>();
  const { reactionInfo } = data;
  const [activeGasId, setActiveGasId] = useAtom(activeGasAtom);
  const [activeReactionId, setActiveReactionId] = useAtom(activeReactionAtom);
  const [reactionActiveInput, setReactionActiveInput] = useState(false);
  const relevantReaction = reactionInfo?.find(
    (reaction) => reaction.id === activeReactionId,
  );

  return (
    <Section
      title={
        <GasSearchBar
          title={
            relevantReaction
              ? `Reaction: ${relevantReaction.name}`
              : 'Reaction Lookup'
          }
          onChange={(keyword) =>
            setActiveReactionId(
              reactionInfo.find((reaction) =>
                reaction.name.toLowerCase().startsWith(keyword.toLowerCase()),
              )?.id || '',
            )
          }
          activeInput={reactionActiveInput}
          setActiveInput={setReactionActiveInput}
        />
      }
    >
      {relevantReaction && (
        <>
          <Box mb="0.5em">{relevantReaction.description}</Box>
          <Box mb="0.5em">{'Relevant Factors:'}</Box>
          <LabeledList>
            {relevantReaction.factors.map((factor) => (
              <LabeledList.Item
                key={`${relevantReaction.id}_${factor.factor_name}`}
                label={
                  factor.factor_type === 'gas' && factor.factor_id ? (
                    <Button
                      onClick={() => setActiveGasId(String(factor.factor_id))}
                      content={factor.factor_name}
                    />
                  ) : factor.tooltip ? (
                    <Tooltip content={factor.tooltip} position="top">
                      <Flex>
                        <Flex.Item
                          style={{ borderBottom: 'dotted 2px' }}
                          shrink
                        >
                          {`${factor.factor_name}:`}
                        </Flex.Item>
                      </Flex>
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
        </>
      )}
    </Section>
  );
}

type HandbookContentProps = {
  vertical?: boolean;
};

export function AtmosHandbookContent(props: HandbookContentProps) {
  return props.vertical ? (
    <>
      <GasHandbook />
      <ReactionHandbook />
    </>
  ) : (
    <Stack>
      <Stack.Item grow>
        <ReactionHandbook />
      </Stack.Item>
      <Stack.Item grow>
        <GasHandbook />
      </Stack.Item>
    </Stack>
  );
}

export function atmosHandbookHooks() {
  const [_activeGasId, setActiveGasId] = useAtom(activeGasAtom);
  const [_activeReactionId, setActiveReactionId] = useAtom(activeReactionAtom);

  return [setActiveGasId, setActiveReactionId];
}
