import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Collapsible, Flex, LabeledList, NumberInput, Section, TextArea } from '../components';
import { formatMoney } from '../format';
import { refocusLayout, Window } from '../layouts';

export const RequestKiosk = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    AccountName,
    Requests =[],
    Applicants =[],
    BountyValue,
    BountyText,
  } = data;
  const color = 'rgba(13, 13, 213, 0.7)';
  const BackColor = 'rgba(0, 0, 69, 0.5)';
  const BackTextColor = 'rgba(255, 255, 255, 0.3)';
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section
          buttons={(
            <Flex>
              <Flex.Item mt={2}>
                <Button
                  icon="power-off"
                  content="Log out"
                  onClick={() => act('Clear')} />
              </Flex.Item>
            </Flex>
          )}>
          <LabeledList
            title="Create Requests">
            <LabeledList.Item
              label="Current Account">
              {AccountName ? AccountName: 'N/A'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Flex mb={1}>
          <Flex.Item grow={1} basis={0}>
            {Requests?.map(request => (
              <Collapsible
                key={request.name}
                title={request.owner}
                width="300px">
                <Section
                  key={request.name}
                  width="300px">
                  <Flex spacing={1} align="baseline">
                    <Flex.Item bold width="310px">
                      {request.owner}
                    </Flex.Item>
                    <Flex.Item width="100px">
                      {formatMoney(request.value) + ' cr'}
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        fluid
                        icon="pen-fancy"
                        content="Apply"
                        onClick={() => act('Apply', {
                          request: request.acc_number,
                        })} />
                      <Button
                        fluid
                        icon="trash-alt"
                        content="Delete"
                        color="red"
                        onClick={() => act('DeleteRequest', {
                          request: request.acc_number,
                        })} />
                    </Flex.Item>
                  </Flex>
                  <Section align="center">
                    <i>&quot;{request.description}&quot;</i>
                  </Section>
                  <Section
                    title="Request Applicants">
                    {Applicants?.map(applicant => (
                      applicant.request_id === request.acc_number && (
                        <Flex>
                          <Flex.Item
                            grow={1}
                            p={0.5}
                            backgroundColor={BackColor}
                            width="510px"
                            style={{
                              border: `2px solid ${color}`,
                            }}>
                            {applicant.name}
                          </Flex.Item>
                          <Flex.Item
                            align="end">
                            <Button
                              fluid
                              icon="cash-register"
                              onClick={() => act('PayApplicant', {
                                applicant: applicant.requestee_id,
                                request: request.acc_number,
                              })} />
                          </Flex.Item>
                        </Flex>
                      )
                    ))}
                  </Section>
                </Section>
              </Collapsible>
            ))}
          </Flex.Item>
          <Flex.Item>
            <Collapsible
              title="New Bounty"
              width="220px"
              color="green">
              <Section>
                <TextArea
                  fluid
                  value={BountyText}
                  height="250px"
                  width="200px"
                  backgroundColor={BackTextColor}
                  textColor="white"
                  onInput={(e, value) => act('bountytext', {
                    bountytext: value,
                  })} />
                <Box>
                  <NumberInput
                    animate
                    unit="cr"
                    minValue={1}
                    maxValue={1000}
                    value={BountyValue}
                    width="80px"
                    onChange={(e, value) => act('bountyval', {
                      bountyval: value,
                    })} />
                </Box>
                <Button
                  icon="print"
                  content="Submit bounty"
                  onClick={() => act('CreateBounty')} />
              </Section>
            </Collapsible>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
