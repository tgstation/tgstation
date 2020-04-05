import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, LabeledList, ProgressBar, Section } from '../components';

export const NtosShipping = props => {
  const { act, data } = useBackend(props);
  return (
    <Section
      title="NTOS Shipping Hub."
	  buttons={(
        <Button
          icon="arrow-left"
          content="Eject Id"
		  disabled={data.has_id === 0 || data.has_id === 1}
          onClick={() => act(ref, 'ejectid', {
		  })} />
      )}>
		<Box>
		{data.card_owner}
		</Box>
    </Section>
  );
};
