import { Fragment } from 'react';

import { useBackend } from '../../backend';
import { Box, Button, Section, Stack } from '../../components';
import { EFFECTS_ALL, POD_GREY } from './constants';
import { useCompact } from './hooks';
import { PodEffect, PodLauncherData } from './types';

export function PodStatusPage(props) {
  const [compact] = useCompact();

  return (
    <Section fill>
      <Stack>
        {EFFECTS_ALL.map((effectType, typeIdx) => (
          <Fragment key={typeIdx}>
            <Stack.Item>
              <Box bold color="label" mb={1}>
                {!compact && (effectType.alt_label || effectType.label)}:
              </Box>
              <Box>
                {effectType.list.map((effect, effectIdx) => (
                  <EffectDisplay
                    effect={effect}
                    hasMargin={effectType.list.length > 1}
                    index={effectIdx}
                    key={effectIdx}
                  />
                ))}
              </Box>
            </Stack.Item>
            {typeIdx < EFFECTS_ALL.length && <Stack.Divider />}
            {typeIdx === EFFECTS_ALL.length - 1 && <Extras />}
          </Fragment>
        ))}
      </Stack>
    </Section>
  );
}

type EffectDisplayProps = {
  effect: PodEffect;
  hasMargin: boolean;
  index: number;
};

function EffectDisplay(props: EffectDisplayProps) {
  const { effect, hasMargin, index } = props;
  const { act, data } = useBackend<PodLauncherData>();
  const { effectShrapnel, payload, shrapnelMagnitude, shrapnelType } = data;

  if (effect.divider || !('icon' in effect)) {
    return (
      <span style={POD_GREY}>
        <b>|</b>
      </span>
    );
  }

  return (
    <Button
      icon={effect.icon}
      onClick={() =>
        payload ? act(effect.act, effect.payload) : act(effect.act)
      }
      selected={
        effect.soloSelected
          ? data[effect.soloSelected]
          : data[effect.selected as string] === effect.choiceNumber
      }
      style={{
        verticalAlign: 'middle',
        marginLeft: index !== 0 ? '1px' : '0px',
        marginRight: hasMargin ? '1px' : '0px',
        borderRadius: '5px',
      }}
      tooltip={
        effect.details
          ? effectShrapnel
            ? effect.title +
              '\n' +
              shrapnelType +
              '\nMagnitude:' +
              shrapnelMagnitude
            : effect.title
          : effect.title
      }
      tooltipPosition={effect.tooltipPosition}
    >
      {effect.content}
    </Button>
  );
}

function Extras(props) {
  const { act } = useBackend();
  const [compact, setCompact] = useCompact();

  return (
    <Stack.Item>
      <Box color="label" mb={1}>
        <b>Extras:</b>
      </Box>
      <Box>
        <Button
          color="transparent"
          icon="list-alt"
          inline
          m={0}
          onClick={() => act('gamePanel')}
          tooltip="Game Panel"
          tooltipPosition="top-start"
        />
        <Button
          color="transparent"
          icon="hammer"
          inline
          m={0}
          onClick={() => act('buildMode')}
          tooltip="Build Mode"
          tooltipPosition="top-start"
        />
        {(compact && (
          <Button
            color="transparent"
            icon="expand"
            inline
            m={0}
            onClick={() => {
              setCompact(!compact);
              act('refreshView');
            }}
            tooltip="Maximize"
            tooltipPosition="top-start"
          />
        )) || (
          <Button
            color="transparent"
            icon="compress"
            inline
            m={0}
            onClick={() => setCompact(!compact)}
            tooltip="Compact mode"
            tooltipPosition="top-start"
          />
        )}
      </Box>
    </Stack.Item>
  );
}
