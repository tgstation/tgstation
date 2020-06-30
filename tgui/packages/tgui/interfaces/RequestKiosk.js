import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, LabeledList, NumberInput, Table, Section } from '../components';
import { formatMoney } from '../format';
import { refocusLayout, Window } from '../layouts';

export const RequestKiosk = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    AccountName,
    Requests =[],
    Applicants =[],
  } = data;
  const color = 'rgba(13, 13, 213, 0.7)';
  const backcolor = 'rgba(0, 0, 69, 0.5)';
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Flex mb={1}>
          <Flex.Item grow={1} basis={0}>
            <Section
              buttons={(
                <Flex>
                  <Flex.Item mt={2}>
                    <Button
                      icon="power-off"
                      content="Log out"
                      onClick={() => act('Clear')} />
                    <Button
                      icon="print"
                      content="Print Bounty Slip"
                      onClick={() => act('CreateBounty')} />
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
            {Requests?.map(request => (
              <Section key={request.name}>
                <Flex spacing={1} align="baseline">
                  <Flex.Item bold width="310px">
                    {request.owner}
                  </Flex.Item>
                  <Flex.Item>
                    {formatMoney(request.value) + ' cr'}
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      icon="pen-fancy"
                      content="Apply"
                      onClick={() => act('Apply', {
                        request: request.acc_number,
                      })} />
                    <Button
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
                          backgroundColor={backcolor}
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
            ))}

          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
