import { useState } from 'react';
import { Button, Section } from 'tgui-core/components';

import { AirAlarmControlHome } from './screens/Home';
import { AirAlarmControlModes } from './screens/Modes';
import { AirAlarmControlScrubbers } from './screens/Scrubbers';
import { AirAlarmControlThresholds } from './screens/Thresholds';
import { AirAlarmControlVents } from './screens/Vents';
import type { AlarmScreen } from './types';

export const AIR_ALARM_ROUTES = {
  home: {
    title: 'Air Controls',
    component: AirAlarmControlHome,
  },
  vents: {
    title: 'Vent Controls',
    component: AirAlarmControlVents,
  },
  scrubbers: {
    title: 'Scrubber Controls',
    component: AirAlarmControlScrubbers,
  },
  modes: {
    title: 'Operating Mode',
    component: AirAlarmControlModes,
  },
  thresholds: {
    title: 'Alarm Thresholds',
    component: AirAlarmControlThresholds,
  },
} as const;

export function AirAlarmControl(props) {
  const [screen, setScreen] = useState<AlarmScreen>('home');

  const route = AIR_ALARM_ROUTES[screen] || AIR_ALARM_ROUTES.home;
  const Component = route.component;
  const isHome = route.title === 'Air Controls';

  return (
    <Section
      fill
      scrollable
      title={route.title}
      buttons={
        <Button
          icon="arrow-left"
          onClick={() => setScreen('home')}
          disabled={isHome}
        >
          Back
        </Button>
      }
    >
      <Component {...(isHome && { setScreen })} />
    </Section>
  );
}
