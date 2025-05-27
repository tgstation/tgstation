import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  can_boo: BooleanLike;
  hud_info: HudInfo[];
  has_fun: BooleanLike;
  lag_switch_on: BooleanLike;
  notification_data: NotificationData[];
  max_extra_view: number;
  body_name: string;
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
  const { has_fun, can_boo } = data;
  return (
    <Window
      title="Ghost Menu"
      width={700}
      height={700}
      buttons={
        !!has_fun && (
          <>
            <Button
              disabled={!can_boo}
              tooltip="Haunts things near you, with a cooldown."
              onClick={() => act('boo')}
            >
              Boo!
            </Button>
            <Button
              tooltip="Allows you to possess any non-sentient mob."
              onClick={() => act('possess')}
            >
              Possess
            </Button>
          </>
        )
      }
    >
      <Window.Content>
        <Stack fill>
          <Stack.Item>
            <Section title="Player & Round Info">
              <RoundSection />
            </Section>
            <Section title="HUDs">
              <HudSection />
            </Section>
            <Section title="Ghost Settings">
              <GhostSettingsSection />
            </Section>
          </Stack.Item>
          <Stack.Item width="70%">
            <Section scrollable fill title="Ghost Role Notifications">
              <NotificationPreferences />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RoundSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { body_name } = data;
  return (
    <>
      {!!body_name && (
        <Box>
          {body_name}
          <Button
            tooltip="Returns you into your corpse."
            onClick={() => act('return_to_body')}
          >
            Enter Body
          </Button>
          <Button.Confirm
            tooltip="Become unable to be resusitated, permanently leaving your corpse behind."
            onClick={() => act('DNR')}
          >
            Leave Body
          </Button.Confirm>
        </Box>
      )}
      <Box>
        <Button onClick={() => act('crew_manifest')}>View Crew Manifest</Button>
      </Box>
      <Box>
        <Button onClick={() => act('signup_pai')}>Signup as pAI</Button>
      </Box>
    </>
  );
};

const HudSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { hud_info, lag_switch_on } = data;
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
      {!lag_switch_on && (
        <Button
          tooltip="Performs a t-ray scan where you are."
          onClick={() => act('tray_scan')}
        >
          T-ray Scan
        </Button>
      )}
    </>
  );
};

const GhostSettingsSection = (props) => {
  const [viewNumber, setviewNumber] = useState<number>(0);
  const { act, data } = useBackend<Data>();
  const { current_darkness, darkness_levels, max_extra_view, lag_switch_on } =
    data;
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
      <Button
        tooltip="Restores your ghost character's appearance and username to that in your character preferences."
        onClick={() => act('restore_appearance')}
      >
        Restore Ghost Character
      </Button>
      {!lag_switch_on && (
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
      )}
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
