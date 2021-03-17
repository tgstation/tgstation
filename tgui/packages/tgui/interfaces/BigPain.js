import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const BigPain = (props, context) => {
  const { act, data } = useBackend(context);
  const { objects } = data;

  return (
    <Window
      width={640}
      height={420}>
      <Window.Content>
        hmm
        {Object.entries(objects)?.map(object => object.name)}
      </Window.Content>
    </Window>
  );
};
