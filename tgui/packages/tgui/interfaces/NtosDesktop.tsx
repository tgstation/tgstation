import { Section } from 'tgui-core/components';
import { NtosWindow } from '../layouts';

export const NtosDesktop = (props) => {
  return (
    <NtosWindow width={600} height={640}>
      <NtosWindow.Content scrollable>
        <Section title="Ntos Desktop" />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
