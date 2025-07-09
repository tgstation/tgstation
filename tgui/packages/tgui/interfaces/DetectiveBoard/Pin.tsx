import { useEffect, useState } from 'react';
import { Box, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import type { DataEvidence, XYCoords } from './types';

type PinProps = {
  evidence: DataEvidence;
  onStartConnecting: (evidence: DataEvidence, mousePos: XYCoords) => void;
  onConnected: (evidence: DataEvidence) => void;
  onMouseUp: (evidence: DataEvidence, args: any) => void;
};

export function Pin(props: PinProps) {
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
          onMouseUp={(args) => props.onMouseUp(evidence, args)}
        />
      </Stack.Item>
    </Stack>
  );
}
