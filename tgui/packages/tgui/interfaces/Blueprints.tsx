import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Box, Button, Divider, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  area_notice: string;
  area_name: string;
  wire_data: WireData[];
  legend: string;
  legend_viewing_list: string;
  legend_off: string;
  fluff_notice: string;
  station_name: string;
  wires_name: string;
  wire_devices: WireDevices[];
  viewing: BooleanLike;
};

type WireDevices = {
  name: string;
  ref: string;
};

type WireData = {
  color: string;
  message: string;
};

export const Blueprints = () => {
  const { act, data } = useBackend<Data>();
  const { legend, legend_viewing_list, legend_off } = data;

  return (
    <Window width={450} height={340}>
      <Window.Content scrollable>
        {legend === legend_viewing_list ? (
          <WireList />
        ) : legend === legend_off ? (
          <MainMenu />
        ) : (
          <WireArea />
        )}
      </Window.Content>
    </Window>
  );
};

const WireList = () => {
  const { act, data } = useBackend<Data>();
  const { wire_devices = [] } = data;

  return (
    <Section>
      <Button fluid icon="chevron-left" onClick={() => act('exit_legend')}>
        Back
      </Button>
      <Box>
        {wire_devices.map((wire) => (
          <Button
            width="49.5%"
            key={wire.ref}
            onClick={() =>
              act('view_wireset', {
                view_wireset: wire.ref,
              })
            }
          >
            {wire.name}
          </Button>
        ))}
      </Box>
    </Section>
  );
};

const WireArea = () => {
  const { act, data } = useBackend<Data>();
  const { wires_name, wire_data = [] } = data;

  return (
    <Section>
      <Button fluid icon="chevron-left" onClick={() => act('view_legend')}>
        Back
      </Button>
      <Box bold>{wires_name} wires:</Box>
      {wire_data.map((wire) => (
        <Box ml={1} m={1} key={wire.message}>
          <span style={{ color: wire.color }}>{wire.color}</span>:{' '}
          {wire.message}
        </Box>
      ))}
    </Section>
  );
};

const MainMenu = () => {
  const { act, data } = useBackend<Data>();
  const { area_notice, area_name, fluff_notice, station_name, viewing } = data;

  return (
    <Section>
      <Box bold m={1} textAlign="center">
        {station_name} blueprints
      </Box>
      <Box italic fontSize={0.9}>
        {fluff_notice}
      </Box>
      <Divider />
      <Box>
        <Button
          fluid
          pb={0.75}
          textAlign="center"
          icon="pencil"
          onClick={() => act('create_area')}
        >
          Create or modify an existing area
        </Button>
      </Box>
      <Box bold m={1.5} textAlign="center">
        {area_notice}
      </Box>
      <Box>
        <Button
          fluid
          pb={0.75}
          textAlign="center"
          icon="font"
          onClick={() => act('edit_area')}
        >
          Change area name
        </Button>
      </Box>
      <Box>
        <Button
          fluid
          pb={0.75}
          textAlign="center"
          icon="chevron-right"
          onClick={() => act('view_legend')}
        >
          View wire color legend
        </Button>
      </Box>
      <Box>
        {viewing ? (
          <>
            <Box>
              <Button
                fluid
                pb={0.75}
                textAlign="center"
                icon="wrench"
                onClick={() => act('refresh')}
              >
                Refresh structural data
              </Button>
            </Box>
            <Box>
              <Button
                fluid
                pb={0.75}
                textAlign="center"
                icon="wrench"
                onClick={() => act('hide_blueprints')}
              >
                Hide structural data
              </Button>
            </Box>
          </>
        ) : (
          <Button
            fluid
            pb={0.75}
            textAlign="center"
            icon="wrench"
            onClick={() => act('view_blueprints')}
          >
            View structural data
          </Button>
        )}
      </Box>
    </Section>
  );
};
