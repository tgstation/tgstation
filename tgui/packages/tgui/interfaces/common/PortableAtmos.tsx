import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';

type StoredTank = {
  name: string;
  pressure: number;
};

export type PortableBasicInfoData = {
  connected: boolean;
  holding: StoredTank | null;
  on: boolean;
  pressure: number;
  hasHypernobCrystal: boolean;
  reactionSuppressionEnabled: boolean;
};

export const PortableBasicInfo = (props) => {
  const { act, data } = useBackend<PortableBasicInfoData>();
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
            selected={on}
            onClick={() => act('power')}
          >
            {on ? 'On' : 'Off'}
          </Button>
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
                icon={reactionSuppressionEnabled ? 'snowflake' : 'times'}
                selected={reactionSuppressionEnabled}
                onClick={() => act('reaction_suppression')}
              >
                {reactionSuppressionEnabled ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      <Section
        title="Holding Tank"
        minHeight="82px"
        buttons={
          <Button icon="eject" disabled={!holding} onClick={() => act('eject')}>
            Eject
          </Button>
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
