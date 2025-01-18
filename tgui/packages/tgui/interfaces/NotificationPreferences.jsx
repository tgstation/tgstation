import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const NotificationPreferences = (props) => {
  const { act, data } = useBackend();
  const ignoresPreSort = data.ignore || [];
  const ignores = ignoresPreSort.sort((a, b) => {
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
    <Window title="Notification Preferences" width={270} height={360}>
      <Window.Content scrollable>
        <Section title="Ghost Role Notifications">
          {ignores.map((ignore) => (
            <Button
              fluid
              key={ignore.key}
              icon={ignore.enabled ? 'times' : 'check'}
              content={ignore.desc}
              color={ignore.enabled ? 'bad' : 'good'}
              onClick={() => act('toggle_ignore', { key: ignore.key })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
