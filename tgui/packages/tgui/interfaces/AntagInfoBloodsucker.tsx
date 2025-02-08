import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Image,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
};

type BloodsuckerInformation = {
  clan: ClanInfo[];
  in_clan: BooleanLike;
  power: PowerInfo[];
};

type ClanInfo = {
  clan_name: string;
  clan_description: string;
  clan_icon: string;
};

type PowerInfo = {
  power_name: string;
  power_explanation: string;
  power_icon: string;
};

type Info = {
  objectives: Objective[];
};

const ObjectivePrintout = (props: any) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Ваши текущие задачи:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoBloodsucker = (props: any) => {
  const [tab, setTab] = useState(1);
  return (
    <Window width={620} height={580} theme="spookyconsole">
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}
          >
            О вас
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}
          >
            Кланы и Способности
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <BloodsuckerIntro />}
        {tab === 2 && <BloodsuckerClan />}
      </Window.Content>
    </Window>
  );
};

const BloodsuckerIntro = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="16rem">
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              Вы кровсос, нежить живущая борту Космической Станции 13
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Силы и Слабости">
          <Stack vertical>
            <Stack.Item>
              <span>
                Вы медленно регенирируете своё здоровьё, ты слаб к огню, и
                должен пить кровь для того чтобы выжить. Не позволяйте своей
                крови закончиться, либо вы войдёте в
              </span>
              <span className={'color-red'}> состояние Безумия</span>!<br />
              <span>
                Будьте осторожны за свой уровень человечности! Чем больше вы
                теряете человечности, тем легче вам войти в{' '}
                <span className={'color-red'}> состояние Безумиия</span>!
              </span>
              <br />
              <span>
                Избегайте питья крови находясь рядом с другими людьми, либо у
                вас появится риск <i>ломания Маскарада</i>!
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Особености">
          <Stack vertical>
            <Stack.Item>
              Ложитесь в <b>гроб</b> чтобы завладеть им, и эта местность будет
              как ваше логово.
              <br />
              Осматривайте ваши новые структуры чтобы узнать их функции!
              <br />
              Медицинские и генетические сканнеры могут сдать вас, Способность
              Маскарад Скроет вашу натуру чтобы предотвратить это.
              <br />
            </Stack.Item>
            <Stack.Item>
              <Section textAlign="center" textColor="red" fontSize="20px">
                Другие кровососы не обязательно ваши друзья, но ваши выживание
                может зависеть от сотрудничества. Предай их сам по своему
                желанию осмотрительность и опасность.
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const BloodsuckerClan = (props: any) => {
  const { act, data } = useBackend<BloodsuckerInformation>();
  const { clan, in_clan } = data;

  if (!in_clan) {
    return (
      <Section minHeight="220px">
        <Box mt={5} bold textAlign="center" fontSize="40px">
          Вы не в клане.
        </Box>
        <Box mt={3}>
          <Button
            fluid
            icon="users"
            content="Вход в клан"
            textAlign="center"
            fontSize="30px"
            lineHeight={2}
            onClick={() => act('join_clan')}
          />
        </Box>
      </Section>
    );
  }

  return (
    <Stack vertical fill>
      <Stack.Item minHeight="20rem">
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item>
              {clan.map((ClanInfo) => (
                <>
                  <Image
                    height="20rem"
                    opacity={0.25}
                    src={resolveAsset(`bloodsucker.${ClanInfo.clan_icon}.png`)}
                    style={{
                      position: 'absolute',
                    }}
                  />
                  <Stack.Item fontSize="20px" textAlign="center">
                    Вы часть {ClanInfo.clan_name}
                  </Stack.Item>
                  <Stack.Item fontSize="16px">
                    {ClanInfo.clan_description}
                  </Stack.Item>
                </>
              ))}
            </Stack.Item>
          </Stack>
        </Section>
        <PowerSection />
      </Stack.Item>
    </Stack>
  );
};

const PowerSection = (props: any) => {
  const { act, data } = useBackend<BloodsuckerInformation>();
  const { power } = data;
  if (!power) {
    return <Section minHeight="220px" />;
  }

  const [selectedPower, setSelectedPower] = useState(power[0]);

  return (
    <Section
      fill
      scrollable={!!power}
      title="Силы"
      buttons={
        <Button
          icon="info"
          tooltipPosition="left"
          tooltip={
            'Выберите силу используя меню для получения подробного объяснения.'
          }
        />
      }
    >
      <Stack>
        <Stack.Item grow>
          <Dropdown
            displayText={selectedPower.power_name}
            selected={selectedPower.power_name}
            width="100%"
            options={power.map((powers) => powers.power_name)}
            onSelected={(powerName: string) =>
              setSelectedPower(
                power.find((p) => p.power_name === powerName) || power[0],
              )
            }
          />
          {selectedPower && (
            <Image
              position="absolute"
              height="12rem"
              src={resolveAsset(`bloodsucker.${selectedPower.power_icon}.png`)}
            />
          )}
          <Divider />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow={1} fontSize="16px">
          {selectedPower && selectedPower.power_explanation}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
