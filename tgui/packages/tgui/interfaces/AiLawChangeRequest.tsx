import { useState } from 'react';
import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  reviewing: boolean;
  laws: string[];
  notify_crew: boolean;
  max_law_length: number;
  law_amount: number;
  requester_key: string;
  requester_name: string;
};

export function AiLawChangeRequest() {
  const { act, data } = useBackend<Data>();
  const {
    reviewing,
    laws = [],
    notify_crew,
    max_law_length,
    law_amount,
    requester_key,
    requester_name,
  } = data;

  const initialLaws = Array.from(
    { length: law_amount },
    (_, index) => laws[index] ?? '',
  );
  const [lawInputs, setLawInputs] = useState<string[]>(initialLaws);

  const handleChange = (index: number, value: string) => {
    const updated = [...lawInputs];
    updated[index] = value;
    setLawInputs(updated);
  };

  return (
    <Window title="Запрос на смену законов" width={480} height={480}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item>
                {reviewing ? (
                  <NoticeBox mb={0}>
                    <Stack
                      style={{ fontWeight: 'normal', fontStyle: 'normal' }}
                    >
                      <Stack.Item grow>
                        <Box fontSize="16px" fontWeight="bold">
                          <a
                            href="#"
                            onClick={(event) => {
                              event.preventDefault();
                              act('pp');
                            }}
                          >
                            {requester_key}
                          </a>
                          /({requester_name})
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Button icon="code" onClick={() => act('vv')}>
                          VV
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button icon="message" onClick={() => act('pm')}>
                          PM
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button icon="ghost" onClick={() => act('flw')}>
                          FLW
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </NoticeBox>
                ) : (
                  <NoticeBox info mb={0}>
                    Ваш запрос будет проверен Центральным командованием. Просим
                    не нарушать рабочую этику и не использовать вульгарные,
                    нецензурные, расистские, ксенофобские, и иным образом
                    порочащие Корпорацию выражения.
                  </NoticeBox>
                )}
              </Stack.Item>
              <Stack.Item grow>
                <Section fill scrollable>
                  <Stack fill vertical g="5px">
                    {lawInputs.map((law, index) => (
                      <Stack.Item grow key={index}>
                        <TextArea
                          fluid
                          height="100%"
                          placeholder={`Закон ${index + 1}`}
                          value={law}
                          maxLength={max_law_length}
                          onChange={(value) => handleChange(index, value)}
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {!!reviewing && (
            <Stack.Item textAlign="center">
              <Button.Checkbox
                checked={notify_crew}
                onClick={() => act('toggle_notify')}
                fluid
                color="normal"
                lineHeight="2em"
              >
                Оповестить о смене законов
              </Button.Checkbox>
            </Stack.Item>
          )}
          <Stack.Item>
            {reviewing ? (
              <Stack fill>
                <Stack.Item grow>
                  <Button.Confirm
                    lineHeight="2em"
                    fluid
                    icon="check"
                    color="good"
                    textAlign="center"
                    onClick={() => act('confirm', { laws: lawInputs })}
                  >
                    ПОДТВЕРДИТЬ
                  </Button.Confirm>
                </Stack.Item>
                <Stack.Item grow>
                  <Button.Confirm
                    fluid
                    icon="ban"
                    color="bad"
                    textAlign="center"
                    onClick={() => act('reject')}
                    confirmContent="ОТКЛОНИТЬ?"
                    lineHeight="2em"
                  >
                    ОТКЛОНИТЬ
                  </Button.Confirm>
                </Stack.Item>
              </Stack>
            ) : (
              <Button.Confirm
                fluid
                icon="check"
                textAlign="center"
                onClick={() => act('submit', { laws: lawInputs })}
                style={{ fontSize: '20px' }}
                confirmContent="ОТПРАВИТЬ?"
              >
                ОТПРАВИТЬ
              </Button.Confirm>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
