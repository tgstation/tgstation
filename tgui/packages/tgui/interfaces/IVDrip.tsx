import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Tooltip, Box, Slider, ProgressBar, NoticeBox, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type IVDripData = {
  hasInternalStorage: BooleanLike;
  hasContainer: BooleanLike;
  canRemoveContainer: BooleanLike;
  mode: BooleanLike;
  canDraw: BooleanLike;
  injectFromPlumbing: BooleanLike;
  canAdjustTransfer: BooleanLike;
  transferRate: number;
  transferStep: number;
  minTransferRate: number;
  maxTransferRate: number;
  hasObjectAttached: BooleanLike;
  objectName: string;
  containerReagentColor: string;
  containerCurrentVolume: number;
  containerMaxVolume: number;
};

enum MODE {
  drawing,
  injecting,
}

export const IVDrip = (props, context) => {
  const { act, data } = useBackend<IVDripData>(context);
  const {
    hasContainer,
    canRemoveContainer,
    mode,
    canDraw,
    injectFromPlumbing,
    canAdjustTransfer,
    hasInternalStorage,
    transferRate,
    transferStep,
    maxTransferRate,
    minTransferRate,
    hasObjectAttached,
    objectName,
    containerCurrentVolume,
    containerMaxVolume,
    containerReagentColor,
  } = data;
  return (
    <Window width={400} height={220}>
      <Window.Content>
        <Section fill>
          <LabeledList>
            {hasContainer || hasInternalStorage ? (
              <LabeledList.Item
                label="Container"
                buttons={
                  !hasInternalStorage &&
                  !!canRemoveContainer && (
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
                  value={containerCurrentVolume}
                  minValue={0}
                  maxValue={containerMaxVolume}
                  color={containerReagentColor}>
                  <span
                    style={{
                      'text-shadow': '1px 1px 0 black',
                    }}>
                    {`${containerCurrentVolume} of ${containerMaxVolume} units`}
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
              color={!mode && 'bad'}
              buttons={
                <Button
                  my={1}
                  width={8}
                  lineHeight={2}
                  align="center"
                  disabled={!canDraw}
                  color={!mode && 'bad'}
                  content={mode ? 'Injecting' : 'Draining'}
                  icon={mode ? 'syringe' : 'droplet'}
                  onClick={() => act('changeMode')}
                />
              }>
              {mode
                ? hasInternalStorage
                  ? 'Reagents from network'
                  : 'Reagents from container'
                : 'Blood into container'}
            </LabeledList.Item>
            {hasObjectAttached ? (
              <LabeledList.Item
                label="Object"
                buttons={
                  <Button
                    disabled={!hasObjectAttached}
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
                  {objectName}
                </Box>
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label="Object">
                <Tooltip content="Drag the cursor from the drip and drop it on an object to connect.">
                  <NoticeBox my={0.7}>No object hasObjectAttached.</NoticeBox>
                </Tooltip>
              </LabeledList.Item>
            )}
            {!!hasObjectAttached &&
              (mode === MODE.injecting && injectFromPlumbing ? ( // Plumbing drip injects with the rate from network
                <LabeledList.Item label="Transfer Rate">
                  Controlled by the plumbing network
                </LabeledList.Item>
              ) : (
                (!!hasContainer || !!hasInternalStorage) &&
                !!canAdjustTransfer && (
                  <LabeledList.Item
                    label="Transfer Rate"
                    buttons={'Units / Second'}>
                    <Slider
                      step={transferStep}
                      my={1}
                      value={transferRate}
                      minValue={minTransferRate}
                      maxValue={maxTransferRate}
                      onDrag={(e, value) =>
                        act('changeRate', {
                          rate: value,
                        })
                      }
                    />
                  </LabeledList.Item>
                )
              ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
