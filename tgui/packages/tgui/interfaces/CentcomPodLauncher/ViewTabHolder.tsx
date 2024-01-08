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
              color="transparent"
              icon="arrow-circle-down"
              inline
              onClick={() => {
                setTabPageIndex(2);
                act('tabSwitch', { tabIndex: 2 });
              }}
              selected={tabPageIndex === 2}
              tooltip="View Dropoff Location"
            />
          )}
          <Button
            color="transparent"
            icon="rocket"
            inline
            onClick={() => {
              setTabPageIndex(0);
              act('tabSwitch', { tabIndex: 0 });
            }}
            selected={tabPageIndex === 0}
            tooltip="View Pod"
          />
          <Button
            color="transparent"
            icon="th"
            inline
            onClick={() => {
              setTabPageIndex(1);
              act('tabSwitch', { tabIndex: 1 });
            }}
            selected={tabPageIndex === 1}
            tooltip="View Source Bay"
          />
          <span style={POD_GREY}>|</span>
          {!!customDropoff && !!effectReverse && (
            <Button
              color="transparent"
              icon="lightbulb"
              inline
              onClick={() => {
                act('renderLighting');
                act('refreshView');
              }}
              selected={renderLighting}
              tooltip="Render Lighting for the dropoff view"
            />
          )}
          <Button
            color="transparent"
            icon="sync-alt"
            inline
            onClick={() => {
              setTabPageIndex(tabPageIndex);
              act('refreshView');
            }}
            tooltip="Refresh view window in case it breaks"
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
