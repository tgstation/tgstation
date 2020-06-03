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
  const color = 'rgba(13, 13, 213, 1)';
  return (
    <Window resizable>
      <div className="RequestKiosk__right">
        <Window.Content scrollable>
          <Flex mb={1}>
            <Flex.Item mr={1}>
              <Section>
                replace
              </Section>
            </Flex.Item>
            <Flex.Item grow={1} basis={0}>
              <Section
                buttons={(
                  <Fragment>
                    <Button
                      icon="power-off"
                      content="Log out"
                      onClick={() => act('Clear')} />
                    <Button
                      icon="power-off"
                      content="Print Bounty Slip"
                      onClick={() => act('CreateBounty')} />
                  </Fragment>
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
                <Section>
                  <Flex spacing={1} align="baseline">
                    <Flex.Item bold width="320px">
                      {request.owner}
                    </Flex.Item>
                    <Flex.Item>
                      {formatMoney(request.value) + ' cr'}
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        content="Apply"
                        onClick={() => act('Apply', {
                          request: request.req_number,
                        })} />
                      <Button
                        icon="pause"
                        content="Delete"
                        color="red"
                        onClick={() => act('DeleteRequest', {
                          request: request.req_number,
                        })} />
                    </Flex.Item>
                  </Flex>
                  <Section align="center">
                    <i>&quot;{request.description}&quot;</i>
                  </Section>
                  <Section
                    title="Request Applicants">
                    {Applicants?.map(applicant => (
					
        
                      <Flex>
                        <Flex.Item
                          grow={1}
                          ml={1}
                          backgroundColor="#000030"
                          width="500px"
                          style={{
                            border: `2px solid ${color}`,
                          }}>
                          {applicant.name}
                        </Flex.Item>
                        <Flex.Item 
                          align="end">
                          <Button
                            icon="play"
                            onClick={() => act('PayApplicant', {
                              applicant: applicant.app_number,
                            })} />
                        </Flex.Item>
                      </Flex>
                    ))}
                  </Section>
                </Section>  
              ))}
              
            </Flex.Item>
          </Flex>
        </Window.Content>
      </div>
    </Window>
  );
};
