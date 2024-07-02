import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
import { BAYS } from './constants';
import { PodLauncherData } from './types';

export function PodBays(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { bayNumber } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            color="transparent"
            icon="trash"
            onClick={() => act('clearBay')}
            tooltip={`
              Clears everything
              from the selected bay`}
            tooltipPosition="top-end"
          />
          <Button
            color="transparent"
            icon="question"
            tooltip={`
              Each option corresponds
              to an area on centcom.
              Launched pods will
              be filled with items
              in these areas according
              to the "Load from Bay"
              options at the top left.`}
            tooltipPosition="top-end"
          />
        </>
      }
      fill
      title="Bay"
    >
      {BAYS.map((bay, i) => (
        <Button
          key={i}
          onClick={() => act('switchBay', { bayNumber: '' + (i + 1) })}
          selected={bayNumber === '' + (i + 1)}
          tooltipPosition="bottom-end"
        >
          {bay.title}
        </Button>
      ))}
    </Section>
  );
}
