import { toArray } from 'common/collections';
import { Fragment } from 'inferno';
import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, LabeledList, Section, Table, Tabs, Grid } from '../components';
import { formatMoney } from '../format';
import { NtosWindow } from '../layouts';

export const NtosBountyConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'catalog');
  const {
    bountydata = [],
    stored_cash,
  } = data;
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <Section
          title={<BountyHeader />}
          buttons={(
            <Button
              icon="print"
              content="Print Bounty List"
              onClick={() => act('Print')} />
          )}>
          <Table border>
            <Table.Row 
              bold 
              italic 
              color="label"
              fontSize={1.25}>
              <Table.Cell p={1} textAlign="center">
                Bounty Object
              </Table.Cell>
              <Table.Cell p={1} textAlign="center">
                Description
              </Table.Cell>
              <Table.Cell p={1} textAlign="center">
                Progress
              </Table.Cell>
              <Table.Cell p={1} textAlign="center">
                Value
              </Table.Cell>
              <Table.Cell p={1} textAlign="center">
                Claim
              </Table.Cell>
            </Table.Row>
            {bountydata.map(bounty => (
              <Table.Row
                key={bounty.name}
                backgroundColor={bounty.priority === 1
                  ? 'rgba(252, 152, 3, 0.25)'
                  : ''}>
                <Table.Cell bold p={1}>
                  {bounty.name}
                </Table.Cell>
                <Table.Cell 
                  italic 
                  textAlign="center"
                  p={1}>
                  {bounty.description}
                </Table.Cell>
                <Table.Cell 
                  bold 
                  p={1} 
                  textAlign="center">
                  {bounty.priority === 1
                    ? <Box>High Priority</Box>
                    : ""}
                  {bounty.completion_string}
                </Table.Cell>
                <Table.Cell 
                  bold 
                  p={1}
                  textAlign="center">
                  {bounty.reward_string}
                </Table.Cell>
                <Table.Cell 
                  bold 
                  p={1}>
                  <Button 
                    fluid
                    textAlign="center"
                    icon={bounty.claimed === 1
                      ? "check"
                      : ""}
                    content={bounty.claimed === 1
                      ? "Claimed"
                      : "Claim"}
                    disabled={bounty.claimed === 1}
                    color={bounty.can_claim === 1
                      ? 'green'
                      : 'red'}
                    onClick={() => act('ClaimBounty', {
                      bounty: bounty.bounty_ref,
                    })} />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const BountyHeader = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    stored_cash,
  } = data;
  return (
    <Box inline bold>
      <AnimatedNumber
        value={stored_cash}
        format={value => formatMoney(value)} />
      {' credits'}
    </Box>
  );
};
