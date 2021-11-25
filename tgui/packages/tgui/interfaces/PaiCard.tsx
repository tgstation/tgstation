import { useBackend } from '../backend';
import { Window } from '../layouts';

type PaiCardData = {
  candidates: [];
  pai: PaiData;
};

type PaiData = {
  can_holo: number;
  dna: string;
  emagged: number;
  laws: string;
  master: string;
  name: string;
  transmit: number;
  receive: number;
};

export const PaiCard = (props, context) => {
  const { act, data } = useBackend<PaiCardData>(context);
  const { pai } = data;
  return (
    <Window width={400} height={400}>
      <Window.Content scrollable>
        {!pai ? <PaiDownload /> : <PaiOptions />}
      </Window.Content>
    </Window>
  );
};

const PaiDownload = (props, context) => {
  const { act, data } = useBackend<PaiCardData>(context);
  return 'Hello';
};

const PaiOptions = (props, context) => {
  const { act, data } = useBackend<PaiCardData>(context);
  const { pai } = data;
  return 'Hello';
};
