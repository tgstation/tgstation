import { useContext } from 'react';
import {
  Button,
  Icon,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { capitalizeFirst, toTitleCase } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { OrbitContext } from '.';
import { HEALTH, VIEWMODE } from './constants';
import { getDepartmentByJob, getDisplayName } from './helpers';
import { JobIcon } from './JobIcon';
import { OrbitData } from './types';

/** Slide open menu with more info about the current observable */
export function OrbitBlade(props) {
  const { data } = useBackend<OrbitData>();
  const { orbiting } = data;

  const { setBladeOpen, realNameDisplay, setRealNameDisplay } =
    useContext(OrbitContext);

  return (
    <Stack vertical width="244px">
      <Stack.Item>
        <Section
          buttons={
            <Button
              color="bad"
              icon="times"
              onClick={() => setBladeOpen(false)}
            />
          }
          color="label"
          title="Orbit Settings"
        >
          Keep in mind: Orbit does not update automatically. You will need to
          click the &quot;Refresh&quot; button to see the latest data.
        </Section>
      </Stack.Item>
      <Stack.Item>
        <ViewModeSelector />
      </Stack.Item>
      <Stack.Item>
        <Section
          buttons={
            <Button
              color="transparent"
              icon="passport"
              selected={realNameDisplay}
              onClick={() => setRealNameDisplay(!realNameDisplay)}
            />
          }
          color="label"
          title="Real Name Display"
        >
          Real Name mode will display actual character names and their
          roundstart jobs insteas of being based on their worn ID. If the person
          lacks a roundstart job, it will still display their ID job icon.
        </Section>
      </Stack.Item>
      {!!orbiting && (
        <Stack.Item>
          <OrbitInfo />
        </Stack.Item>
      )}
    </Stack>
  );
}

function ViewModeSelector(props) {
  const { viewMode, setViewMode } = useContext(OrbitContext);

  return (
    <Section title="View Mode">
      <Stack fill vertical>
        <Stack.Item color="label">
          Change the color and sorting scheme of observable items.
        </Stack.Item>

        {Object.entries(VIEWMODE).map(([key, value]) => (
          <Button
            align="center"
            color="transparent"
            fluid
            icon={value}
            key={key}
            onClick={() => setViewMode(value)}
            selected={value === viewMode}
          >
            {key}
          </Button>
        ))}
      </Stack>
    </Section>
  );
}

function OrbitInfo(props) {
  const { data } = useBackend<OrbitData>();

  const { orbiting } = data;
  if (!orbiting) return;

  const { name, full_name, health, job } = orbiting;

  let department;
  if ('job' in orbiting && !!job) {
    department = getDepartmentByJob(job);
  }

  let showAFK;
  if ('client' in orbiting && !orbiting.client) {
    showAFK = true;
  }

  return (
    <Section title="Orbiting">
      <Stack fill vertical>
        <Stack.Item>
          {toTitleCase(getDisplayName(full_name, name))}
          {showAFK && (
            <Tooltip content="Away from keyboard" position="bottom-start">
              <Icon ml={1} color="grey" name="bed" />
            </Tooltip>
          )}
        </Stack.Item>

        {!!job && (
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <JobIcon item={orbiting} realNameDisplay={false} />
              </Stack.Item>
              <Stack.Item color="label" grow>
                {job}
              </Stack.Item>
              {!!department && (
                <Stack.Item color="grey">
                  {capitalizeFirst(department)}
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        )}
        {health !== undefined && (
          <Stack.Item>
            <HealthDisplay health={health} />
          </Stack.Item>
        )}

        <Stack.Item />
      </Stack>
    </Section>
  );
}

function HealthDisplay(props: { health: number }) {
  const { health } = props;

  let icon = 'heart';
  let howDead;
  switch (true) {
    case health <= HEALTH.Ruined:
      howDead = `Very Dead: ${health}`;
      icon = 'skull';
      break;
    case health <= HEALTH.Dead:
      howDead = `Dead: ${health}`;
      icon = 'heart-broken';
      break;
    case health <= HEALTH.Crit:
      howDead = `Health critical: ${health}`;
      icon = 'tired';
      break;
    case health <= HEALTH.Bad:
      howDead = `Bad: ${health}`;
      icon = 'heartbeat';
      break;
  }

  return (
    <Stack align="center">
      <Stack.Item>
        <Icon color="grey" name={icon} />
      </Stack.Item>
      <Stack.Item color={howDead && 'bad'} grow>
        {howDead || (
          <ProgressBar
            maxValue={100}
            minValue={0}
            ranges={{
              good: [70, Infinity],
              average: [20, HEALTH.Good],
              bad: [0, HEALTH.Average],
            }}
            value={health}
          />
        )}
      </Stack.Item>
    </Stack>
  );
}
