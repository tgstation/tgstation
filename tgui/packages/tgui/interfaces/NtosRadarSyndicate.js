import { NtosWindow } from '../layouts';
import { NtosRadarContent } from './NtosRadar';

export const NtosRadarSyndicate = (props, context) => {
  return (
    <NtosWindow
      width={800}
      height={600}
      theme="syndicate">
      <NtosRadarContent />
    </NtosWindow>
  );
};
