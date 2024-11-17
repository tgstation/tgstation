import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';

export const PortableBasicInfo = (props) => {
  const { act, data } = useBackend();
  const {
    connected,
    holding,
    on,
    pressure,
    hasHypernobCrystal,
    reactionSuppressionEnabled,
  } = data;
  return (
    <>
      <Section
        title="Status"
        buttons={
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? 'On' : 'Off'}
            selected={on}
            onClick={() => act('power')}
          />
        }
      >
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <AnimatedNumber value={pressure} />
            {' kPa'}
          </LabeledList.Item>
          <LabeledList.Item label="Port" color={connected ? 'good' : 'average'}>
            {connected ? 'Connected' : 'Not Connected'}
          </LabeledList.Item>
          {!!hasHypernobCrystal && (
            <LabeledList.Item label="Reaction Suppression">
              <Button
                icon={data.reactionSuppressionEnabled ? 'snowflake' : 'times'}
                content={
                  data.reactionSuppressionEnabled ? 'Enabled' : 'Disabled'
                }
                selected={data.reactionSuppressionEnabled}
                onClick={() => act('reaction_suppression')}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      <Section
        title="Holding Tank"
        minHeight="82px"
        buttons={
          <Button
            icon="eject"
            content="Eject"
            disabled={!holding}
            onClick={() => act('eject')}
          />
        }
      >
        {holding ? (
          <LabeledList>
            <LabeledList.Item label="Label">{holding.name}</LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <AnimatedNumber value={holding.pressure} />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="average">No holding tank</Box>
        )}
      </Section>
    </>
  );
};
