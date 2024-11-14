import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
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
} from '../components';
import { FakeTerminal } from '../components/FakeTerminal';
import { NtosWindow } from '../layouts';

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
  "We've identified potentional high-value targets that are",
  'currently assigned to your mission area. They are believed',
  'to hold valuable information which could be of immediate',
  'importance to our organisation.',
  '',
  'Listed below are all of the contracts available to you. You',
  'are to bring the specified target to the designated',
  'drop-off, and contact us via this uplink. We will send',
  'a specialised extraction unit to put the body into.',
  '',
  'We want targets alive - but we will sometimes pay slight',
  "amounts if they're not, you just won't receive the shown",
  'bonus. You can redeem your payment through this uplink in',
  'the form of raw telecrystals, which can be put into your',
  'regular Syndicate uplink to purchase whatever you may need.',
  'We provide you with these crystals the moment you send the',
  'target up to us, which can be collected at anytime through',
  'this system.',
  '',
  'Targets extracted will be ransomed back to the station once',
  'their use to us is fulfilled, with us providing you a small',
  'percentage cut. You may want to be mindful of them',
  'identifying you when they come back. We provide you with',
  'a standard contractor loadout, which will help cover your',
  'identity.',
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
    'Recording biometric data...',
    'Analyzing embedded syndicate info...',
    'STATUS CONFIRMED',
    'Contacting syndicate database...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Response received, ack 4851234...',
    'CONFIRM ACC ' + Math.round(Math.random() * 20000),
    'Setting up private accounts...',
    'CONTRACTOR ACCOUNT CREATED',
    'Searching for available contracts...',
    'Searching for available contracts...',
    'Searching for available contracts...',
    'Searching for available contracts...',
    'CONTRACTS FOUND',
    'WELCOME, AGENT',
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
            REGISTER USER
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
          CONTINUE
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
          View Information Again
        </Button>
      }
      title="Contractor Status"
    >
      <Stack>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item
              label="TC Available"
              buttons={
                <Button
                  disabled={redeemable_tc <= 0}
                  onClick={() => act('PRG_redeem_TC')}
                >
                  Claim
                </Button>
              }
            >
              {String(redeemable_tc)}
            </LabeledList.Item>
            <LabeledList.Item label="TC Earned">
              {String(earned_tc)}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Contracts Completed">
              {String(contracts_completed)}
            </LabeledList.Item>
            <LabeledList.Item label="Current Status">ACTIVE</LabeledList.Item>
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
        title="Available Contracts"
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
            return;
          }
          const active = contract.status > CONTRACT.Inactive;
          if (contract.status >= CONTRACT.Complete) {
            return;
          }
          return (
            <Section
              key={contract.target}
              title={
                contract.target
                  ? `${contract.target} (${contract.target_rank})`
                  : 'Invalid Target'
              }
              buttons={
                <>
                  <Box inline bold mr={1}>
                    {`${contract.payout} (+${contract.payout_bonus}) TC`}
                  </Box>
                  <Button
                    disabled={!!contract.extraction_enroute}
                    color={active && 'bad'}
                    onClick={() =>
                      act('PRG_contract' + (active ? '_abort' : '-accept'), {
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
        title="Dropoff Locator"
        textAlign="center"
        opacity={ongoing_contract ? 100 : 0}
      >
        <Box bold>{dropoff_direction}</Box>
      </Section>
    </>
  );
}
