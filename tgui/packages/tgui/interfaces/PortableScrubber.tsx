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
  gasId: string;
  gasName: string;
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
              content={getGasLabel(filter.gasId, filter.gasName)}
              selected={filter.enabled}
              onClick={() =>
                act('toggle_filter', {
                  val: filter.gasId,
                })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
