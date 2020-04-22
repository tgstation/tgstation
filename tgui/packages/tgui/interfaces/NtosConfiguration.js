import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosConfiguration = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    power_usage,
    battery_exists,
    battery = {},
    disk_size,
    disk_used,
    hardware = [],
  } = data;

  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <Section
          title="Power Supply"
          buttons={(
            <Box
              inline
              bold
              mr={1}>
              Power Draw: {power_usage}W
            </Box>
          )}>
          <LabeledList>
            <LabeledList.Item
              label="Battery Status"
              color={!battery_exists && 'average'}>
              {battery_exists ? (
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
              ) : 'Not Available'}
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
        <Section title="Hardware Components">
          {hardware.map(component => (
            <Section
              key={component.name}
              title={component.name}
              level={2}
              buttons={(
                <Fragment>
                  {!component.critical && (
                    <Button.Checkbox
                      content="Enabled"
                      checked={component.enabled}
                      mr={1}
                      onClick={() => act('PC_toggle_component', {
                        name: component.name,
                      })}
                    />
                  )}
                  <Box
                    inline
                    bold
                    mr={1}>
                    Power Usage: {component.powerusage}W
                  </Box>
                </Fragment>
              )}>
              {component.desc}
            </Section>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
