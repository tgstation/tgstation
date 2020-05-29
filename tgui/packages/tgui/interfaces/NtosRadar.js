import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { classes } from 'common/react';
import { Box, Button, LabeledList, NoticeBox, Section, Table, Flex, Icon } from '../components';
import { NtosWindow } from '../layouts';

export const NtosRadar = (props, context) => {
  return (
    <NtosWindow theme="ntos">
      <NtosRadarContent />
    </NtosWindow>
  );
};

export const NtosRadarContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    selected,
    object = [],
    target = [],
    scanning,
  } = data;

  return (
    <Flex 
      direction={"row"}
      hight="100%">
      <Flex.Item
        position="relative"
        width={20.5}
        hight="100%">
        <NtosWindow.Content scrollable>
          <Section>
            <Button
              icon="redo-alt"
              content={scanning?"Scanning...":"Scan"}
              color="blue"
              disabled={scanning}
              onClick={() => act('scan')} />
            {!object.length && !scanning && (
              <div>
                No trackable signals found
              </div>
            )}
            {!scanning && object.map(object => (
              <div
                key={object.dev}
                title={object.name}
                className={classes([
                  'Button',
                  'Button--fluid',
                  'Button--color--transparent',
                  'Button--ellipsis',
                  object.ref === selected
                    && 'Button--selected',
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
      </Flex.Item>
      <Flex.Item
        style={{
          'background-image': 'url("ntosradarbackground.png")',
          'background-position': 'center',
          'background-repeat': 'no-repeat',
          'top': '20px',
        }}
        position="relative"
        m={1.5}
        width={45}
        height={45}>
        {Object.keys(target).length === 0
          ? !!selected && (
            <NoticeBox
              position="absolute"
              top={20.6}
              left={1.35}
              width={42}
              fontSize="30px"
              textAlign="center">
              Signal Lost
            </NoticeBox>
          )
          : !!target.userot && (
            <Box as="img"
              src={target.arrowstyle}
              position="absolute"
              top="20px"
              left="243px"
              style={{
                'transform': `rotate(${target.rot}deg)`,
              }}
            />
          ) || (
            <Icon
              name={target.pointer}
              position="absolute"
              size={2}
              color={target.color}
              top={((target.locy * 10) + 29) + 'px'}
              left={((target.locx * 10) + 16) + 'px'}
            />
          )}
      </Flex.Item>
    </Flex>
  );
};
