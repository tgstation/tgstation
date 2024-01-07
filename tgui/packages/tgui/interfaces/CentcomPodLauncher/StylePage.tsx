import { classes } from 'common/react';
import { multiline } from 'common/string';

import { useBackend } from '../../backend';
import { Box, Button, Section } from '../../components';
import { STYLES } from './constants';
import { PodLauncherData } from './types';

export function StylePage(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { effectName, styleChoice } = data;

  return (
    <Section
      fill
      scrollable
      title="Style"
      buttons={
        <Button
          color="transparent"
          icon="edit"
          selected={effectName}
          tooltip={multiline`
            Edit pod's
            name/desc.`}
          tooltipPosition="bottom-start"
          onClick={() => act('effectName')}
        >
          Name
        </Button>
      }
    >
      {STYLES.map((page, i) => (
        <Button
          key={i}
          width="45px"
          height="45px"
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
          style={{
            verticalAlign: 'middle',
            marginRight: '5px',
            borderRadius: '20px',
          }}
          selected={styleChoice - 1 === i}
          onClick={() => act('setStyle', { style: i })}
        >
          <Box
            className={classes(['supplypods64x64', 'pod_asset' + (i + 1)])}
            style={{
              transform: 'rotate(45deg) translate(-25%,-10%)',
              pointerEvents: 'none',
            }}
          />
        </Button>
      ))}
    </Section>
  );
}
