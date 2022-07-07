import { BooleanLike, classes } from 'common/react';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Button, Icon, NoticeBox, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  selected: string;
  object: Object[];
  target: Target;
  scanning: BooleanLike;
};

type Object = {
  dev: string;
  name: string;
  ref: string;
};

type Target = {
  userot: BooleanLike;
  arrowstyle: string;
  rot: number;
  pointer: string;
  color: string;
  locy: number;
  locx: number;
};

export const NtosRadar = () => {
  return (
    <NtosWindow width={800} height={600} theme="ntos">
      <NtosRadarContent sig_err={'Signal Lost'} />
    </NtosWindow>
  );
};

export const NtosRadarContent = (props) => {
  const { sig_err } = props;

  return (
    <Stack fill>
      <Stack.Item position="relative" width={20.5}>
        <ObjectDisplay />
      </Stack.Item>
      <Stack.Item
        style={{
          'background-image':
            'url("' + resolveAsset('ntosradarbackground.png') + '")',
          'background-position': 'center',
          'background-repeat': 'no-repeat',
          'top': '20px',
        }}
        position="relative"
        m={1.5}
        width={45}
        height={45}>
        <TargetDisplay sig_err={sig_err} />
      </Stack.Item>
    </Stack>
  );
};

/** Returns object information */
const ObjectDisplay = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { object = [], scanning, selected } = data;

  return (
    <NtosWindow.Content scrollable>
      <Section>
        <Button
          icon="redo-alt"
          content={scanning ? 'Scanning...' : 'Scan'}
          color="blue"
          disabled={scanning}
          onClick={() => act('scan')}
        />
        {!object.length && !scanning && <div>No trackable signals found</div>}
        {!scanning &&
          object.map((object) => (
            <div
              key={object.dev}
              title={object.name}
              className={classes([
                'Button',
                'Button--fluid',
                'Button--color--transparent',
                'Button--ellipsis',
                object.ref === selected && 'Button--selected',
              ])}
              onClick={() => {
                act('selecttarget', {
                  ref: object.ref,
                });
              }}>
              {object.name}
            </div>
          ))}
      </Section>
    </NtosWindow.Content>
  );
};

/** Returns target information */
const TargetDisplay = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { selected, target } = data;
  const { sig_err } = props;

  if (!Object.keys(target).length && !!selected) {
    return (
      <NoticeBox
        position="absolute"
        top={20.6}
        left={1.35}
        width={42}
        fontSize="30px"
        textAlign="center">
        {sig_err}
      </NoticeBox>
    );
  }
  return target.userot ? (
    <Box
      as="img"
      src={resolveAsset(target.arrowstyle)}
      position="absolute"
      top="20px"
      left="243px"
      style={{
        'transform': `rotate(${target.rot}deg)`,
      }}
    />
  ) : (
    <Icon
      name={target.pointer}
      position="absolute"
      size={2}
      color={target.color}
      top={target.locy * 10 + 19 + 'px'}
      left={target.locx * 10 + 16 + 'px'}
    />
  );
};
