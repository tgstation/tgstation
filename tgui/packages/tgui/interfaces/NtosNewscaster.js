import { NtosWindow } from '../layouts';
import { Newscaster } from './Newscaster';

export const NtosNewscaster = (props, context) => {
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <Newscaster />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
