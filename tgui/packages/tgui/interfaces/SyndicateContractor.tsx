import { BooleanLike } from 'common/react';
import { FakeTerminal } from '../components/FakeTerminal';
import { useBackend } from '../backend';
import { Box, Button, Flex, Grid, Icon, LabeledList, Modal, NoticeBox, Section } from '../components';
import { NtosWindow } from '../layouts';

const CONTRACT_STATUS_INACTIVE = 1;
const CONTRACT_STATUS_ACTIVE = 2;
const CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE = 3;
const CONTRACT_STATUS_EXTRACTING = 4;
const CONTRACT_STATUS_COMPLETE = 5;
const CONTRACT_STATUS_ABORTED = 6;

export const SyndicateContractor = (props, context) => {
  return (
    <NtosWindow width={500} height={600}>
      <NtosWindow.Content scrollable>
        <SyndicateContractorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type Data = {
  error: string;
  logged_in: BooleanLike;
  first_load: BooleanLike;
  info_screen: BooleanLike;
  redeemable_tc: Number;
  earned_tc: Number;
  contracts_completed: Number;
  contracts: ContractData[];
  ongoing_contract: BooleanLike;
  extraction_enroute: BooleanLike;
  dropoff_direction: string;
};

type ContractData = {
  id: Number;
  status: Number;
  target: string;
  target_rank: string;
  extraction_enroute: BooleanLike;
  message: string;
  contract: string;
  dropoff: string;
  payout: Number;
  payout_bonus: Number;
};

export const SyndicateContractorContent = (props, context) => {
  const { data, act } = useBackend<Data>(context);
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
  ];

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
    "amounts if they're not, you just won't recieve the shown",
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
  ];

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
          <Button content="Dismiss" onClick={() => act('PRG_clear_error')} />
        </Flex.Item>
      </Flex>
    </Modal>
  );

  if (!logged_in) {
    return (
      <Section minHeight="525px">
        <Box width="100%" textAlign="center">
          <Button
            content="REGISTER USER"
            color="transparent"
            onClick={() => act('PRG_login')}
          />
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
          content="CONTINUE"
          color="transparent"
          textAlign="center"
          onClick={() => act('PRG_toggle_info')}
        />
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
};

export const StatusPane = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { redeemable_tc, earned_tc, contracts_completed } = data;

  return (
    <Section
      title={
        <>
          Contractor Status
          <Button
            content="View Information Again"
            color="transparent"
            mb={0}
            ml={1}
            onClick={() => act('PRG_toggle_info')}
          />
        </>
      }>
      <Grid>
        <Grid.Column size={0.85}>
          <LabeledList>
            <LabeledList.Item
              label="TC Available"
              buttons={
                <Button
                  content="Claim"
                  disabled={redeemable_tc <= 0}
                  onClick={() => act('PRG_redeem_TC')}
                />
              }>
              {redeemable_tc}
            </LabeledList.Item>
            <LabeledList.Item label="TC Earned">{earned_tc}</LabeledList.Item>
          </LabeledList>
        </Grid.Column>
        <Grid.Column>
          <LabeledList>
            <LabeledList.Item label="Contracts Completed">
              {contracts_completed}
            </LabeledList.Item>
            <LabeledList.Item label="Current Status">ACTIVE</LabeledList.Item>
          </LabeledList>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const ContractsTab = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { contracts, ongoing_contract, extraction_enroute, dropoff_direction } =
    data;

  return (
    <>
      <Section
        title="Available Contracts"
        buttons={
          <Button
            content="Call Extraction"
            disabled={!ongoing_contract || extraction_enroute}
            onClick={() => act('PRG_call_extraction')}
          />
        }>
        {contracts.map((contract) => {
          if (ongoing_contract && contract.status !== CONTRACT_STATUS_ACTIVE) {
            return;
          }
          const active = contract.status > CONTRACT_STATUS_INACTIVE;
          if (contract.status >= CONTRACT_STATUS_COMPLETE) {
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
                    {contract.payout} (+{contract.payout_bonus}) TC
                  </Box>
                  <Button
                    content={active ? 'Abort' : 'Accept'}
                    disabled={contract.extraction_enroute}
                    color={active && 'bad'}
                    onClick={() =>
                      act('PRG_contract' + (active ? '_abort' : '-accept'), {
                        contract_id: contract.id,
                      })
                    }
                  />
                </>
              }>
              <Grid>
                <Grid.Column>{contract.message}</Grid.Column>
                <Grid.Column size={0.5}>
                  <Box bold mb={1}>
                    Dropoff Location:
                  </Box>
                  <Box>{contract.dropoff}</Box>
                </Grid.Column>
              </Grid>
            </Section>
          );
        })}
      </Section>
      <Section
        title="Dropoff Locator"
        textAlign="center"
        opacity={ongoing_contract ? 100 : 0}>
        <Box bold>{dropoff_direction}</Box>
      </Section>
    </>
  );
};
