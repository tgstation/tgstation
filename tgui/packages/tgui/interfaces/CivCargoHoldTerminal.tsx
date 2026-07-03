
import {
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  Tooltip
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useState } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';


// Main window content.

type Data = {
  pad: string;
  sending: BooleanLike;
  status_report: string;
  picking: BooleanLike;

  id_inserted: BooleanLike;
  id_bounty_info: string;
  id_bounty_value: number;
  id_bounty_num: number;

  id_bounty_names: string[];
  id_bounty_infos: string[];
  id_bounty_values: number[];

  listBounty: singleBounty[];
  claimed_bounties: number;
};

type singleBounty = {
  name: string;
  description: string;
  reward: number;
  shipped: number;
  claimed: BooleanLike;
  maximum: number;
  priority: BooleanLike;
  unique: BooleanLike;
}


export const CivCargoHoldTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { id_inserted } = data;

  const in_text = 'Приветствуем, ценный сотрудник.';
  const out_text = 'Чтобы начать вставьте ID карту в консоль.';
  const [tab, setTab] = useState('personal');
  const listBounties = data.listBounty || [];

  return (
    <Window width={580} height={375}>
      <Window.Content scrollable>
        <Flex>
          <Flex.Item grow>
            <Section>

              <Tabs fluid>
                <Tabs.Tab
                  icon="user"
                  onClick={() => setTab('personal')}
                  selected={tab === 'personal'}
                  backgroundColor={tab === 'personal' ? "green" : "default"}
                >
                  Личные заказы
                </Tabs.Tab>
                <Tabs.Tab
                  icon="space-shuttle"
                  onClick={() => setTab('station')}
                  selected={tab === 'station'}
                  backgroundColor={tab === 'station' ? "brown" : "default"}
                >
                  Станционные заказы
                </Tabs.Tab>
              </Tabs>
            </Section>

            <NoticeBox color={!id_inserted ? 'default' : 'blue'}>
              {id_inserted ? in_text : out_text}
            </NoticeBox>

            {tab === 'personal' ?
              <PersonalBountyBlock />
            :
              <GlobalBountyBlock />
            }
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

// Block for the personal bounty information.
const PersonalBountyBlock = (props) => {
  const { act, data } = useBackend<Data>();
  const { pad, sending, status_report, id_inserted, id_bounty_info, picking } = data;
  return (
    <>
      <Section
        title="Платформа снабжения"
        buttons={
          <>
            <Button
              icon={'sync'}
              tooltip={'Проверить содержимое'}
              disabled={!pad || !id_inserted}
              onClick={() => act('recalc')} />
            <Button
              icon={sending ? 'times' : 'arrow-up'}
              tooltip={sending ? 'Остановить отправку' : 'Отправить товары'}
              selected={sending}
              disabled={!pad || !id_inserted}
              onClick={() => act(sending ? 'stop' : 'send')} />
            <Button
              icon={id_bounty_info ? 'recycle' : 'pen'}
              color={id_bounty_info ? 'green' : 'default'}
              tooltip={id_bounty_info ? 'Заменить заказ' : 'Новый заказ'}
              disabled={!id_inserted}
              onClick={() => act('bounty')} />
            <Button
              icon={'download'}
              content={'Извлечь ID карту'}
              disabled={!id_inserted}
              onClick={() => act('eject')} />
          </>}
        >
        <LabeledList>
          <LabeledList.Item label="Статус" color={pad ? 'good' : 'bad'}>
            {pad ? 'Функционирует' : 'Не обнаружен'}
          </LabeledList.Item>
          <LabeledList.Item label="Грузовой отчёт">
            {status_report}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      {picking ? <BountyPickBox /> : <BountyTextBox />}
    </>
  );
};


const BountyTextBox = (props) => {
  const { data } = useBackend<Data>();
  const { id_bounty_info, id_bounty_value, id_bounty_num } = data;
  const na_text = 'N/A, пожалуйста, возьмите новый заказ.';
  return (
    <Section title="Информация о заказе">
      <LabeledList>
        <LabeledList.Item label="Описание">
          {id_bounty_info ? id_bounty_info : na_text}
        </LabeledList.Item>
        <LabeledList.Item label="Количество">
          {id_bounty_info ? id_bounty_num : 'N/A'}
        </LabeledList.Item>
        <LabeledList.Item label="Стоимость">
          {id_bounty_info ? id_bounty_value : 'N/A'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};


const BountyPickBox = (props) => {
  const { act, data } = useBackend<Data>();
  const { id_bounty_names, id_bounty_infos, id_bounty_values } = data;
  return (
    <Section title="Пожалуйста выберите заказ:" textAlign="center">
      <Flex width="100%" wrap>
        <Flex.Item shrink={0} grow={0.5}>
          <BountyPickButton
            bounty_name={id_bounty_names[0]}
            bounty_info={id_bounty_infos[0]}
            bounty_value={id_bounty_values[0]}
            pick_value={1}
            act={act}
          />
        </Flex.Item>
        <Flex.Item shrink={0} grow={0.5} px={1}>
          <BountyPickButton
            bounty_name={id_bounty_names[1]}
            bounty_info={id_bounty_infos[1]}
            bounty_value={id_bounty_values[1]}
            pick_value={2}
            act={act}
          />
        </Flex.Item>
        <Flex.Item shrink={0} grow={0.5}>
          <BountyPickButton
            bounty_name={id_bounty_names[2]}
            bounty_info={id_bounty_infos[2]}
            bounty_value={id_bounty_values[2]}
            pick_value={3}
            act={act}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const BountyPickButton = (props) => {
  return (
    <Button
      fluid
      color="green"
      onClick={() => props.act('pick', { value: props.pick_value })}
      style={{
        display: 'flex',
        textWrap: 'wrap',
        whiteSpace: 'normal',
        paddingLeft: '0',
        paddingRight: '0',
      }}
    >
      <Box>{props.bounty_name}</Box>
      <Box
        textAlign="left"
        color="black"
        backgroundColor="linen"
        lineHeight="1.2em"
        p={1}
      >
        <Box dangerouslySetInnerHTML={{ __html: props.bounty_info }} />
      </Box>
      <Box>Оплата: {props.bounty_value} cr</Box>
    </Button>
  );
};

const GlobalBountyBlock = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    listBounty = [],
    sending,
    pad,
    id_inserted,
  } = data;

  const [localBounty, setBountyData] = useState<singleBounty>({
    name: 'n/a',
    description: '',
    reward: 0,
    shipped: 0,
    claimed: false,
    maximum: 0,
    priority: false,
    unique: false,
  });

  const [bountyTab, setBountyTab] = useState(0);

  const safeListBounty = Array.isArray(listBounty) ? listBounty : [];
  return (
    <Stack fill scrollable>
      <Stack.Item
        width="30%"
        >
        <Tabs
          vertical
          fluid
        >
          {safeListBounty.length < 1 ? (
            <Tabs.Tab
            onClick={() => { act('update_list'); setBountyTab(0); }}
            backgroundColor="blue"
            textColor="white"
            width="100%"
            bold
            icon="refresh"
          >
            Update List
          </Tabs.Tab>
          ) : (
            <Tabs.Tab
              textColor="#ffffffe5"
              align="center"
              >
              <Tooltip content="Общее количество глобальных заказов будет увеличиваться на 1 за каждые 3 выполненных заказа!">
                <Box className="Marquee">
                  Заказов выполнено: {data.claimed_bounties}.
                </Box>
              </Tooltip>
            </Tabs.Tab>
          )}

          <Tabs.Tab
            mt={0.5}
            onClick={() => act('print')}
            backgroundColor="#ffffff70"
            textColor="white"
            width="100%"
            bold
            icon="print"
          >
            Печать
          </Tabs.Tab>
          {safeListBounty.map((bounty) => (
            <Tabs.Tab
              key={bounty.name}
              pt={0.75}
              pb={0.75}
              mt={0.5}
              width="100%"
              backgroundColor={bounty.priority ? "#cec328a8" : (bounty.unique ? "#00fff270" : "#d1d1d170")}
              textColor="white"
              onClick={() => { setBountyData(bounty); setBountyTab(safeListBounty.indexOf(bounty)); }}
              className="Tab_Flash"
              bold={bountyTab === safeListBounty.indexOf(bounty)}
              icon={bounty.priority ? 'star' : (bounty.unique ? 'gem' : '')}
              selected={bountyTab === safeListBounty.indexOf(bounty)}
            >
              {bounty.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        {localBounty.reward !== 0 ? (
          <Section
            title={localBounty.name}
            style={{
              textWrap: 'wrap',
              whiteSpace: 'normal',
              paddingLeft: '0',
              paddingRight: '0',
            }}
            >
          <ProgressBar
            value={localBounty.shipped}
            maxValue={localBounty.maximum}
            p={1}
            >
          {localBounty.shipped} / {localBounty.maximum} отправлено.
          </ProgressBar>
              <Box
                dangerouslySetInnerHTML={{__html:localBounty.description }}
                p={1}
              />
              <br />
              <Box
                py={1.25}
                pl={2}
                my={0.75}
                style={{
                  borderRadius: '5px',
                  textDecoration: 'underline dotted',
                  textDecorationColor: '#ffffff8e',
                  textDecorationThickness: '2px',
                }}
                backgroundColor="green"
                color="white"
              >
                <Tooltip content={`Вы получите долю в ${Math.round(localBounty.reward * 0.3)}¢.`}>
                  <b>Награда:</b> {localBounty.reward}¢
                </Tooltip>
            </Box>
          <Button
            width="100%"
            icon={sending ? 'times' : 'arrow-up'}
            tooltip={sending ? 'Остановить отправку' : 'Отправить товары'}
            selected={sending}
            disabled={!pad || !id_inserted}
            onClick={() => { act(sending ? 'stop' : 'send', { global: true}); setBountyTab(0); }}
          >
            Отправка
          </Button>
        </Section>
        ) : (
          <NoticeBox
            width="100%">
            Пожалуйста, выберите заказ из списка.
          </NoticeBox>
        )}
      </Stack.Item>
    </Stack>
  )
}
