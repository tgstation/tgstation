import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Tooltip, Box, Slider, ProgressBar, NoticeBox, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type IVDripData = {
  transferRate: number;
  transferStep: number;
  injectOnly: BooleanLike;
  minInjectRate: number;
  maxInjectRate: number;
  mode: BooleanLike;
  connected: BooleanLike;
  objectName: string;
  containerAttached: BooleanLike;
  containerReagentColor: string;
  containerCurrentVolume: number;
  containerMaxVolume: number;
  useInternalStorage: BooleanLike;
  isContainerRemovable: BooleanLike;
};

export const IVDrip = (props, context) => {
  const { act, data } = useBackend<IVDripData>(context);
  return (
    <Window width={400} height={220}>
      <Window.Content>
        <Section fill>
          <LabeledList>
            {data.containerAttached || data.useInternalStorage ? (
              <LabeledList.Item
                label="Container"
                buttons={
                  !data.useInternalStorage &&
                  !!data.isContainerRemovable && (
                    <Button
                      my={1}
                      width={8}
                      lineHeight={2}
                      align="center"
                      icon="eject"
                      content="Eject"
                      onClick={() => act('eject')}
                    />
                  )
                }>
                <ProgressBar
                  value={data.containerCurrentVolume}
                  minValue={0}
                  maxValue={data.containerMaxVolume}
                  color={data.containerReagentColor}>
                  <span
                    style={{
                      'text-shadow': '1px 1px 0 black',
                    }}>
                    {`${data.containerCurrentVolume} of ${data.containerMaxVolume} units`}
                  </span>
                </ProgressBar>
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label="Container">
                <Tooltip content="Click the drip with a container in hand to attach.">
                  <NoticeBox my={0.7}>No container attached.</NoticeBox>
                </Tooltip>
              </LabeledList.Item>
            )}
            <LabeledList.Item
              label="Direction"
              color={!data.mode && 'bad'}
              buttons={
                <Button
                  my={1}
                  width={8}
                  lineHeight={2}
                  align="center"
                  disabled={data.injectOnly}
                  color={!data.mode && 'bad'}
                  content={data.mode ? 'Injecting' : 'Draining'}
                  icon={data.mode ? 'syringe' : 'droplet'}
                  onClick={() => act('changeMode')}
                />
              }>
              {data.mode
                ? data.useInternalStorage
                  ? 'Reagents from network'
                  : 'Reagents from container'
                : 'Blood into container'}
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
                <Tooltip content="Drag the cursor from the drip and drop it on an object to connect.">
                  <NoticeBox my={0.7}>No object connected.</NoticeBox>
                </Tooltip>
              </LabeledList.Item>
            )}
            {!!data.connected &&
              (!!data.containerAttached || data.useInternalStorage) && (
                <LabeledList.Item
                  label="Transfer Rate"
                  buttons={'Units / Second'}>
                  <Slider
                    step={data.transferStep}
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
              )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
