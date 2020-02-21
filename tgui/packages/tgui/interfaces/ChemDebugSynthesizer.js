import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from '../components';

export const ChemDebugSynthesizer = props => {
  const { act, data } = useBackend(props);
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
            onClick={() => act('ejectBeaker')} />
          <NumberInput
            value={amount}
            unit="u"
            minValue={1}
            maxValue={beakerMaxVolume}
            step={1}
            stepPixelSize={2}
            onChange={(e, value) => act('amount', {
              amount: value,
            })} />
          <Button
            icon="plus"
            content="Input"
            onClick={() => act('input')} />
        </Fragment>
      ) : (
        <Button
          icon="plus"
          content="Create Beaker"
          onClick={() => act('makecup')} />
      )}>
      {isBeakerLoaded ? (
        <Fragment>
          <Box>
            <AnimatedNumber value={beakerCurrentVolume} />
            {' / ' + beakerMaxVolume + ' u'}
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
