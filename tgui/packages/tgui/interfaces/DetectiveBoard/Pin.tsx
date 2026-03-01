import { useEffect, useState } from 'react';
import { Box, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import type { Coordinates } from '../common/Connections';
import type { DataEvidence } from './types';

type Props = {
  evidence: DataEvidence;
  onStartConnecting: (evidence: DataEvidence, mousePos: Coordinates) => void;
  onConnected: (evidence: DataEvidence) => void;
  onPinMouseUp: (evidence: DataEvidence, args: any) => void;
};

export function Pin(props: Props) {
  const { evidence } = props;
  const [creatingRope, setCreatingRope] = useState(false);

  function handleMouseDown(args) {
    setCreatingRope(true);
    props.onStartConnecting(evidence, {
      x: args.clientX,
      y: args.clientY,
    });
  }

  useEffect(() => {
    if (!creatingRope) {
      return;
    }
    const handleMouseUp = () => {
      if (creatingRope) {
        setCreatingRope(false);
        props.onConnected(evidence);
      }
    };
    window.addEventListener('mouseup', handleMouseUp);
    return () => {
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [creatingRope]);

  return (
    <Stack>
      <Stack.Item>
        <Box
          className={classes([
            'Evidence__Pin',
            creatingRope && 'Evidence__Pin--connecting',
          ])}
          textAlign="center"
          onMouseDown={handleMouseDown}
          onMouseUp={(args) => props.onPinMouseUp(evidence, args)}
        />
      </Stack.Item>
    </Stack>
  );
}
