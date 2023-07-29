import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { MainData } from './data';
import { OperatorMode } from './OperatorMode';

export const Mecha = (props, context) => {
  const { data } = useBackend<MainData>(context);
  return (
    <Window theme={data.ui_theme} width={800} height={550}>
      <Window.Content>
        <OperatorMode />
      </Window.Content>
    </Window>
  );
};
