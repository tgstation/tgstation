import { useBackend } from '../backend';
import { Box, Button, Collapsible, Flex, LabeledList, NumberInput, Section, Stack, TextArea } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const RequestKiosk = (props, context) => {
  return (
    <Window
      width={550}
      height={600}>
      <Window.Content scrollable>
        <RequestKioskContent />
      </Window.Content>
    </Window>
  );
};

export const RequestKioskContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    accountName,
    requests = [],
    applicants = [],
    bountyValue,
    bountyText,
  } = data;
  const color = 'rgba(13, 13, 213, 0.7)';
  const backColor = 'rgba(0, 0, 69, 0.5)';
  return (
    <>
      <Section>
        <LabeledList>
          <LabeledList.Item
            label="Current Account"
            buttons={(
              <Button
                icon="power-off"
                content="Log out"
                onClick={() => act('clear')} />
            )}>
            {accountName || 'N/A'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Flex mb={1}>
        <Flex.Item grow={1} basis={0}>
          {requests?.map(request => (
            <Collapsible
              key={request.name}
              title={request.owner}
              width="300px">
              <Section
                key={request.name}
                width="300px">
                <Stack align="baseline">
                  <Stack.Item bold width="310px">
                    {request.owner}
                  </Stack.Item>
                  <Stack.Item width="100px">
                    {formatMoney(request.value) + ' cr'}
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="pen-fancy"
                      content="Apply"
                      onClick={() => act('apply', {
                        request: request.acc_number,
                      })} />
                    <Button
                      fluid
                      icon="trash-alt"
                      content="Delete"
                      color="red"
                      onClick={() => act('deleteRequest', {
                        request: request.acc_number,
                      })} />
                  </Stack.Item>
                </Stack>
                <Section align="center">
                  <i>&quot;{request.description}&quot;</i>
                </Section>
                <Section
                  title="Request Applicants">
                  {applicants?.map(applicant => (
                    applicant.request_id === request.acc_number && (
                      <Flex>
                        <Flex.Item
                          grow={1}
                          p={0.5}
                          backgroundColor={backColor}
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
                            onClick={() => act('payApplicant', {
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
                height="250px"
                width="200px"
                backgroundColor="black"
                textColor="white"
                onChange={(e, value) => act('bountyText', {
                  bountytext: value,
                })} />
              <Box>
                <NumberInput
                  animate
                  unit="cr"
                  minValue={1}
                  maxValue={1000}
                  value={bountyValue}
                  width="80px"
                  onChange={(e, value) => act('bountyVal', {
                    bountyval: value,
                  })} />
              </Box>
              <Button
                icon="print"
                content="Submit bounty"
                onClick={() => act('createBounty')} />
            </Section>
          </Collapsible>
        </Flex.Item>
      </Flex>
    </>
  );
};
