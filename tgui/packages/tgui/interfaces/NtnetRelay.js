import { useBackend } from '../backend';
import { Box, Button, ProgressBar, Section, AnimatedNumber } from '../components';
import { Window } from '../layouts';

export const NtnetRelay = (props, context) => {
  const { act, data } = useBackend(context);
  const { enabled, dos_capacity, dos_overload, dos_crashed } = data;
  return (
    <Window title="NtNet Quantum Relay" width={400} height={300}>
      <Window.Content>
        <Section
          title="Network Buffer"
          buttons={
            <Button
              icon="power-off"
              selected={enabled}
              content={enabled ? 'ENABLED' : 'DISABLED'}
              onClick={() => act('toggle')}
            />
          }>
          {!dos_crashed ? (
            <ProgressBar
              value={dos_overload}
              minValue={0}
              maxValue={dos_capacity}>
              <AnimatedNumber value={dos_overload} /> GQ
              {' / '}
              {dos_capacity} GQ
            </ProgressBar>
          ) : (
            <Box fontFamily="monospace">
              <Box fontSize="20px">NETWORK BUFFER OVERFLOW</Box>
              <Box fontSize="16px">OVERLOAD RECOVERY MODE</Box>
              <Box>
                This system is suffering temporary outage due to overflow of
                traffic buffers. Until buffered traffic is processed, all
                further requests will be dropped. Frequent occurences of this
                error may indicate insufficient hardware capacity of your
                network. Please contact your network planning department for
                instructions on how to resolve this issue.
              </Box>
              <Box fontSize="20px" color="bad">
                ADMINISTRATOR OVERRIDE
              </Box>
              <Box fontSize="16px" color="bad">
                CAUTION - DATA LOSS MAY OCCUR
              </Box>
              <Button
                icon="signal"
                content="PURGE BUFFER"
                mt={1}
                color="bad"
                onClick={() => act('restart')}
              />
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
