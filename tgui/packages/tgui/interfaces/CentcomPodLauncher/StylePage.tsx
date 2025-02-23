import { Box, Button, Section } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { PodLauncherData } from './types';

export function StylePage(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { effectName, styleChoice, podStyles } = data;

  return (
    <Section
      buttons={
        <Button
          color="transparent"
          icon="edit"
          onClick={() => act('effectName')}
          selected={effectName}
          tooltip={`
            Edit pod's
            .id/desc.`}
          tooltipPosition="bottom-start"
        >
          Name
        </Button>
      }
      fill
      scrollable
      title="Style"
    >
      {podStyles.map((page, i) => (
        <Button
          height="45px"
          key={page.id}
          onClick={() => act('setStyle', { style: page.id })}
          selected={styleChoice === page.id}
          style={{
            verticalAlign: 'middle',
            marginRight: '5px',
            borderRadius: '20px',
          }}
          tooltipPosition={
            i >= podStyles.length - 2
              ? i % 2 === 1
                ? 'top-start'
                : 'top-end'
              : i % 2 === 1
                ? 'bottom-start'
                : 'bottom-end'
          }
          tooltip={page.title}
          width="45px"
        >
          <Box
            className={classes(['supplypods64x64', 'pod_asset' + page.id])}
            style={{
              pointerEvents: 'none',
              transform: 'rotate(45deg) translate(-25%,-10%)',
            }}
          />
        </Button>
      ))}
    </Section>
  );
}
