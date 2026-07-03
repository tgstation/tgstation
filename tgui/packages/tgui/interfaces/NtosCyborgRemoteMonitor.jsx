import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { NtosWindow } from '../layouts';

export const NtosCyborgRemoteMonitor = (props) => {
  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content>
        <NtosCyborgRemoteMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const ProgressSwitch = (param) => {
  switch (param) {
    case -1:
      return '_';
    case 0:
      return 'Connecting';
    case 25:
      return 'Starting Transfer';
    case 50:
      return 'Downloading';
    case 75:
      return 'Downloading';
    case 100:
      return 'Formatting';
  }
};

export const NtosCyborgRemoteMonitorContent = (props) => {
  const { act, data } = useBackend();
  const [tab_main, setTab_main] = useSharedState('tab_main', 1);
  const { card, cyborgs = [], DL_progress } = data;
  const storedlog = data.borglog || [];

  if (!cyborgs.length) {
    return <NoticeBox>Юниты не обнаружены.</NoticeBox>;
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab
            icon="robot"
            lineHeight="23px"
            selected={tab_main === 1}
            onClick={() => setTab_main(1)}
          >
            Борги
          </Tabs.Tab>
          <Tabs.Tab
            icon="clipboard"
            lineHeight="23px"
            selected={tab_main === 2}
            onClick={() => setTab_main(2)}
          >
            Сохраненные логи борга
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      {tab_main === 1 && (
        <>
          {!card && (
            <Stack.Item>
              <NoticeBox>Некоторые функции требуют ввод ID-карты.</NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow={1}>
            <Section fill scrollable>
              {cyborgs.map((cyborg) => (
                <Section
                  key={cyborg.ref}
                  title={cyborg.name}
                  buttons={
                    <Button
                      icon="terminal"
                      content="Отправить сообщение"
                      color="blue"
                      disabled={!card}
                      onClick={() =>
                        act('messagebot', {
                          ref: cyborg.ref,
                        })
                      }
                    />
                  }
                >
                  <LabeledList>
                    <LabeledList.Item label="Статус">
                      <Box
                        color={
                          cyborg.status
                            ? 'bad'
                            : cyborg.locked_down
                              ? 'average'
                              : 'good'
                        }
                      >
                        {cyborg.status
                          ? 'Не отвечает'
                          : cyborg.locked_down
                            ? 'Заблокирован'
                            : cyborg.shell_discon
                              ? 'В норме/отключен'
                              : 'В норме'}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Состояние">
                      <Box
                        color={
                          cyborg.integ <= 25
                            ? 'bad'
                            : cyborg.integ <= 75
                              ? 'average'
                              : 'good'
                        }
                      >
                        {cyborg.integ === 0
                          ? 'Неисправен'
                          : cyborg.integ <= 25
                            ? 'Функциональность нарушена'
                            : cyborg.integ <= 75
                              ? 'Функциональность ограничена'
                              : 'Исправен'}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Заряд">
                      <Box
                        color={
                          cyborg.charge <= 30
                            ? 'bad'
                            : cyborg.charge <= 70
                              ? 'average'
                              : 'good'
                        }
                      >
                        {typeof cyborg.charge === 'number'
                          ? `${cyborg.charge}%`
                          : 'Не найдено'}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Модель">
                      {cyborg.module}
                    </LabeledList.Item>
                    <LabeledList.Item label="Улучшения">
                      {cyborg.upgrades}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              ))}
            </Section>
          </Stack.Item>
        </>
      )}
      {tab_main === 2 && (
        <>
          <Stack.Item>
            <Section>
              Сканируйте борга, чтобы загрузить сохраненные логи.
              <ProgressBar value={DL_progress / 100}>
                {ProgressSwitch(DL_progress)}
              </ProgressBar>
            </Section>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section fill scrollable backgroundColor="black">
              {storedlog.map((log) => (
                <Box mb={1} key={log} color="green">
                  {log}
                </Box>
              ))}
            </Section>
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};
