import { sortBy } from 'common/collections';
import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Beaker, BeakerDisplay } from './common/BeakerDisplay';

type DispensableReagent = {
  title: string;
  id: string;
  volume: number;
  pH: number;
};

type TransferableBeaker = Beaker & {
  transferAmounts: number[];
};

type Data = {
  amount: number;
  chemicals: DispensableReagent[];
  beaker: TransferableBeaker;
};

export const PortableChemMixer = (props) => {
  const { act, data } = useBackend<Data>();
  const { beaker } = data;
  const beakerTransferAmounts = beaker ? beaker.transferAmounts : [];
  const chemicals = sortBy(
    data.chemicals,
    (chem: DispensableReagent) => chem.id,
  );
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        <Section
          title="Dispense Controls"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="plus"
              selected={amount === data.amount}
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            >
              {amount}
            </Button>
          ))}
        >
          <Box>
            {chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                fluid
                lineHeight={1.75}
                tooltip={'pH: ' + chemical.pH}
                onClick={() =>
                  act('dispense', {
                    reagent: chemical.id,
                  })
                }
              >
                {`(${chemical.volume}) ${chemical.title}`}
              </Button>
            ))}
          </Box>
        </Section>
        <Section
          title="Disposal Controls"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="minus"
              onClick={() => act('remove', { amount })}
            >
              {amount}
            </Button>
          ))}
        >
          <BeakerDisplay beaker={beaker} showpH />
        </Section>
      </Window.Content>
    </Window>
  );
};
