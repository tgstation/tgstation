import { Box, Divider, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  error_message: string | null;
  last_power_output: string | null;
  cold_data: CirculatorData[];
  hot_data: CirculatorData[];
};

type CirculatorData = {
  temperature_inlet: number | null;
  temperature_outlet: number | null;
  pressure_inlet: number | null;
  pressure_outlet: number | null;
};

export const ThermoElectricGenerator = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    error_message,
    last_power_output,
    cold_data = [],
    hot_data = [],
  } = data;
  if (error_message) {
    return (
      <Window width={320} height={100}>
        <Window.Content>
          <Section>ERROR: {error_message}</Section>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={350} height={195}>
      <Window.Content>
        <Section>
          <Box>
            <Box>Last Output: {last_power_output}</Box>
            <Divider />
            <Box m={1} textColor="cyan" bold>
              Cold Loop
            </Box>
            {cold_data.map((data, index) => (
              <Box key={index}>
                <Box>
                  Temperature Inlet: {data.temperature_inlet} K / Outlet:{' '}
                  {data.temperature_outlet} K
                </Box>
                <Box>
                  Pressure Inlet: {data.pressure_inlet} kPa / Outlet:{' '}
                  {data.pressure_outlet} kPa
                </Box>
              </Box>
            ))}
          </Box>
          <Box>
            <Box m={1} textColor="red" bold>
              Hot loop{' '}
            </Box>
            {hot_data.map((data, index) => (
              <Box key={index}>
                <Box>
                  Temperature Inlet: {data.temperature_inlet} K / Outlet:{' '}
                  {data.temperature_outlet} K
                </Box>
                <Box>
                  Pressure Inlet: {data.pressure_inlet} kPa / Outlet:{' '}
                  {data.pressure_outlet} kPa
                </Box>
              </Box>
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
