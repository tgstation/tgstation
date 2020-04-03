import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';

export const NtosAtmos = props => {
  const { act, data } = useBackend(props);
  const air = data.AirData || [];
  return (
    <Section
      title="Atmospheric Readings"
      textAlign="center">
      <Box>
        Temperature: {data.AirTemp} Celcius
      </Box>
      <Box>
        Pressure: {data.AirPressure} kPa
      </Box>
      <Box my={1} />
      <LabeledList>
        {air.map(gas => (
          <LabeledList.Item
            key={gas.name}
            label={gas.name}
            textAlign="center">
            {gas.percentage} %
            <Box my={1} />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};
