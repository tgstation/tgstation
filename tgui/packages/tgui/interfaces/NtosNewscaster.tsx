import { NtosWindow } from '../layouts';
import { Newscaster } from './Newscaster';

export const NtosNewscaster = () => {
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <Newscaster />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
