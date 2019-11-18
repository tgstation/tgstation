import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Box, Button, LabeledList, ProgressBar, Section, Tabs } from '../components';

export const Keycard_Auth = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Section>
      <Box>
        {data.waiting === 1 && (
          <span>Waiting for another device to confirm your request...</span>
        )}
      </Box>
      <Box>
        {data.auth_required === 1 && (
          <Button
            icon="check"
            onClick={() => act(ref, 'auth_swipe')}
            content="Authorize" />
        )}
		{data.auth_required === 0 && (
          <Button
            icon="warning"
            onClick={() => act(ref, 'red_alert')}
            content="Red Alert" />
		  <Button
            icon="wrench"
            onClick={() => act(ref, 'emergency_maint')}
            content="Emergency Maint" />
		  <Button
            icon="warning"
            onClick={() => act(ref, 'bsa_unlock')}
            content="Bluespace Artillery Unlock" />
        )}
      </Box>
    </Section>
  );
};
