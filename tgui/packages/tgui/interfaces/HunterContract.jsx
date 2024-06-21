import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Icon } from '../components';
import { Window } from '../layouts';

const HunterObjectives = (props) => {
  const { act, data } = useBackend();
  const { objectives = [], all_completed, rabbits_found, used_up } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section fill title="Objectives">
          {objectives.map((objective) => (
            <Box key={objective.explanation}>
              <Stack align="baseline">
                <Stack.Item grow bold>
                  {objective.explanation}
                </Stack.Item>
              </Stack>
              <Icon
                name={objective.completed ? 'check' : 'times'}
                color={objective.completed ? 'good' : 'bad'}
              />
            </Box>
          ))}
          <Box>
            <Button
              fluid
              textAlign="center"
              align="center"
              width={50}
              content={'Commence Apocalypse'}
              fontSize="200%"
              disabled={!all_completed || !rabbits_found || used_up}
              onClick={() => act('claim_reward')}
            />
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const HunterContract = (props) => {
  const { act, data } = useBackend();
  const { items = [], bought, number_of_rabbits } = data;
  return (
    <Window width={670} height={400} theme="spookyconsole">
      <Window.Content scrollable>
        <Section title="Hunter's Contract" />
        {
          <Stack vertical fill>
            <Stack.Item fontSize="20px" textAlign="center">
              Pick your Hunter tool
            </Stack.Item>
            <Stack.Item grow>
              {items.map((item) => (
                <Box key={item.name} className="candystripe" p={1} pb={2}>
                  <Stack align="baseline">
                    <Stack.Item grow bold>
                      {item.name}
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        content="Claim"
                        disabled={bought}
                        onClick={() =>
                          act('select', {
                            item: item.id,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                  {item.desc}
                </Box>
              ))}
            </Stack.Item>
            <Stack.Item>
              <Section fill title="Hunter's Guide">
                <Stack vertical fill>
                  <Stack.Item>
                    <span>
                      Look for the white rabbits! Use their eyes to upgrade your
                      hunter&#39;s weapon, the red queen&#39;s card will guide
                      you!{' '}
                      <span className={'color-red'}>
                        {' '}
                        YOU HAVE FOUND {number_of_rabbits}{' '}
                        {number_of_rabbits === 1 ? 'RABBIT' : 'RABBITS'}{' '}
                      </span>
                      Only once the contract is fullfilled and the rabbits are
                      found will you be able to bring upon the
                      <span className={'color-red'}> APOCALYPSE </span>!
                    </span>
                    <br />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Box>
                <HunterObjectives />
              </Box>
            </Stack.Item>
          </Stack>
        }
      </Window.Content>
    </Window>
  );
};
