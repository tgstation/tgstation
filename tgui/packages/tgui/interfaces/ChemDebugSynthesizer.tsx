import { Beaker } from './ChemDispenser';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, NumberInput, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  amount: number;
  purity: number;
  beaker: Beaker;
};

export const ChemDebugSynthesizer = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { amount, purity, beaker } = data;
  const beakerContents = beaker?.contents || [];

  return (
    <Window width={390} height={330}>
      <Window.Content scrollable>
        <Section
          title="Recipient"
          buttons={
            beaker ? (
              <>
                <Button
                  icon="eject"
                  content="Eject"
                  onClick={() => act('ejectBeaker')}
                />
                <NumberInput
                  value={amount}
                  unit="u"
                  minValue={1}
                  maxValue={beaker.maxVolume}
                  step={1}
                  stepPixelSize={2}
                  onChange={(e, value) =>
                    act('amount', {
                      amount: value,
                    })
                  }
                />
                <NumberInput
                  value={purity}
                  unit="%"
                  minValue={0}
                  maxValue={120}
                  step={1}
                  stepPixelSize={2}
                  onChange={(e, value) =>
                    act('purity', {
                      amount: value,
                    })
                  }
                />
                <Button
                  icon="plus"
                  content="Input"
                  onClick={() => act('input')}
                />
              </>
            ) : (
              <Button
                icon="plus"
                content="Create Beaker"
                onClick={() => act('makecup')}
              />
            )
          }>
          {
            <LabeledList>
              <LabeledList.Item label="Beaker">
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
          }
        </Section>
      </Window.Content>
    </Window>
  );
};
