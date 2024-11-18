import { useEffect, useState } from 'react';
import {
  Button,
  Image,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { randomPick } from 'tgui-core/random';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  current_attempts: number;
  current_failures: number;
  all_icons: Icon_Data[];
  maximum_attempts: number;
  maximum_failures: number;
};

type Icon_Data = {
  direction: String;
  icon: String;
};

export const RideMinigame = (props) => {
  const { act, data } = useBackend<Data>();
  const { all_icons, maximum_attempts, maximum_failures } = data;
  const [CurrIcon, setCurrIcon] = useState(randomPick(all_icons));
  const [CurrDisabled, setCurrDisabled] = useState(false);
  const [ChosenAnswer, setChosenAnswer] = useState('');
  const [CurrentFailures, setCurrentFailures] = useState(0);
  const [CurrentAttempts, setCurrentAttempts] = useState(0);

  const UpdateAnswer = (Answer: string) => {
    setChosenAnswer(Answer);
    setCurrDisabled(true);
  };
  useEffect(() => {
    const intervalId = setInterval(() => {
      if (CurrentFailures >= maximum_failures) {
        act('lose_game');
        return;
      }
      if (CurrentAttempts >= maximum_attempts) {
        act('win_game');
        return;
      }
      setCurrentAttempts(CurrentAttempts + 1);
      if (CurrIcon.direction !== ChosenAnswer) {
        setCurrentFailures(CurrentFailures + 1);
      }
      const ListToPickFrom = all_icons.filter((icon) => icon !== CurrIcon);
      setCurrIcon(randomPick(ListToPickFrom));
      setChosenAnswer('');
      setCurrDisabled(false);
    }, 1000);
    return () => clearInterval(intervalId);
  }, [CurrIcon, ChosenAnswer, CurrDisabled]);
  return (
    <Window title="Click the opposite direction!" width={318} height={220}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Section textAlign="center">
              <Image
                src={`data:image/jpeg;base64,${CurrIcon.icon}`}
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
                  {maximum_attempts - CurrentAttempts}
                </LabeledList.Item>
                <LabeledList.Item label="Failures Left">
                  {maximum_failures - CurrentFailures}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section>
              <Stack vertical>
                <Stack.Item textAlign="center">
                  <Button
                    disabled={CurrDisabled}
                    style={{ padding: '3px' }}
                    icon="arrow-up"
                    width="30px"
                    onClick={() => UpdateAnswer('north')}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <Button
                        disabled={CurrDisabled}
                        style={{ padding: '3px' }}
                        icon="arrow-left"
                        width="30px"
                        onClick={() => UpdateAnswer('west')}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        disabled={CurrDisabled}
                        style={{ padding: '3px' }}
                        icon="arrow-right"
                        width="30px"
                        onClick={() => UpdateAnswer('east')}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item textAlign="center">
                  <Button
                    disabled={CurrDisabled}
                    style={{ padding: '3px' }}
                    width="30px"
                    icon="arrow-down"
                    onClick={() => UpdateAnswer('south')}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
