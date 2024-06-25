import { useBackend } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Flex,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import { UserDetails } from './Vending';

type Data = {
  accountName: string;
  requests: Request[];
  applicants: Applicant[];
  bountyValue: number;
  bountyText: string;
  user: User;
};

type Request = {
  name: string;
  owner: string;
  description: string;
  value: number;
  acc_number: number;
};

type Applicant = {
  name: string;
  request_id: number;
  requestee_id: number;
};

type User = {
  name: string;
};

export const BountyBoard = (props) => {
  return (
    <Window width={550} height={600}>
      <Window.Content scrollable>
        <BountyBoardContent />
      </Window.Content>
    </Window>
  );
};

export const BountyBoardContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    accountName,
    requests = [],
    applicants = [],
    bountyValue,
    bountyText,
    user,
  } = data;
  const color = 'rgba(13, 13, 213, 0.7)';
  const backColor = 'rgba(50, 50, 170, 0.5)';
  return (
    <>
      <Section
        title={'User Details'}
        buttons={
          <Button
            icon="power-off"
            content="Reset Account"
            onClick={() => act('clear')}
          />
        }
      >
        <UserDetails />
      </Section>
      <Flex mb={1}>
        <Flex.Item grow={1} basis={0}>
          {requests?.map((request) => (
            <Collapsible key={request.name} title={request.owner} width="300px">
              <Section key={request.name} width="300px">
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
                      disabled={request.owner === user.name}
                      onClick={() =>
                        act('apply', {
                          request: request.acc_number,
                        })
                      }
                    />
                    <Button
                      fluid
                      icon="trash-alt"
                      content="Delete"
                      color="red"
                      onClick={() =>
                        act('deleteRequest', {
                          request: request.acc_number,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
                <BlockQuote pt={1} align="center">
                  <i>&quot;{request.description}&quot;</i>
                </BlockQuote>
                <Section title="Request Applicants">
                  {applicants?.map(
                    (applicant) =>
                      applicant.request_id === request.acc_number && (
                        <Flex key={applicant.request_id}>
                          <Flex.Item
                            grow={1}
                            p={0.5}
                            backgroundColor={backColor}
                            width="500px"
                            textAlign="center"
                            style={{
                              border: `2px solid ${color}`,
                            }}
                          >
                            {applicant.name}
                          </Flex.Item>
                          <Flex.Item align="end">
                            <Button
                              fluid
                              p={1}
                              icon="cash-register"
                              tooltip="Pay out to this applicant."
                              onClick={() =>
                                act('payApplicant', {
                                  applicant: applicant.requestee_id,
                                  request: request.acc_number,
                                })
                              }
                            />
                          </Flex.Item>
                        </Flex>
                      ),
                  )}
                </Section>
              </Section>
            </Collapsible>
          ))}
        </Flex.Item>
        <Flex.Item>
          <Collapsible title="New Bounty" width="220px" color="green">
            <Section>
              <TextArea
                fluid
                height="150px"
                width="200px"
                backgroundColor="black"
                textColor="white"
                onChange={(e, value) =>
                  act('bountyText', {
                    bountytext: value,
                  })
                }
              />
              <Box>
                <NumberInput
                  animated
                  unit="cr"
                  minValue={1}
                  maxValue={1000}
                  value={bountyValue}
                  step={1}
                  width="80px"
                  onChange={(value) =>
                    act('bountyVal', {
                      bountyval: value,
                    })
                  }
                />
                <Button
                  icon="print"
                  content="Submit bounty"
                  disabled={user.name === 'Unknown'}
                  onClick={() => act('createBounty')}
                />
              </Box>
            </Section>
          </Collapsible>
        </Flex.Item>
      </Flex>
    </>
  );
};
