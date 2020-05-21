import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, LabeledList, NumberInput, Section } from '../components';
import { refocusLayout, Window } from '../layouts';

export const RequestKiosk = (props, context) => {
  const { act, data } = useBackend(context);
  const {
	  Requests,
  } = data;
  return (
    <Window resizable>
      <div className="RequestKiosk__right">
        <Window.Content scrollable>
          <Flex mb={1}>
            <Flex.Item mr={1}>
              <Section>
                Broken List
				{Requests?.map(task => (
				  <div
					key={task.owner}
					title={task.owner}
					className={classes([
					  'Button',
					  'Button--fluid',
					  'Button--color--transparent',
					  'Button--ellipsis',
					
					])}
					onClick={() => {
					  refocusLayout();
						}}>
						Tasky
						</div>
				))}
              </Section>
            </Flex.Item>
            <Flex.Item grow={1} basis={0}>
			<Section>
              <LabeledList
                title="Create Requests">
				<LabeledList.Item
				label = "Current Account">
                {data.AccountName ? data.AccountName: 'N/A'}
				</LabeledList.Item>
				<LabeledList.Item
				label = "Current Bounty">
				</LabeledList.Item>
              </LabeledList>
			  </Section>
			  
			  
              <LabeledList>
                <LabeledList.Item
                  label="name">
                  Jimmy Twoshoes 
                  <Button
                    content="Pay me" />
                </LabeledList.Item>
                <LabeledList.Item
                  label="name">
                  Johnny Smollips 
                  <Button
                    content="Pay me" />
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Window.Content>
      </div>
    </Window>
  );
};