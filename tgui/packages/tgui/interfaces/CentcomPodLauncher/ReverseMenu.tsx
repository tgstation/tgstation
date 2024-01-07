import { multiline } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../../backend';
import { Button, Section, Stack } from '../../components';
import { REVERSE_OPTIONS } from './constants';
import { PodLauncherData } from './types';

export function ReverseMenu(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { customDropoff, effectReverse, picking_dropoff_turf } = data;

  const [tabPageIndex, setTabPageIndex] = useState(1);

  return (
    <Section
      fill
      title="Reverse"
      buttons={
        <Button
          icon={effectReverse === 1 ? 'toggle-on' : 'toggle-off'}
          selected={effectReverse}
          tooltip={multiline`
            Doesn't send items.
            Afer landing, returns to
            dropoff turf (or bay
            if none specified).`}
          tooltipPosition="top-start"
          onClick={() => {
            act('effectReverse');
            if (tabPageIndex === 2) {
              setTabPageIndex(1);
              act('tabSwitch', { tabIndex: 1 });
            }
          }}
        />
      }
    >
      {effectReverse === 1 && (
        <Stack fill vertical>
          <Stack.Item maxHeight="20px">
            <Button
              selected={picking_dropoff_turf}
              disabled={!effectReverse}
              tooltip={multiline`
                Where reverse pods
                go after landing`}
              tooltipPosition="bottom-end"
              onClick={() => act('pickDropoffTurf')}
            >
              Dropoff Turf
            </Button>
            <Button
              inline
              icon="trash"
              disabled={!customDropoff}
              tooltip={multiline`
                Clears the custom dropoff
                location. Reverse pods will
                instead dropoff at the
                selected bay.`}
              tooltipPosition="bottom"
              onClick={() => {
                act('clearDropoffTurf');
                if (tabPageIndex === 2) {
                  setTabPageIndex(1);
                  act('tabSwitch', { tabIndex: 1 });
                }
              }}
            />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item maxHeight="20px">
            {REVERSE_OPTIONS.map((option, i) => (
              <Button
                key={i}
                inline
                icon={option.icon}
                disabled={!effectReverse}
                selected={
                  option.key
                    ? reverse_option_list[option.key]
                    : reverse_option_list[option.title]
                }
                tooltip={option.title}
                onClick={() =>
                  act('reverseOption', {
                    reverseOption: option.key ? option.key : option.title,
                  })
                }
              />
            ))}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
}
