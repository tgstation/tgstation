import { Component, Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Grid, Icon, LabeledList, Modal, NoticeBox, Section, Table, Tabs } from '../components';
import { NtosWindow } from '../layouts';

const CONTRACT_STATUS_INACTIVE = 1;
const CONTRACT_STATUS_ACTIVE = 2;
const CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE = 3;
const CONTRACT_STATUS_EXTRACTING = 4;
const CONTRACT_STATUS_COMPLETE = 5;
const CONTRACT_STATUS_ABORTED = 6;

export class FakeTerminal extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      currentIndex: 0,
      currentDisplay: [],
    };
  }

  tick() {
    const { props, state } = this;
    if (state.currentIndex <= props.allMessages.length) {
      this.setState(prevState => {
        return ({
          currentIndex: prevState.currentIndex + 1,
        });
      });
      const { currentDisplay } = state;
      currentDisplay.push(props.allMessages[state.currentIndex]);
    } else {
      clearTimeout(this.timer);
      setTimeout(props.onFinished, props.finishedTimeout);
    }
  }

  componentDidMount() {
    const {
      linesPerSecond = 2.5,
    } = this.props;
    this.timer = setInterval(() => this.tick(), 1000 / linesPerSecond);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    return (
      <Box m={1}>
        {this.state.currentDisplay.map(value => (
          <Fragment key={value}>
            {value}
            <br />
          </Fragment>
        ))}
      </Box>
    );
  }
}

