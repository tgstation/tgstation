import { useContext } from 'react';
import { Button, Icon, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { OrbitContext } from '.';
import { VIEWMODE } from './constants';
import { isJobCkeyOrNameMatch, sortByOrbiters } from './helpers';
import { OrbitData } from './types';

/** Search bar for the orbit ui. Has a few buttons to switch between view modes and auto-observe */
export function OrbitSearchBar(props) {
  const {
    autoObserve,
    bladeOpen,
    realNameDisplay,
    searchQuery,
    viewMode,
    setAutoObserve,
    setBladeOpen,
    setRealNameDisplay,
    setSearchQuery,
    setViewMode,
  } = useContext(OrbitContext);

  const { act, data } = useBackend<OrbitData>();

  /** Gets a list of Observables, then filters the most relevant to orbit */
  function orbitMostRelevant() {
    const mostRelevant = [
      data.alive,
      data.antagonists,
      data.critical,
      data.deadchat_controlled,
      data.dead,
      data.ghosts,
      data.misc,
      data.npcs,
    ]
      .flat()
      .filter((observable) => isJobCkeyOrNameMatch(observable, searchQuery))
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
    ([_key, value]) => value === viewMode,
  )?.[0];

  return (
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
            onChange={setSearchQuery}
            placeholder="Search..."
            value={searchQuery}
            expensive
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
        {!!data.can_observe && (
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
        )}
        <Stack.Item>
          <Button
            color="transparent"
            icon="sync-alt"
            onClick={() => act('refresh')}
            tooltip="Refresh"
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="passport"
            onClick={() => setRealNameDisplay(!realNameDisplay)}
            selected={realNameDisplay}
            tooltip="Toggle real name display. When active, you'll see real
            names instead of disguises in orbit menu."
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="sliders-h"
            onClick={() => setBladeOpen(!bladeOpen)}
            selected={bladeOpen}
            tooltip="Toggle settings blade"
            tooltipPosition="left-end"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
