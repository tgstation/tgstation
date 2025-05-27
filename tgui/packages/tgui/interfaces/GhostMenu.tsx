import { Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  notification_data: NotificationData[];
};

type NotificationData = {
  key: string;
  enabled: BooleanLike;
  desc: string;
};

export const GhostMenu = (props) => {
  <Window>
    <Window.Content>
      <NotificationPreferences />;
    </Window.Content>
  </Window>;
};

const NotificationPreferences = (props) => {
  const { act, data } = useBackend<Data>();
  const { notification_data } = data;
  if (!notification_data) {
    return <Section>No notifications!</Section>;
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
    <Section title="Ghost Role Notifications">
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
    </Section>
  );
};
