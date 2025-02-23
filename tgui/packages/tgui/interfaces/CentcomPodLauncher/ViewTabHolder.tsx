import { Button, ByondUi, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { POD_GREY, TABPAGES } from './constants';
import { useTab } from './hooks';
import { PodLauncherData } from './types';

export function ViewTabHolder(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { mapRef, customDropoff, effectReverse, renderLighting } = data;

  const [tab, setTab] = useTab();

  const TabPageComponent = TABPAGES[tab].component;

  return (
    <Section
      buttons={
        <>
          {!!customDropoff && !!effectReverse && (
            <Button
              color="transparent"
              icon="arrow-circle-down"
              inline
              onClick={() => {
                setTab(2);
                act('tabSwitch', { tabIndex: 2 });
              }}
              selected={tab === 2}
              tooltip="View Dropoff Location"
            />
          )}
          <Button
            color="transparent"
            icon="rocket"
            inline
            onClick={() => {
              setTab(0);
              act('tabSwitch', { tabIndex: 0 });
            }}
            selected={tab === 0}
            tooltip="View Pod"
          />
          <Button
            color="transparent"
            icon="th"
            inline
            onClick={() => {
              setTab(1);
              act('tabSwitch', { tabIndex: 1 });
            }}
            selected={tab === 1}
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
              setTab(tab);
              act('refreshView');
            }}
            tooltip="Refresh view window in case it breaks"
          />
        </>
      }
      fill
      title="View"
    >
      <Stack fill vertical>
        <Stack.Item>
          <TabPageComponent />
        </Stack.Item>
        <Stack.Item grow>
          <ByondUi
            height="100%"
            params={{
              id: mapRef,
              type: 'map',
              zoom: 0,
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
