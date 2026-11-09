import {
  Box,
  Button,
  ByondUi,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Gateway = () => {
  return (
    <Window width={350} height={440}>
      <Window.Content scrollable>
        <GatewayContent />
      </Window.Content>
    </Window>
  );
};

const GatewayContent = (props) => {
  const { act, data } = useBackend();
  const {
    gateway_present = false,
    gateway_status = false,
    current_target = null,
    destinations = [],
    gateway_mapkey,
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
        <ByondUi
          height="320px"
          params={{
            id: gateway_mapkey,
            type: 'map',
          }}
        />
        <Button
          mt="2px"
          textAlign="center"
          fluid
          onClick={() => act('deactivate')}
        >
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
              }
            >
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
