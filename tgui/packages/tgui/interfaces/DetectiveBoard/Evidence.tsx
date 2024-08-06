import { useEffect, useState } from 'react';

import { Box, Button, Flex, Stack } from '../../components';
import { DataEvidence } from './DataTypes';
import { Pin } from './Pin';

type EvidenceProps = {
  case_ref: string;
  evidence: DataEvidence;
  act: Function;
  onPinStartConnecting: Function;
  onPinConnected: Function;
  onPinMouseUp: Function;
  onEvidenceRemoved: Function;
};

type Position = {
  x: number;
  y: number;
};

export function Evidence(props: EvidenceProps) {
  const { evidence, case_ref, act } = props;

  const [dragging, setDragging] = useState(false);

  const [canDrag, setCanDrag] = useState(true);

  const [dragPosition, setDragPosition] = useState<Position>({
    x: evidence.x,
    y: evidence.y,
  });

  const [lastMousePosition, setLastMousePosition] = useState<Position | null>(
    null,
  );

  function handleMouseDown(args) {
    setDragging(true);
    setLastMousePosition({ x: args.screenX, y: args.screenY });
  }

  useEffect(() => {
    if (!dragging) {
      return;
    }
    const handleMouseUp = (args: MouseEvent) => {
      if (dragPosition) {
        act('set_evidence_cords', {
          evidence_ref: evidence.ref,
          case_ref: case_ref,
          rel_x: dragPosition.x,
          rel_y: dragPosition.y,
        });
      }
      setDragging(false);
      setLastMousePosition(null);
    };
    window.addEventListener('mouseup', handleMouseUp);
    return () => {
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [dragPosition, dragging]);

  useEffect(() => {
    if (!dragging) {
      return;
    }

    const onMouseMove = (args: MouseEvent) => {
      if (canDrag) {
        if (lastMousePosition) {
          setDragPosition({
            x: dragPosition.x - (lastMousePosition.x - args.screenX),
            y: dragPosition.y - (lastMousePosition.y - args.screenY),
          });
        }

        setLastMousePosition({ x: args.screenX, y: args.screenY });
      }
    };

    window.addEventListener('mousemove', onMouseMove);
    return () => {
      window.removeEventListener('mousemove', onMouseMove);
    };
  }, [evidence.x, evidence.y, dragging]);

  return (
    <Box
      position="absolute"
      left={`${dragPosition.x}px`}
      top={`${dragPosition.y}px`}
      onMouseDown={handleMouseDown}
    >
      <Stack vertical>
        <Stack.Item>
          <Box className="Evidence__Box">
            <Flex justify="space-between" align="center">
              <Flex.Item align="left">
                <Pin
                  evidence={evidence}
                  onStartConnecting={(
                    evidence: DataEvidence,
                    mousePos: Position,
                  ) => {
                    props.onPinStartConnecting(evidence, mousePos);
                    setCanDrag(false);
                  }}
                  onConnected={(evidence: DataEvidence) => {
                    props.onPinConnected(evidence);
                    setCanDrag(true);
                  }}
                  onMouseUp={(evidence: DataEvidence, args) => {
                    props.onPinMouseUp(evidence, args);
                    setCanDrag(true);
                  }}
                />
              </Flex.Item>
              <Flex.Item align="center">
                <Box className="Evidence__Box__TextBox title">
                  <b>{evidence.name}</b>
                </Box>
              </Flex.Item>
              <Flex.Item align="right">
                <Button
                  iconColor="red"
                  icon="trash"
                  color="white"
                  onClick={() => {
                    act('remove_evidence', {
                      case_ref: case_ref,
                      evidence_ref: evidence.ref,
                    });
                    props.onEvidenceRemoved(evidence);
                  }}
                />
              </Flex.Item>
            </Flex>
            <Box
              onClick={() =>
                act('look_evidence', {
                  case_ref: case_ref,
                  evidence_ref: evidence.ref,
                })
              }
            >
              {evidence.type === 'photo' ? (
                <img className="Evidence__Icon" src={evidence.photo_url} />
              ) : (
                // eslint-disable-next-line react/no-danger
                <div dangerouslySetInnerHTML={{ __html: evidence.text }} />
              )}
            </Box>

            <Box className="Evidence__Box__TextBox">{evidence.description}</Box>
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
}
