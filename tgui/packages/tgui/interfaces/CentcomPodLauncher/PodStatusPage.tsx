import { Fragment } from 'react';

import { useBackend } from '../../backend';
import { Box, Button, Section, Stack } from '../../components';
import { EFFECTS_ALL, POD_GREY } from './constants';
import { PodLauncherData } from './types';
import { useCompact } from './useCompact';

export function PodStatusPage(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { effectShrapnel, payload, shrapnelMagnitude, shrapnelType } = data;

  const { compact, toggleCompact } = useCompact();

  return (
    <Section fill>
      <Stack>
        {EFFECTS_ALL.map((list, i) => (
          <Fragment key={i}>
            <Stack.Item>
              <Box bold color="label" mb={1}>
                {compact && list.alt_label ? list.alt_label : list.label}:
              </Box>
              <Box>
                {list.list.map((effect, j) => (
                  <Fragment key={j}>
                    {effect.divider && (
                      <span style={POD_GREY}>
                        <b>|</b>
                      </span>
                    )}
                    {!effect.divider && (
                      <Button
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
                        tooltipPosition={list.tooltipPosition}
                        icon={effect.icon}
                        selected={
                          effect.soloSelected
                            ? data[effect.soloSelected]
                            : data[effect.selected] === effect.choiceNumber
                        }
                        onClick={() =>
                          payload !== 0
                            ? act(effect.act, effect.payload)
                            : act(effect.act)
                        }
                        style={{
                          verticalAlign: 'middle',
                          marginLeft: j !== 0 ? '1px' : '0px',
                          marginRight:
                            j !== list.list.length - 1 ? '1px' : '0px',
                          borderRadius: '5px',
                        }}
                      >
                        {effect.content}
                      </Button>
                    )}
                  </Fragment>
                ))}
              </Box>
            </Stack.Item>
            {i < EFFECTS_ALL.length && <Stack.Divider />}
            {i === EFFECTS_ALL.length - 1 && (
              <Stack.Item>
                <Box color="label" mb={1}>
                  <b>Extras:</b>
                </Box>
                <Box>
                  <Button
                    m={0}
                    inline
                    color="transparent"
                    icon="list-alt"
                    tooltip="Game Panel"
                    tooltipPosition="top-start"
                    onClick={() => act('gamePanel')}
                  />
                  <Button
                    inline
                    m={0}
                    color="transparent"
                    icon="hammer"
                    tooltip="Build Mode"
                    tooltipPosition="top-start"
                    onClick={() => act('buildMode')}
                  />
                  {(compact && (
                    <Button
                      inline
                      m={0}
                      color="transparent"
                      icon="expand"
                      tooltip="Maximize"
                      tooltipPosition="top-start"
                      onClick={() => {
                        toggleCompact();
                        act('refreshView');
                      }}
                    />
                  )) || (
                    <Button
                      m={0}
                      inline
                      color="transparent"
                      icon="compress"
                      tooltip="Compact mode"
                      tooltipPosition="top-start"
                      onClick={() => toggleCompact()}
                    />
                  )}
                </Box>
              </Stack.Item>
            )}
          </Fragment>
        ))}
      </Stack>
    </Section>
  );
}
