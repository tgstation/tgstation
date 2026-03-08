
import {
  BlockQuote,
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
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
}


export const CivCargoHoldTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const { id_inserted } = data;

  const in_text = 'Welcome valued employee.';
  const out_text = 'To begin, insert your ID into the console.';
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
                  Personal Bounties
                </Tabs.Tab>
                <Tabs.Tab
                  icon="space-shuttle"
                  onClick={() => setTab('station')}
                  selected={tab === 'station'}
                  backgroundColor={tab === 'station' ? "brown" : "default"}
                >
                  Station Bounties
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
        title="Cargo Pad"
        buttons={
          <>
            <Button
              icon={'sync'}
              tooltip={'Check Contents'}
              disabled={!pad || !id_inserted}
              onClick={() => act('recalc')} />
            <Button
              icon={sending ? 'times' : 'arrow-up'}
              tooltip={sending ? 'Stop Sending' : 'Send Goods'}
              selected={sending}
              disabled={!pad || !id_inserted}
              onClick={() => act(sending ? 'stop' : 'send')} />
            <Button
              icon={id_bounty_info ? 'recycle' : 'pen'}
              color={id_bounty_info ? 'green' : 'default'}
              tooltip={id_bounty_info ? 'Replace Bounty' : 'New Bounty'}
              disabled={!id_inserted}
              onClick={() => act('bounty')} />
            <Button
              icon={'download'}
              content={'Eject ID'}
              disabled={!id_inserted}
              onClick={() => act('eject')} />
          </>}
        >
        <LabeledList>
          <LabeledList.Item label="Status" color={pad ? 'good' : 'bad'}>
            {pad ? 'Online' : 'Not Found'}
          </LabeledList.Item>
          <LabeledList.Item label="Cargo Report">
            {status_report}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <>
        {picking ? <BountyPickBox /> : <BountyTextBox />}
      </>
    </>
  );
};


const BountyTextBox = (props) => {
  const { data } = useBackend<Data>();
  const { id_bounty_info, id_bounty_value, id_bounty_num } = data;
  const na_text = 'N/A, please add a new bounty.';
  return (
    <Section title="Bounty Info">
      <LabeledList>
        <LabeledList.Item label="Description">
          {id_bounty_info ? id_bounty_info : na_text}
        </LabeledList.Item>
        <LabeledList.Item label="Quantity">
          {id_bounty_info ? id_bounty_num : 'N/A'}
        </LabeledList.Item>
        <LabeledList.Item label="Value">
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
    <Section title="Please Select a Bounty:" textAlign="center">
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
        {props.bounty_info}
      </Box>
      <Box>Payout: {props.bounty_value} cr</Box>
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
  });

  const safeListBounty = Array.isArray(listBounty) ? listBounty : [];
  return (
    <>
    <Stack fill>
      <Stack.Item
        width="30%"
        >
        <Tabs
          vertical
          fluid
        >
          {safeListBounty.length < 1 ? (
            <Tabs.Tab
            onClick={() => act('update_list')}
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
              backgroundColor="#40638a70"
              textColor="#ffffffe5"
              align="center"
              >
              {data.claimed_bounties} bount{data.claimed_bounties === 1 ? "y" : "ies"} served{data.claimed_bounties > 0 ? "!" : "."}
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
            Printout List
          </Tabs.Tab>
          {safeListBounty.map((bounty) => (
            <Tabs.Tab
              key={bounty.name}
              pt={0.75}
              pb={0.75}
              mt={0.5}
              width="100%"
              backgroundColor={bounty.priority ? "#cec328a8" : "#d1d1d170"}
              textColor="white"
              onClick={() => setBountyData(bounty)}
              className="Tab_Flash"
              icon={bounty.priority ? 'star' : ''}
            >
              {bounty.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        {localBounty.reward !== 0 ? (
          <>
            <Section
              title={localBounty.name}
              >
          <ProgressBar
            value={localBounty.shipped}
            maxValue={localBounty.maximum}
            >
          {localBounty.shipped} / {localBounty.maximum} shipped.
          </ProgressBar>
          <BlockQuote
            my="5%"
            >
            {localBounty.description}
          </BlockQuote>
          <Button
            width="100%"
            icon={sending ? 'times' : 'arrow-up'}
            tooltip={sending ? 'Stop Sending' : 'Send Goods'}
            selected={sending}
            disabled={!pad || !id_inserted}
            onClick={() => act(sending ? 'stop' : 'send', { global: true})}
          >
            Send & Claim
          </Button>
        </Section>
        </>
        ) : (
          <>
            <NoticeBox
              width="100%">
              Please select a bounty from the list.
            </NoticeBox>
          </>
        )}
      </Stack.Item>
    </Stack>
    </>
  )
}
