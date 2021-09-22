import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { Window } from '../layouts';

export const CTFPanel = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Window
      title="CTF Panel"
      width={650}
      height={580}>
      <Window.Content />
    </Window>
  );
};
