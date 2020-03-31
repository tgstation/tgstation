import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Grid, LabeledList, ProgressBar, Section } from '../components';

export const NtosRoboControl = props => {
  const { act, data } = useBackend(props);
  return (
    <Section
      title="Outbomb Cuban Pete Ultra"
      textAlign="center">
      <Box />
    </Section>
  );
};
