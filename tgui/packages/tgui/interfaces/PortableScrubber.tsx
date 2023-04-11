import { Button, Section } from '../components';
import { FilterGas, getGasLabel } from '../constants';

import { PortableBasicInfo } from './common/PortableAtmos';
import { Window } from '../layouts';
import { useBackend } from '../backend';

type Data = {
  filterTypes: FilterGas[];
};

export const PortableScrubber = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { filterTypes = [] } = data;

  return (
    <Window width={320} height={420}>
      <Window.Content>
        <PortableBasicInfo />
        <Section title="Filters">
          {filterTypes.map(({ id, enabled, gasId, gasName }) => (
            <Button
              key={id}
              icon={enabled ? 'check-square-o' : 'square-o'}
              content={getGasLabel(gasId, gasName)}
              selected={enabled}
              onClick={() =>
                act('toggle_filter', {
                  val: gasId,
                })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
