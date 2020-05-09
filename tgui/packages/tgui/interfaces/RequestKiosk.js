import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Input, LabeledList, NumberInput, Section } from '../components';
import { refocusLayout, Window } from '../layouts';

export const RequestKiosk = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    health,
    color,
  } = data;
  return (
    <Window resizable>
      <div className="RequestKiosk__right">
		<Window.Content scrollable>
		<Flex mb={1}>
          <Flex.Item mr={1}>
          <Section>
			a list of tasks here
		  </Section>
		  </Flex.Item>
		  <Flex.Item grow={1} basis={0}>
		  <Section
		  title="Create Request">
			Some buttons that would let you create a new request would be here.
			<Input
			fluid
			mb={1}
			placeholder="At some point this could be a description"
			onInput={(e, value) => setSearchText(value)} />
			Bounty Amount 
			<NumberInput
                      value={0}
                      unit="Credits"
                      minValue={0}
                      maxValue={1000}
                      step={10}
                      stepPixelSize={2}
					  />
		</Section>
		<LabeledList>
			<LabeledList.Item
			label="name">
				Jimmy Twoshoes 
				<Button
				  content="Pay me"/>
			</LabeledList.Item>
			<LabeledList.Item
			label="name">
				Johnny Dicklips 
				<Button
				  content="Pay me"/>
			</LabeledList.Item>
		</LabeledList>
		</Flex.Item>
		</Flex>
        </Window.Content>
	  </div>
    </Window>
  );
};