export const SyndContractor = (props, context) => {
  return (
    <NtosWindow
      width={500}
      height={600}
      theme="syndicate"
      resizable>
      <NtosWindow.Content scrollable>
        <SyndContractorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const SyndContractorContent = (props, context) => {
  const { data, act } = useBackend(context);

  const terminalMessages = [
    "Recording biometric data...",
    "Analyzing embedded syndicate info...",
    "STATUS CONFIRMED",
    "Contacting syndicate database...",
    "Awaiting response...",
    "Awaiting response...",
    "Awaiting response...",
    "Awaiting response...",
    "Awaiting response...",
    "Awaiting response...",
    "Response received, ack 4851234...",
    "CONFIRM ACC " + (Math.round(Math.random() * 20000)),
    "Setting up private accounts...",
    "CONTRACTOR ACCOUNT CREATED",
    "Searching for available contracts...",
    "Searching for available contracts...",
    "Searching for available contracts...",
    "Searching for available contracts...",
    "CONTRACTS FOUND",
    "WELCOME, AGENT",
  ];

  const infoEntries = [
    "SyndTract v2.0",
    "",
    "We've identified potentional high-value targets that are",
    "currently assigned to your mission area. They are believed",
    "to hold valuable information which could be of immediate",
    "importance to our organisation.",
    "",
    "Listed below are all of the contracts available to you. You",
    "are to bring the specified target to the designated",
    "drop-off, and contact us via this uplink. We will send",
    "a specialised extraction unit to put the body into.",
    "",
    "We want targets alive - but we will sometimes pay slight",
    "amounts if they're not, you just won't recieve the shown",
    "bonus. You can redeem your payment through this uplink in",
    "the form of raw telecrystals, which can be put into your",
    "regular Syndicate uplink to purchase whatever you may need.",
    "We provide you with these crystals the moment you send the",
    "target up to us, which can be collected at anytime through",
    "this system.",
    "",
    "Targets extracted will be ransomed back to the station once",
    "their use to us is fulfilled, with us providing you a small",
    "percentage cut. You may want to be mindful of them",
    "identifying you when they come back. We provide you with",
    "a standard contractor loadout, which will help cover your",
    "identity.",
  ];

  const errorPane = !!data.error && (
    <Modal backgroundColor="red">
      <Flex align="center">
        <Flex.Item mr={2}>
          <Icon
            size={4}
            name="exclamation-triangle" />
        </Flex.Item>
        <Flex.Item
          mr={2}
          grow={1}
          textAlign="center">
          <Box
            width="260px"
            textAlign="left"
            minHeight="80px">
            {data.error}
          </Box>
          <Button
            content="Dismiss"
            onClick={() => act('PRG_clear_error')} />
        </Flex.Item>
      </Flex>
    </Modal>
  );

  if (!data.logged_in) {
    return (
      <Section minHeight="525px">
        <Box
          width="100%"
          textAlign="center">
          <Button
            content="REGISTER USER"
            color="transparent"
            onClick={() => act('PRG_login')} />
        </Box>
        {!!data.error && (
          <NoticeBox>
            {data.error}
          </NoticeBox>
        )}
      </Section>
    );
  }

  if (data.logged_in && data.first_load) {
    return (
      <Box
        backgroundColor="rgba(0, 0, 0, 0.8)"
        minHeight="525px">
        <FakeTerminal
          allMessages={terminalMessages}
          finishedTimeout={3000}
          onFinished={() => act('PRG_set_first_load_finished')} />
      </Box>
    );
  }

  if (data.info_screen) {
    return (
      <Fragment>
        <Box
          backgroundColor="rgba(0, 0, 0, 0.8)"
          minHeight="500px">
          <FakeTerminal
            allMessages={infoEntries}
            linesPerSecond={10} />
        </Box>
        <Button
          fluid
          content="CONTINUE"
          color="transparent"
          textAlign="center"
          onClick={() => act('PRG_toggle_info')} />
      </Fragment>
    );
  }

  return (
    <Fragment>
      {errorPane}
      <SyndPane />
    </Fragment>
  );
};

export const StatusPane = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section
      title={(
        <Fragment>
          Contractor Status
          <Button
            content="View Information Again"
            color="transparent"
            mb={0}
            ml={1}
            onClick={() => act('PRG_toggle_info')} />
        </Fragment>
      )}
      buttons={(
        <Box bold mr={1}>
          {data.contract_rep} Rep
        </Box>
      )}>
      <Grid>
        <Grid.Column size={0.85}>
          <LabeledList>
            <LabeledList.Item
              label="TC Availible"
              buttons={(
                <Button
                  content="Claim"
                  disabled={data.redeemable_tc <= 0}
                  onClick={() => act('PRG_redeem_TC')} />
              )}>
              {data.redeemable_tc}
            </LabeledList.Item>
            <LabeledList.Item label="TC Earned">
              {data.earned_tc}
            </LabeledList.Item>
          </LabeledList>
        </Grid.Column>
        <Grid.Column>
          <LabeledList>
            <LabeledList.Item label="Contracts Completed">
              {data.contracts_completed}
            </LabeledList.Item>
            <LabeledList.Item label="Current Status">
              ACTIVE
            </LabeledList.Item>
          </LabeledList>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

export const SyndPane = (props, context) => {
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  return (
    <Fragment>
      <StatusPane state={props.state} />
      <Tabs>
        <Tabs.Tab
          selected={tab === 1}
          onClick={() => setTab(1)}>
          Contracts
        </Tabs.Tab>
        <Tabs.Tab
          selected={tab === 2}
          onClick={() => setTab(2)}>
          Hub
        </Tabs.Tab>
      </Tabs>
      {tab === 1 && (
        <ContractsTab />
      )}
      {tab === 2 && (
        <HubTab />
      )}
    </Fragment>
  );
};

const ContractsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const contracts = data.contracts || [];
  return (
    <Fragment>
      <Section
        title="Availible Contracts"
        buttons={(
          <Button
            content="Call Extraction"
            disabled={!data.ongoing_contract || data.extraction_enroute}
            onClick={() => act('PRG_call_extraction')} />
        )}>
        {contracts.map(contract => {
          if (data.ongoing_contract
            && contract.status !== CONTRACT_STATUS_ACTIVE) {
            return;
          }
          const active = (contract.status > CONTRACT_STATUS_INACTIVE);
          if (contract.status >= CONTRACT_STATUS_COMPLETE) {
            return;
          }
          return (
            <Section
              key={contract.target}
              title={contract.target
                ? `${contract.target} (${contract.target_rank})`
                : "Invalid Target"}
              level={active ? 1 : 2}
              buttons={(
                <Fragment>
                  <Box
                    inline
                    bold
                    mr={1}>
                    {contract.payout} (+{contract.payout_bonus}) TC
                  </Box>
                  <Button
                    content={active ? "Abort" : "Accept"}
                    disabled={contract.extraction_enroute}
                    color={active && "bad"}
                    onClick={() => act(
                      'PRG_contract' + (active ? '_abort' : '-accept'),
                      {
                        contract_id: contract.id,
                      })} />
                </Fragment>
              )}>
              <Grid>
                <Grid.Column>
                  {contract.message}
                </Grid.Column>
                <Grid.Column size={0.5}>
                  <Box
                    bold
                    mb={1}>
                    Dropoff Location:
                  </Box>
                  <Box>
                    {contract.dropoff}
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          );
        })}
      </Section>
      <Section
        title="Dropoff Locator"
        textAlign="center"
        opacity={data.ongoing_contract ? 100 : 0}>
        <Box bold>
          {data.dropoff_direction}
        </Box>
      </Section>
    </Fragment>
  );
};

const HubTab = (props, context) => {
  const { act, data } = useBackend(context);
  const contractor_hub_items = data.contractor_hub_items || [];
  return (
    <Section>
      {contractor_hub_items.map(item => {
        const repInfo = item.cost ? (item.cost + ' Rep') : 'FREE';
        const limited = (item.limited !== -1);
        return (
          <Section
            key={item.name}
            title={item.name + ' - ' + repInfo}
            level={2}
            buttons={(
              <Fragment>
                {limited && (
                  <Box inline bold mr={1}>
                    {item.limited} remaining
                  </Box>
                )}
                <Button
                  content="Purchase"
                  disabled={data.contract_rep < item.cost
                    || (limited && item.limited <= 0)}
                  onClick={() => act('buy_hub', {
                    item: item.name,
                    cost: item.cost,
                  })} />
              </Fragment>
            )}>
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Icon
                    fontSize="60px"
                    name={item.item_icon} />
                </Table.Cell>
                <Table.Cell
                  verticalAlign="top">
                  {item.desc}
                </Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        );
      })}
    </Section>
  );
};
