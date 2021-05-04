import { SignalerContent } from './Signaler';
import { NtosWindow } from '../layouts';

export const NtosSignaler = (props, context) => {
  return (
    <NtosWindow
      width={400}
      height={300}>
      <NtosWindow.Content scrollable>
        <SignalerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
