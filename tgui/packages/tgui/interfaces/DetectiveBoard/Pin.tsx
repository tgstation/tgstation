import { useEffect, useState } from 'react';
import { Box, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { DataEvidence } from './DataTypes';

type PinProps = {
  evidence: DataEvidence;
  onStartConnecting: Function;
  onConnected: Function;
  onMouseUp: Function;
};

export function Pin(props: PinProps) {
  const { evidence, onStartConnecting, onConnected, onMouseUp } = props;
  const [creatingRope, setCreatingRope] = useState(false);

  function handleMouseDown(args) {
    setCreatingRope(true);
    onStartConnecting(evidence, {
      x: args.clientX,
      y: args.clientY,
    });
  }

  useEffect(() => {
    if (!creatingRope) {
      return;
    }
    const handleMouseUp = (args: MouseEvent) => {
      if (creatingRope) {
        setCreatingRope(false);
        onConnected(evidence, {
          evidence_ref: 'not used',
          position: {
            x: args.clientX,
            y: args.clientY,
          },
        });
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
          onMouseUp={(args) => onMouseUp(evidence, args)}
        />
      </Stack.Item>
    </Stack>
  );
}
