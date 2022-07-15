import { useBackend } from '../backend';
import { Box, Button, Icon, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const Gateway = () => {
  return (
    <Window>
      <Window.Content scrollable>
        <GatewayContent />
      </Window.Content>
    </Window>
  );
};

const GatewayContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    gateway_present = false,
    gateway_status = false,
    current_target = null,
    destinations = [],
  } = data;
  if (!gateway_present) {
    return (
      <Section>
        <NoticeBox>No linked gateway</NoticeBox>
        <Button fluid onClick={() => act('linkup')}>
          Linkup
        </Button>
      </Section>
    );
  }
  if (current_target) {
    return (
      <Section title={current_target.name}>
        <Icon name="rainbow" size={4} color="green" />
        <Button fluid onClick={() => act('deactivate')}>
          Deactivate
        </Button>
      </Section>
    );
  }
  if (!destinations.length) {
    return <Section>No gateway nodes detected.</Section>;
  }
  return (
    <>
      {!gateway_status && <NoticeBox>Gateway Unpowered</NoticeBox>}
      {destinations.map((dest) => (
        <Section key={dest.ref} title={dest.name}>
          {(dest.available && (
            <Button
              fluid
              onClick={() =>
                act('activate', {
                  destination: dest.ref,
                })
              }>
              Activate
            </Button>
          )) || (
            <>
              <Box m={1} textColor="bad">
                {dest.reason}
              </Box>
              {!!dest.timeout && (
                <ProgressBar value={dest.timeout}>Calibrating...</ProgressBar>
              )}
            </>
          )}
        </Section>
      ))}
    </>
  );
};
