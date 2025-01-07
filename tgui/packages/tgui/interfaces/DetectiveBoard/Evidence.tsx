import { useEffect, useState } from 'react';
import { Box, Button, Flex, Stack } from 'tgui-core/components';

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
  onStartMoving: Function;
  onStopMoving: Function;
  onMoving: Function;
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
    if (canDrag) {
      setDragging(true);
      props.onStartMoving(evidence);
      setLastMousePosition({ x: args.screenX, y: args.screenY });
    }
  }

  useEffect(() => {
    if (!dragging) {
      return;
    }

    const handleMouseUp = (args: MouseEvent) => {
      if (canDrag && dragPosition && dragging && lastMousePosition) {
        act('set_evidence_cords', {
          evidence_ref: evidence.ref,
          case_ref: case_ref,
          rel_x: dragPosition.x - (lastMousePosition.x - args.screenX),
          rel_y: dragPosition.y - (lastMousePosition.y - args.screenY),
        });
        props.onStopMoving({
          ...evidence,
          y: dragPosition.y - (lastMousePosition.y - args.screenY),
          x: dragPosition.x - (lastMousePosition.x - args.screenX),
        });
      }
      setDragging(false);
      setLastMousePosition(null);
    };
    window.addEventListener('mouseup', handleMouseUp);
    return () => {
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [dragging]);

  function getPinPositionByPosition(evidence: Position) {
    return { x: evidence.x + 15, y: evidence.y + 45 };
  }
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
          props.onMoving(evidence, {
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
            <Flex justify="space-between" mt={0.5} align="top">
              <Flex.Item align="left">
                <Pin
                  evidence={evidence}
                  onStartConnecting={(
                    evidence: DataEvidence,
                    mousePos: Position,
                  ) => {
                    setCanDrag(false);
                    props.onPinStartConnecting(evidence, mousePos);
                  }}
                  onConnected={(evidence: DataEvidence) => {
                    setCanDrag(true);
                    props.onPinConnected(evidence);
                  }}
                  onMouseUp={(evidence: DataEvidence, args) => {
                    setCanDrag(true);
                    props.onPinMouseUp(evidence, args);
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
                    props.onEvidenceRemoved(evidence);
                    act('remove_evidence', {
                      evidence_ref: evidence.ref,
                    });
                  }}
                  onMouseDown={() => setCanDrag(false)}
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
