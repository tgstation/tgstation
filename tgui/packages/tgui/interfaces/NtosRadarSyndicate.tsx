import { NtosWindow } from '../layouts';
import { NtosRadarContent } from './NtosRadar';

export const NtosRadarSyndicate = () => {
  return (
    <NtosWindow width={800} height={600} theme="syndicate">
      <NtosRadarContent sig_err={'Out of Range'} />
    </NtosWindow>
  );
};
