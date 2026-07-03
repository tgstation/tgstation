import { Box, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  help_text: string;
};

const DEFAULT_HELP = `Информация отсутствует! Обратитесь за помощью при нужде.`;

const boxHelp = [
  {
    color: 'purple',
    text: 'Изучите местность и принесите в убещиже ящик. Обращайте пристальное внимание на информацию о домене и на контекстные подсказки.',
    icon: 'search-location',
    title: 'Поиск',
  },
  {
    color: 'green',
    text: 'Принесите ящик к обозначенной зоне в вашем убежище. Место отправки будет выглядеть необычно для окружения. Осмотрите убежище, чтобы найти его.',
    icon: 'boxes',
    title: 'Ящик',
  },
  {
    color: 'blue',
    text: 'Лестница предоставляет самый безопасный способ выхода из домена, если ящик еще не вытащили. При разрыве соединения, ваш нетпод предоставляет ограниченную возможность к реанимации.',
    icon: 'plug',
    title: 'Отключение',
  },
  {
    color: 'yellow',
    text: 'Пока вы подключены, вы в какой-то мере защищены от опасностей окружащей среды и опасности извне, но не полностью. Обращайте внимания на оповещения и тревоги.',
    icon: 'id-badge',
    title: 'Безопасность',
  },
  {
    color: 'gold',
    text: 'Создание аватаров требует огромной пропускной способности. Не тратье их впустую.',
    icon: 'coins',
    title: 'Ограниченные попытки',
  },
  {
    color: 'red',
    text: 'Помните, что вы физически связаны с вашим аватаром. Вы - чужой во враждебном окружении. Оно попытается силой изгнать вас.',
    icon: 'skull-crossbones',
    title: 'Реальная опасность',
  },
] as const;

export const AvatarHelp = (props) => {
  const { data } = useBackend<Data>();
  const { help_text = DEFAULT_HELP } = data;

  return (
    <Window title="Информация о домене" width={600} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              color="good"
              fill
              scrollable
              title="Добро пожаловать в виртуальный домен."
            >
              {help_text}
            </Section>
          </Stack.Item>
          <Stack.Item grow={4}>
            <Stack fill vertical>
              <Stack.Item grow>
                <Stack fill>
                  {[0, 1].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  {[2, 3].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  {[4, 5].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// I wish I had media queries
const BoxHelp = (props: { index: number }) => {
  const { index } = props;

  return (
    <Stack.Item grow>
      <Section
        color="label"
        fill
        minHeight={10}
        title={
          <Stack align="center">
            <Icon
              color={boxHelp[index].color}
              mr={1}
              name={boxHelp[index].icon}
            />
            <Box>{boxHelp[index].title}</Box>
          </Stack>
        }
      >
        {boxHelp[index].text}
      </Section>
    </Stack.Item>
  );
};
