import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Slider, ProgressBar, NoticeBox, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type IVDripData = {
  transferRate: number;
  injectOnly: BooleanLike;
  minInjectRate: number;
  maxInjectRate: number;
  mode: BooleanLike;
  connected: BooleanLike;
  objectName: string;
  canDrainBlood: BooleanLike;
  beakerAttached: BooleanLike;
  beakerReagentColor: string;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  useInternalStorage: BooleanLike;
};

export const IVDrip = (props, context) => {
  const { act, data } = useBackend<IVDripData>(context);
  return (
    <Window width={380} height={220}>
      <Window.Content>
        <Section fill>
          <LabeledList>
            {data.beakerAttached ? (
              <LabeledList.Item
                label="Container"
                buttons={
                  <Button
                    my={1}
                    width={8}
                    lineHeight={2}
                    align="center"
                    icon="eject"
                    content="Eject"
                    onClick={() => act('eject')}
                  />
                }>
                <ProgressBar
                  value={data.beakerCurrentVolume}
                  minValue={0}
                  maxValue={data.beakerMaxVolume}
                  color={data.beakerReagentColor}>
                  <span
                    style={{
                      'text-shadow': '1px 1px 0 black',
                    }}>
                    {`${data.beakerCurrentVolume} of ${data.beakerMaxVolume} units`}
                  </span>
                </ProgressBar>
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label="Container">
                <NoticeBox my={0.7}>No container attached.</NoticeBox>
              </LabeledList.Item>
            )}
            <LabeledList.Item
              label="Direction"
              color={data.mode ? 'good' : 'bad'}
              buttons={
                <Button
                  my={1}
                  width={8}
                  lineHeight={2}
                  align="center"
                  disabled={data.injectOnly || !data.canDrainBlood}
                  color={data.mode ? 'good' : 'bad'}
                  content={data.mode ? 'Injecting' : 'Draining'}
                  icon={data.mode ? 'syringe' : 'droplet'}
                  onClick={() => act('changeMode')}
                />
              }>
              {data.mode ? 'Reagents from container' : 'Blood into container'}
            </LabeledList.Item>
            {data.connected ? (
              <LabeledList.Item
                label="Object"
                buttons={
                  <Button
                    disabled={!data.connected}
                    my={1}
                    width={8}
                    lineHeight={2}
                    align="center"
                    icon="ban"
                    content="Disconnect"
                    onClick={() => act('detach')}
                  />
                }>
                <Box maxHeight={'45px'} overflow={'hidden'}>
                  {data.objectName}
                </Box>
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label="Object">
                <NoticeBox my={0.7}>No object connected.</NoticeBox>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Transfer Rate" buttons={'Units / Second'}>
              <Slider
                step={0.01}
                my={1}
                value={data.transferRate}
                minValue={data.minInjectRate}
                maxValue={data.maxInjectRate}
                onDrag={(e, value) =>
                  act('changeRate', {
                    rate: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
