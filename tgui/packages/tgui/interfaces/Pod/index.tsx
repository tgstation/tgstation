import { Stack } from '../../components';
import { Window } from '../../layouts';
import PartsDisplay from './PartsDisplay';
import PodDisplay from './PodDisplay';

export function Pod(_props: any): JSX.Element {
  return (
    <Window width={500} height={275} title="Pod Controls">
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={1.5}>
            <PodDisplay />
          </Stack.Item>
          <Stack.Item grow={2}>
            <PartsDisplay />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
