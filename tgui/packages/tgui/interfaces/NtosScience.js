import { Techweb } from './Techweb.js';
import { NtosWindow } from '../layouts';

export const NtosScience = (props, context) => {
  return (
    <NtosWindow
      width={690}
      height={785}>
      <NtosWindow.Content scrollable>
        <Techweb />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
