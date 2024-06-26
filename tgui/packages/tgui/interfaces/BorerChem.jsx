// THIS IS A MONKESTATION UI FILE

import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const BorerChem = (props) => {
  const { act, data } = useBackend();
  const borerTransferAmounts = data.borerTransferAmounts || [];
  return (
    <Window width={565} height={400} title="Injector" theme="wizard">
      <Window.Content scrollable>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Storage">
              <ProgressBar value={data.energy / data.maxEnergy}>
                {toFixed(data.energy) + ' units'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Inject"
          buttons={borerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="plus"
              selected={amount === data.amount}
              content={amount}
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            />
          ))}
        >
          <Box mr={-1}>
            {data.chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                width="129.5px"
                lineHeight={1.75}
                content={chemical.title}
                disabled={data.onCooldown || data.notEnoughChemicals}
                onClick={() =>
                  act('inject', {
                    // reagent: chemical.title, REQUIRES PR #78637?
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
