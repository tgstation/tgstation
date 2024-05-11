import { useState } from 'react';
import { Button, Icon, Input, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { useBackend } from '../../backend';
import { getMostRelevant } from './helpers';
import { ObservableContent } from './ObservableContent';
import { OrbitData } from './types';

export function Orbit(props) {
  const { act, data } = useBackend<OrbitData>();
  const {
    alive = [],
    antagonists = [],
    deadchat_controlled = [],
    dead = [],
    ghosts = [],
    misc = [],
    npcs = [],
  } = data;

  const [autoObserve, setAutoObserve] = useState(false);
  const [heatMap, setHeatMap] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  /** Gets a list of Observables, then filters the most relevant to orbit */
  function orbitMostRelevant(searchQuery: string) {
    const mostRelevant = getMostRelevant(searchQuery, [
      alive,
      antagonists,
      deadchat_controlled,
      dead,
      ghosts,
      misc,
      npcs,
    ]);

    if (mostRelevant !== undefined) {
      act('orbit', {
        ref: mostRelevant.ref,
        auto_observe: autoObserve,
      });
    }
  }

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
                    onEnter={(event, value) => orbitMostRelevant(value)}
                    onInput={(event, value) => setSearchQuery(value)}
                    placeholder="Search..."
                    value={searchQuery}
                  />
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  <Button
                    color="transparent"
                    icon={!heatMap ? 'heart' : 'ghost'}
                    onClick={() => setHeatMap(!heatMap)}
                    tooltip={`Toggles between highlighting health or
            orbiters.`}
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
                heatMap={heatMap}
                searchQuery={searchQuery}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
