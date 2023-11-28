import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {};

export const AntagInfoSpy = (props, context) => {
  const { data } = useBackend<Data>(context);
  return (
    <Window width={620} height={580} theme={'neutral'}>
      <Window.Content>hello</Window.Content>
    </Window>
  );
};
