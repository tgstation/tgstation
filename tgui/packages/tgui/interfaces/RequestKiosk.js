import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, LabeledList, NumberInput, Table, Section } from '../components';
import { refocusLayout, Window } from '../layouts';

export const RequestKiosk = (props, context) => {
  const { act, data } = useBackend(context);
  const {
	  AccountName,
	  Requests = [],
  } = data;
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
				  <LabeledList>
					<LabeledList.Item
					  label={request.owner}>
						  <Section backgroundColor = "#414757">
						  "{request.description}"
						  <Box>Reward: {request.value} Cr </Box>
						  <Box>
						  <Button
							icon="play"
							content="Apply"
							onClick={() => act('Apply', {
							  request: request.applicants,
							})} />
						  <Button
							icon="pause"
							content="Delete"
							onClick={() => act('DeleteRequest', {
							  request: request,
							})} />
						</Box>
						  </Section>
					</LabeledList.Item>
					<LabeledList.Item
					  label = "Request Applicants">
					  {request.applicants?.map(applicant => (
						<LabeledList>
						  <LabeledList.Item
							label={applicant.name}>
							<Button
							icon="play"
							onClick={() => act('PayApplicant', {
							})} />
						  </LabeledList.Item>
						</LabeledList>
					  ))}
					</LabeledList.Item>
				  </LabeledList>
				))}
              
            </Flex.Item>
          </Flex>
        </Window.Content>
      </div>
    </Window>
  );
};
