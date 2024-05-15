import { classes } from 'common/react';

import { useBackend } from '../../backend';
import { Box, Button, Section } from '../../components';
import { STYLES } from './constants';
import { PodLauncherData } from './types';

export function StylePage(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { effectName, styleChoice } = data;

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
            name/desc.`}
          tooltipPosition="bottom-start"
        >
          Name
        </Button>
      }
      fill
      scrollable
      title="Style"
    >
      {STYLES.map((page, i) => (
        <Button
          height="45px"
          key={i}
          onClick={() => act('setStyle', { style: i })}
          selected={styleChoice - 1 === i}
          style={{
            verticalAlign: 'middle',
            marginRight: '5px',
            borderRadius: '20px',
          }}
          tooltipPosition={
            i >= STYLES.length - 2
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
            className={classes(['supplypods64x64', 'pod_asset' + (i + 1)])}
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
