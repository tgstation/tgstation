import { sortBy } from 'common/collections';
import { Beaker } from './ChemDispenser';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type DispensableReagent = {
  title: string;
  id: string;
  volume: number;
  pH: number;
};

type Data = {
  amount: number;
  chemicals: DispensableReagent[];
  beaker: Beaker;
};

export const PortableChemMixer = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { beaker } = data;
  const beakerTransferAmounts = beaker ? beaker.transferAmounts : [];
  const beakerContents = beaker ? beaker.contents : [];
  const chemicals = sortBy((chem: DispensableReagent) => chem.id)(
    data.chemicals
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
              content={amount}
              onClick={() =>
                act('amount', {
                  target: amount,
                })
              }
            />
          ))}>
          <Box>
            {chemicals.map((chemical) => (
              <Button
                key={chemical.id}
                icon="tint"
                fluid
                lineHeight={1.75}
                content={`(${chemical.volume}) ${chemical.title}`}
                tooltip={'pH: ' + chemical.pH}
                onClick={() =>
                  act('dispense', {
                    reagent: chemical.id,
                  })
                }
              />
            ))}
          </Box>
        </Section>
        <Section
          title="Disposal Controls"
          buttons={beakerTransferAmounts.map((amount) => (
            <Button
              key={amount}
              icon="minus"
              content={amount}
              onClick={() => act('remove', { amount })}
            />
          ))}>
          <LabeledList>
            <LabeledList.Item
              label="Beaker"
              buttons={
                !!beaker && (
                  <Button
                    icon="eject"
                    content="Eject"
                    onClick={() => act('eject')}
                  />
                )
              }>
              {(!!beaker && (
                <>
                  <AnimatedNumber initial={0} value={beaker.currentVolume} />/
                  {beaker.maxVolume} units
                </>
              )) ||
                'No beaker'}
            </LabeledList.Item>
            <LabeledList.Item label="Contents">
              <Box color="label">
                {(!beaker && 'N/A') ||
                  (beakerContents.length === 0 && 'Nothing')}
              </Box>
              {beakerContents.map((chemical) => (
                <Box key={chemical.name} color="label">
                  <AnimatedNumber initial={0} value={chemical.volume} /> units
                  of {chemical.name}
                </Box>
              ))}
              {beakerContents.length > 0 && (
                <Box>
                  pH:
                  <AnimatedNumber value={beaker.pH} />
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
