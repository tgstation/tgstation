import { NtosWindow, Window } from '../../layouts';
import { TechwebStart } from './Start';

export function Techweb(props) {
  return (
    <Window width={640} height={735}>
      <Window.Content>
        <TechwebStart />
      </Window.Content>
    </Window>
  );
}

export function AppTechweb(props) {
  return (
    <NtosWindow width={640} height={735}>
      <NtosWindow.Content>
        <TechwebStart />
      </NtosWindow.Content>
    </NtosWindow>
  );
}
