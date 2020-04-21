import { useBackend } from '../../backend';
import { Fragment } from 'inferno';
import { Box, Section, LabeledList, Button, AnimatedNumber } from '../../components';

export const PortableBasicInfo = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    connected,
    holding,
    on,
    pressure,
  } = data;

  return (
    <Fragment>
      <Section
        title="Status"
        buttons={(
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? 'On' : 'Off'}
            selected={on}
            onClick={() => act('power')} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <AnimatedNumber value={pressure} />
            {' kPa'}
          </LabeledList.Item>
          <LabeledList.Item
            label="Port"
            color={connected ? 'good' : 'average'}>
            {connected ? 'Connected' : 'Not Connected'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Holding Tank"
        minHeight="82px"
        buttons={(
          <Button
            icon="eject"
            content="Eject"
            disabled={!holding}
            onClick={() => act('eject')} />
        )}>
        {holding ? (
          <LabeledList>
            <LabeledList.Item label="Label">
              {holding.name}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <AnimatedNumber
                value={holding.pressure} />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="average">
            No holding tank
          </Box>
        )}
      </Section>
    </Fragment>
  );
};
