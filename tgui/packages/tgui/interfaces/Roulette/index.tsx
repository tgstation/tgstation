import { Window } from '../../layouts';
import { RouletteBetTable } from './BetTable';
import { RouletteBoard } from './Board';

export function Roulette(props) {
  return (
    <Window width={570} height={520} theme="cardtable">
      <Window.Content>
        <RouletteBoard />
        <RouletteBetTable />
      </Window.Content>
    </Window>
  );
}
