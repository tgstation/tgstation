import { useBackend } from '../backend';
import { Button, Section, Stack } from '../components';
import { Window } from '../layouts';

export const CTFPanel = (context) => {
  const { act } = useBackend(context);
  return (
    <Window
      title="CTF Panel"
      width={390}
      height={200}>
      <Window.Content />
    </Window>
  );
};

