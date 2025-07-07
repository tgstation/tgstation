import { Box, Button, Divider, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  area_notice: string;
  area_name: string;
  area_allows_shuttle_docking: boolean;
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
      <Stack fill wrap g={0.5} mt={1}>
        {wire_devices.map((wire) => (
          <Stack.Item key={wire.ref} grow basis={10}>
            <Button
              fluid
              ellipsis
              onClick={() =>
                act('view_wireset', {
                  view_wireset: wire.ref,
                })
              }
            >
              {wire.name}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
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
  const {
    area_notice,
    area_name,
    area_allows_shuttle_docking,
    fluff_notice,
    station_name,
    viewing,
  } = data;

  const buttonProps = {
    fluid: true,
    textAlign: 'center',
    py: 0.75,
  };

  return (
    <Section title={`${station_name} blueprints`}>
      <Box italic fontSize={0.9}>
        {fluff_notice}
      </Box>
      <Divider />
      <Box bold m={1.5} textAlign="center">
        {area_notice}
      </Box>
      <Stack fill vertical>
        <Stack.Item>
          <Button
            {...buttonProps}
            icon="pencil"
            onClick={() => act('create_area')}
          >
            Create or modify an existing area
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button {...buttonProps} icon="font" onClick={() => act('edit_area')}>
            Change area name
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            {...buttonProps}
            icon={area_allows_shuttle_docking ? 'toggle-on' : 'toggle-off'}
            iconPosition="right"
            onClick={() => act('toggle_allow_shuttle_docking')}
          >
            Allow shuttle docking
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            {...buttonProps}
            icon="chevron-right"
            onClick={() => act('view_legend')}
          >
            View wire color legend
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Stack fill>
            <Stack.Item grow>
              <Button
                {...buttonProps}
                icon="wrench"
                color={!!viewing && 'red'}
                onClick={() =>
                  act(viewing ? 'hide_blueprints' : 'view_blueprints')
                }
              >
                {viewing ? 'Hide' : 'View'} structural data
              </Button>
            </Stack.Item>
            {!!viewing && (
              <Stack.Item>
                <Button
                  {...buttonProps}
                  p={0.75}
                  icon="refresh"
                  tooltip="Refresh structural data"
                  onClick={() => act('refresh')}
                />
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
