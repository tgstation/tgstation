import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, Section } from '../components';

export const KeycardAuth = props => {
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
        {data.waiting === 0 && (
          <Fragment>
            {!!data.auth_required && (
              <Button
                icon="check-square"
                color="red"
                textAlign="center"
                lineHeight="60px"
                fluid
                onClick={() => act(ref, 'auth_swipe')}
                content="Authorize" />
            )}
            {data.auth_required === 0 && (
              <Fragment>
                <Button
                  icon="exclamation-triangle"
                  fluid
                  onClick={() => {
                    return act(ref, 'red_alert');
                  }}
                  content="Red Alert" />
                <Button
                  icon="wrench"
                  fluid
                  onClick={() => act(ref, 'emergency_maint')}
                  content="Emergency Maintenance Access" />
                <Button
                  icon="meteor"
                  fluid
                  onClick={() => act(ref, 'bsa_unlock')}
                  content="Bluespace Artillery Unlock" />
              </Fragment>
            )}
          </Fragment>
        )}
      </Box>
    </Section>
  );
};
