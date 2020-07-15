import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const ChemSynthesizer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    amount,
    current_reagent,
    chemicals = [],
    possible_amounts = [],
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section>
          <Box>
            {possible_amounts.map(possible_amount => (
              <Button
                icon="plus"
                key={toFixed(possible_amount, 0)}
                content={toFixed(possible_amount, 0)}
                selected={possible_amount === amount}
                onClick={() => act('amount', {
                  target: possible_amount,
                })} />
            ))}
          </Box>
          <Box mt={1}>
            {chemicals.map(chemical => (
              <Button
                key={chemical.id}
                icon="tint"
                content={chemical.title}
                width="129px"
                selected={chemical.id === current_reagent}
                onClick={() => act('select', {
                  reagent: chemical.id,
                })} />
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
