import { multiline } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section, Tabs } from '../components';

export const NtosRoboControl = props => {
  const { act, data } = useBackend(props);
  return (
	<Fragment>
		<Section
		  title="Robot Control Console"
		  textAlign="center">
		  <Box>
		  Bots detected in range:{data.botcount} 
		  </Box>
		  <Section>
			{data.bots.map(robot => (
				  <Box
					key={robot.name}
					color="black">
				  </Box>
				))}
		  </Section>
		</Section>
	</Fragment>
  );
};
