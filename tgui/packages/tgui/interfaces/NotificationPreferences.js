import { useBackend } from '../backend';
import { Section, Button } from '../components';

export const NotificationPreferences = props => {
  const { act, data } = useBackend(props);

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
    <Section title="Ghost Role Notifications">
      {ignores.map(ignore => (
        <Button
          fluid
          key={ignore.key}
          icon={ignore.enabled ? 'times' : 'check'}
          content={ignore.desc}
          color={ignore.enabled ? 'bad' : 'good'}
          onClick={() => act('toggle_ignore', { key: ignore.key })} />
      ))}
    </Section>
  );
};
