import { useBackend } from '../backend';
import { Box, Button, Grid, Section } from '../components';
import { Window } from '../layouts';

export const EmergencyShuttleConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    timer_str,
    enabled,
    emagged,
    engines_started,
    authorizations_remaining,
    authorizations = [],
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section>
          <Box
            bold
            fontSize="40px"
            textAlign="center"
            fontFamily="monospace">
            {timer_str}
          </Box>
          <Box
            textAlign="center"
            fontSize="16px"
            mb={1}>
            <Box
              inline
              bold>
              ENGINES:
            </Box>
            <Box
              inline
              color={engines_started ? 'good' : 'average'}
              ml={1}>
              {engines_started ? 'Online' : 'Idle'}
            </Box>
          </Box>
          <Section
            title="Early Launch Authorization"
            level={2}
            buttons={(
              <Button
                icon="times"
                content="Repeal All"
                color="bad"
                disabled={!enabled}
                onClick={() => act('abort')} />
            )}>
            <Grid>
              <Grid.Column>
                <Button
                  fluid
                  icon="exclamation-triangle"
                  color="good"
                  content="AUTHORIZE"
                  disabled={!enabled}
                  onClick={() => act('authorize')} />
              </Grid.Column>
              <Grid.Column>
                <Button
                  fluid
                  icon="minus"
                  content="REPEAL"
                  disabled={!enabled}
                  onClick={() => act('repeal')} />
              </Grid.Column>
            </Grid>
            <Section
              title="Authorizations"
              level={3}
              minHeight="150px"
              buttons={(
                <Box
                  inline
                  bold
                  color={emagged ? 'bad' : 'good'}>
                  {emagged ? 'ERROR' : 'Remaining: ' + authorizations_remaining}
                </Box>
              )}>
              {authorizations.length > 0 ? (
                authorizations.map(authorization => (
                  <Box
                    key={authorization.name}
                    bold
                    fontSize="16px"
                    className="candystripe">
                    {authorization.name} ({authorization.job})
                  </Box>
                ))
              ) : (
                <Box
                  bold
                  textAlign="center"
                  fontSize="16px"
                  color="average">
                  No Active Authorizations
                </Box>
              )}
              {authorizations.map(authorization => (
                <Box
                  key={authorization.name}
                  bold
                  fontSize="16px"
                  className="candystripe">
                  {authorization.name} ({authorization.job})
                </Box>
              ))}
            </Section>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
