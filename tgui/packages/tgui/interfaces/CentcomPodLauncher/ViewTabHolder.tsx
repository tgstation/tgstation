import { useState } from 'react';

import { useBackend } from '../../backend';
import { Button, ByondUi, Section, Stack } from '../../components';
import { POD_GREY, TABPAGES } from './constants';
import { PodLauncherData } from './types';

export function ViewTabHolder(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { mapRef, customDropoff, effectReverse, renderLighting } = data;

  const [tabPageIndex, setTabPageIndex] = useState(1);

  const TabPageComponent = TABPAGES[tabPageIndex].component;

  return (
    <Section
      fill
      title="View"
      buttons={
        <>
          {!!customDropoff && effectReverse === 1 && (
            <Button
              inline
              color="transparent"
              tooltip="View Dropoff Location"
              icon="arrow-circle-down"
              selected={tabPageIndex === 2}
              onClick={() => {
                setTabPageIndex(2);
                act('tabSwitch', { tabIndex: 2 });
              }}
            />
          )}
          <Button
            inline
            color="transparent"
            tooltip="View Pod"
            icon="rocket"
            selected={tabPageIndex === 0}
            onClick={() => {
              setTabPageIndex(0);
              act('tabSwitch', { tabIndex: 0 });
            }}
          />
          <Button
            inline
            color="transparent"
            tooltip="View Source Bay"
            icon="th"
            selected={tabPageIndex === 1}
            onClick={() => {
              setTabPageIndex(1);
              act('tabSwitch', { tabIndex: 1 });
            }}
          />
          <span style={POD_GREY}>|</span>
          {!!customDropoff && effectReverse === 1 && (
            <Button
              inline
              color="transparent"
              icon="lightbulb"
              selected={renderLighting}
              tooltip="Render Lighting for the dropoff view"
              onClick={() => {
                act('renderLighting');
                act('refreshView');
              }}
            />
          )}
          <Button
            inline
            color="transparent"
            icon="sync-alt"
            tooltip="Refresh view window in case it breaks"
            onClick={() => {
              setTabPageIndex(tabPageIndex);
              act('refreshView');
            }}
          />
        </>
      }
    >
      <Stack fill vertical>
        <Stack.Item>
          <TabPageComponent />
        </Stack.Item>
        <Stack.Item grow>
          <ByondUi
            height="100%"
            params={{
              zoom: 0,
              id: mapRef,
              type: 'map',
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
