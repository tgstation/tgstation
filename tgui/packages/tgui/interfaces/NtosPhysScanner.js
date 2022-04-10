/* eslint-disable max-len */
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Section } from '../components';

export const NtosPhysScanner = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    set_mode,
  } = data;
  return (
    <NtosWindow
      width={600}
      height={350}>
      <NtosWindow.Content scrollable>
        <Section>
          Tap something (right-click) with your tablet to use the physical scanner. The scanner is currently set to: {set_mode}.
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
