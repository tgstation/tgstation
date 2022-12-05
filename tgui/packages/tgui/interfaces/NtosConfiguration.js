import { useBackend } from '../backend';
import { Box, LabeledList, ProgressBar, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosConfiguration = (props, context) => {
  const { act, data } = useBackend(context);
  const { PC_device_theme, power_usage, battery, disk_size, disk_used } = data;
  return (
    <NtosWindow theme={PC_device_theme} width={420} height={630}>
      <NtosWindow.Content scrollable>
        <Section
          title="Power Supply"
          buttons={
            <Box inline bold mr={1}>
              Power Draw: {power_usage}W
            </Box>
          }>
          <LabeledList>
            <LabeledList.Item
              label="Battery Status"
              color={!battery && 'average'}>
              {battery ? (
                <ProgressBar
                  value={battery.charge}
                  minValue={0}
                  maxValue={battery.max}
                  ranges={{
                    good: [battery.max / 2, Infinity],
                    average: [battery.max / 4, battery.max / 2],
                    bad: [-Infinity, battery.max / 4],
                  }}>
                  {battery.charge} / {battery.max}
                </ProgressBar>
              ) : (
                'Not Available'
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="File System">
          <ProgressBar
            value={disk_used}
            minValue={0}
            maxValue={disk_size}
            color="good">
            {disk_used} GQ / {disk_size} GQ
          </ProgressBar>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
