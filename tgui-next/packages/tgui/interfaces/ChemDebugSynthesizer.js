import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Box, Button, LabeledList, Section } from '../components';
import { NumberInput } from '../components/NumberInput';

export const ChemDebugSynthesizer = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    amount,
    beakerCurrentVolume,
    beakerMaxVolume,
    isBeakerLoaded,
    beakerContents = [],
  } = data;
  return (
    <Section
      title="Recipient"
      buttons={isBeakerLoaded ? (
        <Fragment>
          <Button
            icon="eject"
            content="Eject"
            onClick={() => act(ref, 'ejectBeaker')}
          />
          <NumberInput
            value={amount}
            unit="u"
            minValue={1}
            maxValue={beakerMaxVolume}
            step={1}
            stepPixelSize={2}
            onChange={(e, value) => act(ref, 'amount', {
              amount: value,
            })} />
          <Button
            icon="plus"
            content="Input"
            onClick={() => act(ref, 'input')} />
        </Fragment>
      ) : (
        <Button
          icon="plus"
          content="Create Beaker"
          onClick={() => act(ref, 'makecup')} />
      )}>
      {isBeakerLoaded ? (
        <Fragment>
          <Box>
            <Box inline>
              <AnimatedNumber
                value={beakerCurrentVolume}
              />
            </Box>
            /
            <Box inline>
              {beakerMaxVolume} u
            </Box>
          </Box>
          {beakerContents.length > 0 ? (
            <LabeledList>
              {beakerContents.map(chem => (
                <LabeledList.Item
                  key={chem.name}
                  label={chem.name}>
                  {chem.volume} u
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            <Box color="bad">
              Recipient Empty
            </Box>
          )}
        </Fragment>
      ) : (
        <Box color="average">
          No Recipient
        </Box>
      )}
    </Section>
  );
};
