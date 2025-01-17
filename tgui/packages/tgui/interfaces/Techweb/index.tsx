import { NtosWindow, Window } from '../../layouts';
import { TechwebStart } from './Start';

export function Techweb(props) {
  return (
    <Window width={640} height={735}>
      <Window.Content scrollable>
        <TechwebStart />
      </Window.Content>
    </Window>
  );
}

export function AppTechweb(props) {
  return (
    <NtosWindow width={640} height={735}>
      <NtosWindow.Content scrollable>
        <TechwebStart />
      </NtosWindow.Content>
    </NtosWindow>
  );
}
