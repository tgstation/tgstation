import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import { Image, LabeledList, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  already_chosen: BooleanLike;
  current_attempts: number;
  current_failures: number;
  chosen_icon: String;
  maximum_attempts: number;
  maximum_failures: number;
};

export const RideMinigame = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    already_chosen,
    current_attempts,
    current_failures,
    chosen_icon,
    maximum_attempts,
    maximum_failures,
  } = data;
  return (
    <Window title="Raptor Data" width={318} height={220}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Section textAlign="center">
              <Image
                src={`data:image/jpeg;base64,${chosen_icon}`}
                height="160px"
                width="160px"
                style={{
                  verticalAlign: 'middle',
                }}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Attempts Left">
                  {maximum_attempts - current_attempts}
                </LabeledList.Item>
                <LabeledList.Item label="Failures Left">
                  {maximum_failures - current_failures}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section>
              <Stack vertical>
                <Stack.Item textAlign="center">
                  <Button
                    style={{ padding: '3px' }}
                    icon="arrow-up"
                    width="30px"
                    onClick={() =>
                      act('submit_answer', {
                        picked_answer: 'north',
                      })
                    }
                  ></Button>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <Button
                        style={{ padding: '3px' }}
                        icon="arrow-left"
                        width="30px"
                        onClick={() =>
                          act('submit_answer', {
                            picked_answer: 'west',
                          })
                        }
                      ></Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        style={{ padding: '3px' }}
                        icon="arrow-right"
                        width="30px"
                        onClick={() =>
                          act('submit_answer', {
                            picked_answer: 'east',
                          })
                        }
                      ></Button>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item textAlign="center">
                  <Button
                    style={{ padding: '3px' }}
                    width="30px"
                    icon="arrow-down"
                    onClick={() =>
                      act('submit_answer', {
                        picked_answer: 'south',
                      })
                    }
                  ></Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
