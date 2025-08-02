import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { REVERSE_OPTIONS } from './constants';
import { useTab } from './hooks';
import type { PodLauncherData } from './types';

export function ReverseMenu(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const {
    customDropoff,
    effectReverse,
    picking_dropoff_turf,
    reverse_option_list,
  } = data;

  const [tab, setTab] = useTab();

  return (
    <Section
      buttons={
        <Button
          icon={effectReverse ? 'toggle-on' : 'toggle-off'}
          onClick={() => {
            act('effectReverse');
            if (tab === 2) {
              setTab(1);
              act('tabSwitch', { tabIndex: 1 });
            }
          }}
          selected={effectReverse}
          tooltip={`
            Doesn't send items.
            Afer landing, returns to
            dropoff turf (or bay
            if none specified).`}
          tooltipPosition="bottom"
        />
      }
      fill
      title="Reverse"
    >
      {!!effectReverse && (
        <Stack fill vertical>
          <Stack.Item maxHeight="20px">
            <Button
              disabled={!effectReverse}
              onClick={() => act('pickDropoffTurf')}
              selected={picking_dropoff_turf}
              tooltip={`
                Where reverse pods
                go after landing`}
              tooltipPosition="bottom-end"
            >
              Dropoff Turf
            </Button>
            <Button
              disabled={!customDropoff}
              icon="trash"
              inline
              onClick={() => {
                act('clearDropoffTurf');
                if (tab === 2) {
                  setTab(1);
                  act('tabSwitch', { tabIndex: 1 });
                }
              }}
              tooltip={`
                Clears the custom dropoff
                location. Reverse pods will
                instead dropoff at the
                selected bay.`}
              tooltipPosition="bottom"
            />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item maxHeight="20px">
            {REVERSE_OPTIONS.map((option, i) => (
              <Button
                disabled={!effectReverse}
                key={i}
                icon={option.icon}
                inline
                onClick={() =>
                  act('reverseOption', {
                    reverseOption: option.key || option.title,
                  })
                }
                selected={
                  option.key
                    ? reverse_option_list[option.key]
                    : reverse_option_list[option.title]
                }
                tooltip={option.title}
              />
            ))}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
}
