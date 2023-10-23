import { NtosWindow } from '../layouts';
import { CameraContent } from './CameraConsole';

export const NtosSecurEye = (props, context) => {
  return (
    <NtosWindow width={800} height={600}>
      <NtosWindow.Content>
        <CameraContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
