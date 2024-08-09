import { useEffect, useState } from 'react';

import { Box, Stack } from '../../components';
import { DataEvidence } from './DataTypes';

const Y_OFFSET = -45;

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
      y: args.clientY + Y_OFFSET,
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
            y: args.clientY + Y_OFFSET,
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
          className="Evidence__Pin"
          textAlign="center"
          onMouseDown={handleMouseDown}
          onMouseUp={(args) => onMouseUp(evidence, args)}
        />
      </Stack.Item>
    </Stack>
  );
}
