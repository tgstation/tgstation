import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Icon,
  Input,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  active_bets: ActiveBets[];
  bank_name: string;
  bank_money: number;
  can_create_bet: BooleanLike;
  max_title_length: number;
  max_description_length: number;
};

type ActiveBets = {
  name: string;
  description: string;
  owner: BooleanLike;
  creator: string;
  current_bets: CurrentBets[];
  locked: BooleanLike;
};

type CurrentBets = {
  option_name: string;
  total_amount: number;
  personally_invested: number;
};

export const NtosSpaceBetting = () => {
  const { act, data } = useBackend<Data>();
  const { bank_name, bank_money, can_create_bet } = data;
  return (
    <NtosWindow width={500} height={620}>
      <NtosWindow.Content scrollable>
        <Section title="User Information">
          <Stack>
            <Stack.Item mr={1.5}>
              <Icon
                name="id-card"
                size={3}
                mr={1}
                color={bank_name ? 'green' : 'red'}
              />
            </Stack.Item>
            <Stack fill vertical>
              <Stack.Item>Username: {bank_name}</Stack.Item>
              <Stack.Item>Money Available: {bank_money}cr</Stack.Item>
            </Stack>
          </Stack>
        </Section>
        <PollsSection />
        {!!can_create_bet && <BettingCreation />}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const PollsSection = () => {
  const { act, data } = useBackend<Data>();
  const { active_bets = [] } = data;
  const [Winner, set_winner] = useState('');
  return (
    <Section>
      {!active_bets.length ? (
        <Box>
          There&apos;s currently no active polls to bet on, create one below!
        </Box>
      ) : (
        active_bets.map(
          (
            { name, description, owner, creator, current_bets = [], locked },
            index,
          ) => (
            <Section title={name + ' - Created by ' + creator} key={name}>
              <Stack>
                <Stack.Item grow>
                  <Stack.Item grow>{description}</Stack.Item>
                  <Divider />
                  {current_bets.map(
                    (
                      { option_name, total_amount, personally_invested },
                      index,
                    ) => (
                      <Stack.Item
                        grow
                        key={option_name}
                        className="candystripe"
                        my={1.5}
                      >
                        <Stack.Item>
                          <Stack.Item my={1}>
                            {option_name} (Has {total_amount || 0}cr bet on it)
                            {!owner ? (
                              <NumberInput
                                value={personally_invested}
                                unit="cr"
                                width="15px"
                                disabled={!!locked}
                                minValue={0}
                                maxValue={10000}
                                step={1}
                                onChange={(value) =>
                                  act('place_bet', {
                                    bet_selected: name,
                                    option_selected: option_name,
                                    money_betting: value,
                                  })
                                }
                              />
                            ) : (
                              <Button.Checkbox
                                tooltip="Whether this answer won."
                                checked={Winner === option_name}
                                key={option_name}
                                onClick={() => set_winner(option_name)}
                              />
                            )}
                          </Stack.Item>
                        </Stack.Item>
                      </Stack.Item>
                    ),
                  )}
                  {!!owner &&
                    (!locked ? (
                      <Stack.Item>
                        <Button.Confirm
                          fluid
                          icon="minus"
                          tooltip="Lock the ability to place/retract bets. This is irreversible!"
                          onClick={() =>
                            act('lock_betting', { bet_selected: name })
                          }
                        >
                          Lock Betting
                        </Button.Confirm>
                      </Stack.Item>
                    ) : (
                      <Button.Confirm
                        fluid
                        icon="plus"
                        tooltip="Finalize results as the checked answer being the winner."
                        onClick={() =>
                          act('select_winner', {
                            bet_selected: name,
                            winning_answer: Winner,
                          })
                        }
                      >
                        Finalize Results
                      </Button.Confirm>
                    ))}
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    icon="minus"
                    disabled={locked}
                    tooltip="If you have any bets, this will remove them and refund the money."
                    onClick={() => act('cancel_bet', { bet_selected: name })}
                  >
                    Cancel Bet
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          ),
        )
      )}
    </Section>
  );
};

export const BettingCreation = () => {
  const { act, data } = useBackend<Data>();
  const { max_title_length, max_description_length } = data;
  const [Title, setTitle] = useState('');
  const [Desc, setDesc] = useState('');
  const [Option1, setOption1] = useState('');
  const [Option2, setOption2] = useState('');
  const [Option3, setOption3] = useState('');
  const [Option4, setOption4] = useState('');
  return (
    <Collapsible title="Bet Creation">
      <Stack fill vertical>
        <Stack.Item grow>
          <Input
            fluid
            placeholder="Title"
            maxLength={max_title_length}
            onInput={(event, value) => setTitle(value)}
          />
        </Stack.Item>
        <Stack.Item grow>
          <TextArea
            fluid
            placeholder="Description"
            height="100px"
            width="100%"
            maxLength={max_description_length}
            backgroundColor="black"
            textColor="white"
            onChange={(event, value) => setDesc(value)}
          />
        </Stack.Item>
        <Input
          fluid
          placeholder="Option 1"
          maxLength={max_title_length}
          onInput={(event, value) => setOption1(value)}
        />
        <Input
          fluid
          placeholder="Option 2"
          maxLength={max_title_length}
          onInput={(event, value) => setOption2(value)}
        />
        <Input
          fluid
          placeholder="Option 3 (Optional)"
          maxLength={max_title_length}
          onInput={(event, value) => setOption3(value)}
        />
        <Input
          fluid
          placeholder="Option 4 (Optional)"
          maxLength={max_title_length}
          onInput={(event, value) => setOption4(value)}
        />
        <Stack.Item grow>
          <Button
            fluid
            onClick={() =>
              act('create_bet', {
                title: Title,
                description: Desc,
                option1: Option1,
                option2: Option2,
                option3: Option3,
                option4: Option4,
              })
            }
          >
            Create Bet!
          </Button>
        </Stack.Item>
      </Stack>
    </Collapsible>
  );
};
