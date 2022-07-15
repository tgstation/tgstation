import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { getGasLabel } from '../constants';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';

type Data = {
  filterTypes: Filter[];
};

type Filter = {
  id: string;
  enabled: BooleanLike;
  gas_id: string;
  gas_name: string;
};

export const PortableScrubber = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { filterTypes = [] } = data;

  return (
    <Window width={320} height={420}>
      <Window.Content>
        <PortableBasicInfo />
        <Section title="Filters">
          {filterTypes.map((filter) => (
            <Button
              key={filter.id}
              icon={filter.enabled ? 'check-square-o' : 'square-o'}
              content={getGasLabel(filter.gas_id, filter.gas_name)}
              selected={filter.enabled}
              onClick={() =>
                act('toggle_filter', {
                  val: filter.gas_id,
                })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
