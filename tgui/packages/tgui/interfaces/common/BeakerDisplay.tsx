import { BooleanLike } from 'common/react';
import { AnimatedNumber, Box, Button, LabeledList } from '../../components';
import { useBackend } from '../../backend';

type BeakerReagent = {
  name: string;
  volume: number;
};

export type Beaker = {
  maxVolume: number;
  transferAmounts: number[];
  pH: number;
  currentVolume: number;
  contents: BeakerReagent[];
};

type BeakerProps = {
  beaker: Beaker;
  replace_contents?: BeakerReagent[];
  title_label?: string;
  showpH?: BooleanLike;
};

export const BeakerDisplay = (props: BeakerProps, context) => {
  const { act } = useBackend(context);
  const { beaker, replace_contents, title_label, showpH } = props;
  const beakerContents = replace_contents || beaker?.contents || [];

  return (
    <LabeledList>
      <LabeledList.Item
        label="Beaker"
        buttons={
          !!beaker && (
            <Button icon="eject" content="Eject" onClick={() => act('eject')} />
          )
        }>
        {title_label ||
          (!!beaker && (
            <>
              <AnimatedNumber initial={0} value={beaker.currentVolume} />/
              {beaker.maxVolume} units
            </>
          )) ||
          'No beaker'}
      </LabeledList.Item>
      <LabeledList.Item label="Contents">
        <Box color="label">
          {(!beaker && 'N/A') || (beakerContents.length === 0 && 'Nothing')}
        </Box>
        {beakerContents.map((chemical) => (
          <Box key={chemical.name} color="label">
            <AnimatedNumber initial={0} value={chemical.volume} /> units of{' '}
            {chemical.name}
          </Box>
        ))}
        {beakerContents.length > 0 && !!showpH && (
          <Box>
            pH:
            <AnimatedNumber value={beaker.pH} />
          </Box>
        )}
      </LabeledList.Item>
    </LabeledList>
  );
};
