import { Button, Section } from '../components';

import { BooleanLike } from 'common/react';
import { PortableBasicInfo } from './common/PortableAtmos';
import { Window } from '../layouts';
import { getGasLabel } from '../constants';
import { useBackend } from '../backend';

type Data = {
  filterTypes: Filter[];
};

type Filter = {
  id: string;
  enabled: BooleanLike;
  gasId: string;
  gasName: string;
};

export const PortableScrubber = (props) => {
  const { act, data } = useBackend<Data>();
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
