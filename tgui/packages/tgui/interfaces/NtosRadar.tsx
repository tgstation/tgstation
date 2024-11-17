import {
  Button,
  Icon,
  Image,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike, classes } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
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

export const NtosRadar = (props) => {
  return (
    <NtosWindow width={800} height={600} theme="ntos">
      <NtosRadarContent />
    </NtosWindow>
  );
};

export const NtosRadarContent = (props) => {
  return (
    <Stack fill>
      <Stack.Item position="relative" width={20.5}>
        <ObjectDisplay />
      </Stack.Item>
      <Stack.Item
        style={{
          backgroundImage:
            'url("' + resolveAsset('ntosradarbackground.png') + '")',
          backgroundPosition: 'center',
          backgroundRepeat: 'no-repeat',
          top: '20px',
        }}
        position="relative"
        m={1.5}
        width={45}
        height={45}
      >
        <TargetDisplay />
      </Stack.Item>
    </Stack>
  );
};

/** Returns object information */
const ObjectDisplay = (props) => {
  const { act, data } = useBackend<Data>();
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
              }}
            >
              {object.name}
            </div>
          ))}
      </Section>
    </NtosWindow.Content>
  );
};

/** Returns target information */
const TargetDisplay = (props) => {
  const { data } = useBackend<Data>();
  const { selected, target } = data;

  if (!selected || !target) {
    return null;
  }
  if (!Object.keys(target).length && !!selected) {
    return (
      <NoticeBox
        position="absolute"
        top={20.6}
        left={1.35}
        width={42}
        fontSize="30px"
        textAlign="center"
      >
        Signal Lost
      </NoticeBox>
    );
  }
  return target.userot ? (
    <Image
      src={resolveAsset(target.arrowstyle)}
      position="absolute"
      top="20px"
      left="243px"
      style={{
        transform: `rotate(${target.rot}deg)`,
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
