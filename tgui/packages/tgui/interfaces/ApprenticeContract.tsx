import {
  BlockQuote,
  Box,
  Button,
  Icon,
  Section,
  Stack,
} from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ApprenticeContract = (props) => {
  return (
    <Window width={620} height={600} theme="wizard">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section textColor="lightgreen" fontSize="15px">
              Если вы не можете связаться с кем-то из своих учеников сегодня, вы
              можете сунуть контракт обратно в книгу заклинаний, чтобы
              возместить его стоимость.
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <ApprenticeSelection
              iconName="fire"
              fluffName="Ученик Разрушения"
              schoolTitle="destruction"
              assetName="destruction.png"
              blurb={`
                Ваш ученик владеет наступательной магией.
                Они владеют «Magic Missile» и «Fireball».
              `}
            />
            <ApprenticeSelection
              iconName="route"
              fluffName="Студент Транслокации"
              schoolTitle="bluespace"
              assetName="bluespace.png"
              blurb={`
              Ваш ученик способен бросить вызов физике, проникая
              сквозь твердые предметы и преодолевая огромные
              расстояния в мгновение ока. Они владеют «Teleport» и «Ethereal Jaunt».
              `}
            />
            <ApprenticeSelection
              iconName="medkit"
              fluffName="Неофит Восстановления"
              schoolTitle="healing"
              assetName="healing.png"
              blurb={`
              Ваш ученик обучается заклинаниям, которые
              помогут вам в выживании. Они знают «Forcewall» и «Charge» и
              имеют при себе Посох исцеления.
              `}
            />
            <ApprenticeSelection
              iconName="user-secret"
              fluffName="Безробный Ученик"
              schoolTitle="robeless"
              assetName="robeless.png"
              blurb={`
              Ваш ученик учится применять заклинания
              без одеяний. Они владеют «Knock» и «Mindswap».
              `}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ApprenticeSelection = (props) => {
  const { act } = useBackend();
  const { iconName, fluffName, schoolTitle, assetName, blurb } = props;
  return (
    <Section>
      <Stack align="middle" fill>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <img
                src={resolveAsset(assetName)}
                style={{
                  borderStyle: 'solid',
                  borderColor: '#7e90a7',
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                textAlign="center"
                fluid
                onClick={() =>
                  act('buy', {
                    school: schoolTitle,
                  })
                }
              >
                Выбрать
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <Box fontSize="20px" height="30%">
            <Icon name={iconName} /> {fluffName}
          </Box>
          <BlockQuote height="70%" fontSize="16px">
            {blurb}
          </BlockQuote>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
