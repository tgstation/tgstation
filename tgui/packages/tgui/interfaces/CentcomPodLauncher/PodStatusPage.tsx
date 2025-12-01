import { Fragment } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { EFFECTS_ALL, POD_GREY } from './constants';
import { useCompact } from './hooks';
import type { PodEffect, PodLauncherData } from './types';

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
        borderRadius: '5px',
        marginLeft: index !== 0 ? '1px' : '0px',
        marginRight: hasMargin ? '1px' : '0px',
        verticalAlign: 'middle',
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
        <Button
          color="transparent"
          icon={compact ? 'expand' : 'compress'}
          inline
          m={0}
          onClick={() => {
            setCompact(!compact);
            compact && act('refreshView');
          }}
          tooltip={compact ? 'Expand mode' : 'Compact mode'}
          tooltipPosition="top-start"
        />
      </Box>
    </Stack.Item>
  );
}
