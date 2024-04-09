import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Box, Button, Divider } from '../components';
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
  legend: string;
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
    <Window width={450} height={330}>
      <Window.Content scrollable>
        {legend === legend_viewing_list ? (<WireList />) : (legend === legend_off ? (<MainMenu />) : (<WireArea />))}
      </Window.Content>
    </Window>
  );
};

const WireList = () => {
  const { act, data } = useBackend<Data>();
  const { wire_devices = [] } = data;

  return (
    <Box>
      <Button
        fluid
        icon="chevron-left"
        content="Back"
        onClick={() => act('exit_legend')}
      />
      <Box>
        {wire_devices.map((wire) => (
          <Button
            width="49.5%"
            key={wire.ref}
            content={wire.name}
            onClick={() =>
            act('view_wireset', {
              view_wireset: wire.ref,
            })}
          />
        ))}
      </Box>
    </Box>
  );
};

const WireArea = () => {
  const { act, data } = useBackend<Data>();
  const { wires_name, wire_data = [] } = data;

  return (
    <>
      <Button
        fluid
        icon="chevron-left"
        content="Back"
        onClick={() => act('view_legend')}
      />
      <Box bold>
        {wires_name} wires:
      </Box>
      {wire_data.map((wire) => (
        <Box ml={1} m={1} key={wire}>
          <span style={{ color: wire.color }}>{wire.color}</span>: {wire.message}
        </Box>
      ))}
    </>
  );
};

const MainMenu = () => {
  const { act, data } = useBackend<Data>();
  const { area_notice, area_name, fluff_notice, station_name, viewing } = data;

  return (
    <>
      <Box bold m={1}>
        {station_name} blueprints
      </Box>
      <Box>
        {fluff_notice}
      </Box>
      <Divider />
      <Box>
        <Button
          fluid
          icon="pencil"
          content="Create or modify an existing area"
          onClick={() => act('create_area')}
        />
      </Box>
      <Box bold m={1.5}>
        {area_notice}
      </Box>
      <Box>
        <Button
          fluid
          icon="font"
          content="Change area name"
          onClick={() => act('edit_area')}
        />
      </Box>
      <Box>
        <Button
          fluid
          icon="chevron-right"
          content="View wire color legend"
          onClick={() => act('view_legend')}
        />
      </Box>
      <Box>
        {viewing ? (
          <>
            <Box>
              <Button
                fluid
                icon="wrench"
                content="Refresh structural data"
                onClick={() => act('refresh')}
              />
            </Box>
            <Box>
              <Button
                fluid
                icon="wrench"
                content="Hide structural data"
                onClick={() => act('hide_blueprints')}
              />
            </Box>
          </>
        ) : (
          <Button
            fluid
            icon="wrench"
            content="View structural data"
            onClick={() => act('view_blueprints')}
          />
        )}
      </Box>
    </>
  );
};
