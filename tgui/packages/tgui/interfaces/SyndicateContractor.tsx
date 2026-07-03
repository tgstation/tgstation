import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { FakeTerminal } from './common/FakeTerminal';

enum CONTRACT {
  Inactive = 1,
  Active = 2,
  Complete = 5,
}

type Data = {
  contracts_completed: number;
  contracts: ContractData[];
  dropoff_direction: string;
  earned_tc: number;
  error: string;
  extraction_enroute: BooleanLike;
  first_load: BooleanLike;
  info_screen: BooleanLike;
  logged_in: BooleanLike;
  ongoing_contract: BooleanLike;
  redeemable_tc: number;
};

type ContractData = {
  contract: string;
  dropoff: string;
  extraction_enroute: BooleanLike;
  id: number;
  message: string;
  payout_bonus: number;
  payout: number;
  status: number;
  target_rank: string;
  target: string;
};

const infoEntries = [
  'SyndTract v2.0',
  '',
  'Мы определили потенциально ценные цели, которые',
  'в настоящее время находятся в районе вашей миссии. Они могут',
  'хранить ценную информацию, которая может иметь важное',
  'значение для нашей организации.',
  '',
  'Ниже перечислены все доступные вам контракты. Вы',
  'должны довести заданную цель до назначенной',
  'зоны отправки, и связаться с нами через аплинк. Мы отправим',
  'специализированную капсулу для транспортировки, куда нужно поместить тело.',
  '',
  'Мы хотим, чтобы цели были живыми; мы платим меньшие',
  'суммы если цель будет мертва, так как вы просто не получите указанный',
  'бонус. Вы можете получить свою оплату через этот аплинк в',
  'форме телекристаллов, которые могут быть вложены в',
  'обычный аплинк Синдиката для приобретения необходимого вам снаряжения.',
  'Мы предоставим вам эти кристаллы в тот момент, когда вы отправите',
  'цель к нам, телекристаллы можно получить в любое время через',
  'эту систему.',
  '',
  'Похищенные цели будут выкуплены обратно на станцию после того,',
  'как их знания будут извлечены, и вам будет предоставлена',
  'часть выкупа. Вам следует помнить, что они могут',
  'идентифицировать вас, когда они вернутся. Мы предоставляем вам',
  'стандартное снаряжение контрактника, которое поможет скрыть вашу',
  'личность.',
] as const;

