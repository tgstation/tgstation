import { Box, Button, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  amount: number;
  current_reagent: string;
  chemicals: { id: string; title: string }[];
  possible_amounts: number[];
};

export const ChemSynthesizer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    amount,
    current_reagent,
    chemicals = [],
    possible_amounts = [],
  } = data;

  return (
    <Window width={300} height={375}>
      <Window.Content>
        <Section>
          <Box>
            {possible_amounts.map((possible_amount) => (
              <Button
                icon="plus"
                key={toFixed(possible_amount, 0)}
                content={toFixed(possible_amount, 0)}
                selected={possible_amount === amount}
                onClick={() =>
                  act('amount', {
                    target: possible_amount,
                  })
                }
              />
            ))}
          </Box>
          <Box mt={1}>
            {chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                content={chemical.title}
                width="129px"
                selected={chemical.id === current_reagent}
                onClick={() =>
                  act('select', {
                    reagent: chemical.id,
                  })
                }
              />
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
