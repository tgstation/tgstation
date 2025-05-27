import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  hud_info: HudInfo[];
  has_fun: BooleanLike;
  lag_switch_on: BooleanLike;
  notification_data: NotificationData[];
  max_extra_view: number;
  current_darkness: string;
  darkness_levels: string[];
};

type HudInfo = {
  name: string;
  enabled: BooleanLike;
  flag: string;
  tooltip: string;
};

type NotificationData = {
  key: string;
  enabled: BooleanLike;
  desc: string;
};

export const GhostMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_fun, lag_switch_on } = data;
  return (
    <Window title="Ghost Menu" width={500} height={360}>
      <Window.Content scrollable>
        {!!has_fun && (
          <Section title="Fun Buttons">
            <FunSection />
          </Section>
        )}
        <Section title="HUDs">
          <HudSection />
        </Section>
        <Section title="Ghost Settings">
          <GhostSettingsSection />
        </Section>
        {!!lag_switch_on && <Section>Lag Switch enabled!</Section>}
        <Section title="Ghost Role Notifications">
          <NotificationPreferences />
        </Section>
      </Window.Content>
    </Window>
  );
};

const FunSection = (props) => {
  const { act } = useBackend<Data>();
  return (
    <>
      <Button onClick={() => act('boo')}>Boo!</Button>
      <Button onClick={() => act('possess')}>Possess</Button>
    </>
  );
};

const HudSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { hud_info } = data;
  return (
    <>
      {hud_info.map((individual_hud) => (
        <Button
          key={individual_hud.name}
          icon={individual_hud.enabled ? 'check' : 'times'}
          color={individual_hud.enabled ? 'good' : 'bad'}
          tooltip={individual_hud.tooltip}
          onClick={() =>
            act('toggle_visibility', { toggling: individual_hud.flag })
          }
        >
          {individual_hud.name}
        </Button>
      ))}
      <Button
        tooltip="Performs a t-ray scan where you are."
        onClick={() => act('tray_scan')}
      >
        T-ray Scan
      </Button>
    </>
  );
};

const GhostSettingsSection = (props) => {
  const [viewNumber, setviewNumber] = useState<number>(0);
  const { act, data } = useBackend<Data>();
  const { current_darkness, darkness_levels, max_extra_view } = data;
  return (
    <>
      <Box>
        <Dropdown
          options={darkness_levels}
          selected={current_darkness}
          onSelected={(value) =>
            act('darkness', {
              darkness_level: value,
            })
          }
        />
      </Box>
      <Box>
        Extra View size:
        <NumberInput
          width="30px"
          step={1}
          value={viewNumber}
          minValue={0}
          maxValue={max_extra_view}
          onDrag={(newValue) => setviewNumber(newValue)}
          onChange={(new_range) =>
            act('view_range', {
              new_view_range: new_range,
            })
          }
        />
      </Box>
    </>
  );
};

const NotificationPreferences = (props) => {
  const { act, data } = useBackend<Data>();
  const { notification_data } = data;
  if (!notification_data) {
    return 'No notifications!';
  }

  const ignores = notification_data.sort((a, b) => {
    const descA = a.desc.toLowerCase();
    const descB = b.desc.toLowerCase();
    if (descA < descB) {
      return -1;
    }
    if (descA > descB) {
      return 1;
    }
    return 0;
  });

  return (
    <>
      {ignores.map((ignore) => (
        <Button
          fluid
          key={ignore.key}
          icon={ignore.enabled ? 'times' : 'check'}
          color={ignore.enabled ? 'bad' : 'good'}
          onClick={() => act('change_notification', { key: ignore.key })}
        >
          {ignore.desc}
        </Button>
      ))}
    </>
  );
};
