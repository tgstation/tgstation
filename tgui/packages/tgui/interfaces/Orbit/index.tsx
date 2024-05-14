import { useState } from 'react';
import { Button, Icon, Input, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { useBackend } from '../../backend';
import { VIEWMODE } from './constants';
import { isJobOrNameMatch, sortByOrbiters } from './helpers';
import { ObservableContent } from './ObservableContent';
import { OrbitData, ViewMode } from './types';

export function Orbit(props) {
  const { act, data } = useBackend<OrbitData>();

  const [autoObserve, setAutoObserve] = useState(false);
  const [viewMode, setViewMode] = useState<ViewMode>(VIEWMODE.Health);
  const [searchQuery, setSearchQuery] = useState('');

  /** Gets a list of Observables, then filters the most relevant to orbit */
  function orbitMostRelevant() {
    const mostRelevant = [
      data.alive,
      data.antagonists,
      data.deadchat_controlled,
      data.dead,
      data.ghosts,
      data.misc,
      data.npcs,
    ]
      .flat()
      .filter((observable) => isJobOrNameMatch(observable, searchQuery))
      .sort(sortByOrbiters)[0];

    if (mostRelevant !== undefined) {
      act('orbit', {
        ref: mostRelevant.ref,
        auto_observe: autoObserve,
      });
    }
  }

  /** Iterates through the view modes and switches to the next one */
  function swapViewMode() {
    const thisIndex = Object.values(VIEWMODE).indexOf(viewMode);
    const nextIndex = (thisIndex + 1) % Object.values(VIEWMODE).length;

    setViewMode(Object.values(VIEWMODE)[nextIndex]);
  }

  const viewModeTitle = Object.entries(VIEWMODE).find(
    ([key, value]) => value === viewMode,
  )?.[0];

  return (
    <Window title="Orbit" width={400} height={550}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item>
                  <Icon name="search" />
                </Stack.Item>
                <Stack.Item grow>
                  <Input
                    autoFocus
                    fluid
                    onEnter={orbitMostRelevant}
                    onInput={(event, value) => setSearchQuery(value)}
                    placeholder="Search..."
                    value={searchQuery}
                  />
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  <Button
                    color="transparent"
                    icon={viewMode}
                    onClick={swapViewMode}
                    tooltip={`Color scheme: ${viewModeTitle}`}
                    tooltipPosition="bottom-start"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    color={autoObserve ? 'good' : 'transparent'}
                    icon={autoObserve ? 'toggle-on' : 'toggle-off'}
                    onClick={() => setAutoObserve(!autoObserve)}
                    tooltip={`Toggle Auto-Observe. When active, you'll
            see the UI / full inventory of whoever you're orbiting. Neat!`}
                    tooltipPosition="bottom-start"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    color="transparent"
                    icon="sync-alt"
                    onClick={() => act('refresh')}
                    tooltip="Refresh"
                    tooltipPosition="bottom-start"
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item mt={0.2} grow>
            <Section fill>
              <ObservableContent
                autoObserve={autoObserve}
                searchQuery={searchQuery}
                viewMode={viewMode}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
