import { useBackend } from '../../backend';
import { Button, LabeledList, Section, Stack } from '../../components';
import { ControllerData } from './types';

export function OverviewSection(props) {
  const { act, data } = useBackend<ControllerData>();
  const { fast_update, map_cpu, subsystems = [], world_time } = data;

  let overallUsage = 0;
  let overallOverrun = 0;
  for (let i = 0; i < subsystems.length; i++) {
    overallUsage += subsystems[i].tick_usage;
    overallOverrun += subsystems[i].tick_overrun;
  }

  return (
    <Section
      fill
      title="Master Overview"
      buttons={
        <Button
          tooltip="Fast Update"
          icon={fast_update ? 'check-square-o' : 'square-o'}
          color={fast_update && 'average'}
          onClick={() => {
            act('toggle_fast_update');
          }}
        >
          Fast
        </Button>
      }
    >
      <Stack fill>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="World Time">
              {world_time.toFixed(1)}
            </LabeledList.Item>
            <LabeledList.Item label="Map CPU">
              {map_cpu.toFixed(2)}%
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Overall Usage">
              {(overallUsage * 0.01).toFixed(2)}%
            </LabeledList.Item>
            <LabeledList.Item label="Overall Overrun">
              {(overallOverrun * 0.01).toFixed(2)}%
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
