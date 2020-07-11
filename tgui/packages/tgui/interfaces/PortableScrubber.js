import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Box, Section, LabeledList, Button, AnimatedNumber, NumberInput } from '../components';
import { getGasLabel } from '../constants';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';

export const PortableScrubber = (props, context) => {
  const { act, data } = useBackend(context);

  const filter_types = data.filter_types || [];

  return (
    <Window>
      <Window.Content>
        <PortableBasicInfo />
        <Section title="Filters">
          {filter_types.map(filter => (
            <Button
              key={filter.id}
              icon={filter.enabled ? 'check-square-o' : 'square-o'}
              content={getGasLabel(filter.gas_id, filter.gas_name)}
              selected={filter.enabled}
              onClick={() => act('toggle_filter', {
                val: filter.gas_id,
              })} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