export function SyndicateContractor(props) {
  return (
    <NtosWindow width={500} height={600}>
      <NtosWindow.Content scrollable>
        <SyndicateContractorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
}

function SyndicateContractorContent(props) {
  const { data, act } = useBackend<Data>();
  const { error, logged_in, first_load, info_screen } = data;

  const terminalMessages = [
    'Запись биометрических данных...',
    'Анализ встроенной информации о синдикате...',
    'СТАТУС ПОДТВЕРЖДЕН',
    'Обращение к базе данных синдиката...',
    'Ожидание ответа...',
    'Ожидание ответа...',
    'Ожидание ответа...',
    'Ожидание ответа...',
    'Ожидание ответа...',
    'Ожидание ответа...',
    'Ответ получен, аккаунт 4851234...',
    `ПОДТВЕРДИТЬ АККАУНТ ${Math.round(Math.random() * 20000)}`,
    'Настройка личных аккаунтов...',
    'АККАУНТ КОНТРАКТНИКА СОЗДАН',
    'Поиск доступных контрактов...',
    'Поиск доступных контрактов...',
    'Поиск доступных контрактов...',
    'Поиск доступных контрактов...',
    'КОНТРАКТЫ НАЙДЕНЫ',
    'ДОБРО ПОЖАЛОВАТЬ, АГЕНТ',
  ] as const;

  const errorPane = !!error && (
    <Modal backgroundColor="red">
      <Flex align="center">
        <Flex.Item mr={2}>
          <Icon size={4} name="exclamation-triangle" />
        </Flex.Item>
        <Flex.Item mr={2} grow={1} textAlign="center">
          <Box width="260px" textAlign="left" minHeight="80px">
            {error}
          </Box>
          <Button onClick={() => act('PRG_clear_error')}>Dismiss</Button>
        </Flex.Item>
      </Flex>
    </Modal>
  );

  if (!logged_in) {
    return (
      <Section minHeight="525px">
        <Box width="100%" textAlign="center">
          <Button color="transparent" onClick={() => act('PRG_login')}>
            ЗАРЕГИСТРИРОВАННЫЙ ПОЛЬЗОВАТЕЛЬ
          </Button>
        </Box>
        {!!error && <NoticeBox>{error}</NoticeBox>}
      </Section>
    );
  }

  if (logged_in && first_load) {
    return (
      <Box backgroundColor="rgba(0, 0, 0, 0.8)" minHeight="525px">
        <FakeTerminal
          allMessages={terminalMessages}
          finishedTimeout={3000}
          onFinished={() => act('PRG_set_first_load_finished')}
        />
      </Box>
    );
  }

  if (info_screen) {
    return (
      <>
        <Box backgroundColor="rgba(0, 0, 0, 0.8)" minHeight="500px">
          <FakeTerminal allMessages={infoEntries} linesPerSecond={10} />
        </Box>
        <Button
          fluid
          color="transparent"
          textAlign="center"
          onClick={() => act('PRG_toggle_info')}
        >
          ПРОДОЛЖИТЬ
        </Button>
      </>
    );
  }

  return (
    <>
      {errorPane}
      <StatusPane state={props.state} />
      <ContractsTab />
    </>
  );
}

function StatusPane(props) {
  const { act, data } = useBackend<Data>();
  const { redeemable_tc, earned_tc, contracts_completed } = data;

  return (
    <Section
      buttons={
        <Button
          color="transparent"
          mb={0}
          ml={1}
          onClick={() => act('PRG_toggle_info')}
        >
          Посмотреть информацию еще раз
        </Button>
      }
      title="Статус контрактника"
    >
      <Stack>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item
              label="Доступные ТК"
              buttons={
                <Button
                  disabled={redeemable_tc <= 0}
                  onClick={() => act('PRG_redeem_TC')}
                >
                  Забрать
                </Button>
              }
            >
              {String(redeemable_tc)}
            </LabeledList.Item>
            <LabeledList.Item label="Заработанные ТК">
              {String(earned_tc)}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Выполненные контракты">
              {String(contracts_completed)}
            </LabeledList.Item>
            <LabeledList.Item label="Текущий статус">АКТИВНЫЙ</LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function ContractsTab(props) {
  const { act, data } = useBackend<Data>();
  const {
    contracts = [],
    ongoing_contract,
    extraction_enroute,
    dropoff_direction,
  } = data;

  return (
    <>
      <Section
        title="Доступные контракты"
        buttons={
          <Button
            disabled={!ongoing_contract || !!extraction_enroute}
            onClick={() => act('PRG_call_extraction')}
          >
            Call Extraction
          </Button>
        }
      >
        {contracts.map((contract) => {
          if (ongoing_contract && contract.status !== CONTRACT.Active) {
            return null;
          }
          const active = contract.status > CONTRACT.Inactive;
          if (contract.status >= CONTRACT.Complete) {
            return null;
          }
          return (
            <Section
              key={contract.target}
              title={
                contract.target
                  ? `${contract.target} (${contract.target_rank})`
                  : 'Неверная цель'
              }
              buttons={
                <>
                  <Box inline bold mr={1}>
                    {`${contract.payout} (+${contract.payout_bonus}) ТК`}
                  </Box>
                  <Button
                    disabled={!!contract.extraction_enroute}
                    color={active && 'bad'}
                    onClick={() =>
                      act(`PRG_contract${active ? '_abort' : '-accept'}`, {
                        contract_id: contract.id,
                      })
                    }
                  >
                    {active ? 'Abort' : 'Accept'}
                  </Button>
                </>
              }
            >
              <Stack>
                <Stack.Item grow>{contract.message}</Stack.Item>
                <Stack.Item>
                  <Box bold mb={1}>
                    Dropoff Location:
                  </Box>
                  <Box>{contract.dropoff}</Box>
                </Stack.Item>
              </Stack>
            </Section>
          );
        })}
      </Section>
      <Section
        title="Локатор зоны отправки"
        textAlign="center"
        opacity={ongoing_contract ? 100 : 0}
      >
        <Box bold>{dropoff_direction}</Box>
      </Section>
    </>
  );
}
