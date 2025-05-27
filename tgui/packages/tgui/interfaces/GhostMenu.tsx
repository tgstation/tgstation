import { Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  hud_info: HudInfo[];
  has_fun: BooleanLike;
  lag_switch_on: BooleanLike;
  notification_data: NotificationData[];
};

type HudInfo = {
  name: string;
  enabled: BooleanLike;
  flag: string;
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
          fluid
          key={individual_hud.name}
          icon={individual_hud.enabled ? 'check' : 'times'}
          color={individual_hud.enabled ? 'good' : 'bad'}
          onClick={() =>
            act('toggle_visibility', { toggling: individual_hud.flag })
          }
        >
          {individual_hud.name}
        </Button>
      ))}
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
