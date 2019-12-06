import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';

export const KeycardAuth = props => {
  const { act, data } = useBackend(props);
  return (
    <Section>
      <Box>
        {data.waiting === 1 && (
          <span>Waiting for another device to confirm your request...</span>
        )}
      </Box>
      <Box>
        {data.waiting === 0 && (
          <Fragment>
            {!!data.auth_required && (
              <Button
                icon="check-square"
                color="red"
                textAlign="center"
                lineHeight="60px"
                fluid
                onClick={() => act('auth_swipe')}
                content="Authorize" />
            )}
            {data.auth_required === 0 && (
              <Fragment>
                <Button
                  icon="exclamation-triangle"
                  fluid
                  onClick={() => {
                    return act('red_alert');
                  }}
                  content="Red Alert" />
                <Button
                  icon="wrench"
                  fluid
                  onClick={() => act('emergency_maint')}
                  content="Emergency Maintenance Access" />
                <Button
                  icon="meteor"
                  fluid
                  onClick={() => act('bsa_unlock')}
                  content="Bluespace Artillery Unlock" />
              </Fragment>
            )}
          </Fragment>
        )}
      </Box>
    </Section>
  );
};
