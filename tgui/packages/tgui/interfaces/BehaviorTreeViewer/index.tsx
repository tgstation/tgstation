import { useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  type BehaviorTreeViewerData,
  BT_ABORT_BOTH,
  BT_ABORT_LOWER_PRIORITY,
  BT_ABORT_NONE,
  BT_ABORT_SELF,
  BT_NODE_DECORATOR,
  BT_NODE_LEAF,
  BT_NODE_PARALLEL,
  BT_NODE_SELECTOR,
  BT_NODE_SEQUENCE,
  BT_NODE_SUBTREE,
  type BtNodeData,
} from './types';

const NODE_WIDTH = 160;
const NODE_HEIGHT = 70;
const H_GAP = 12;
const V_GAP = 48;

function nodeTypeBadge(t: number): string {
  switch (t) {
    case BT_NODE_SEQUENCE:
      return 'SEQ';
    case BT_NODE_SELECTOR:
      return 'SEL';
    case BT_NODE_PARALLEL:
      return 'PAR';
    case BT_NODE_DECORATOR:
      return 'DEC';
    case BT_NODE_SUBTREE:
      return 'SUB';
    default:
      return '';
  }
}

function lastIdx(node: BtNodeData): number {
  return node.z ?? node.e;
}

function children(node: BtNodeData): BtNodeData[] {
  return (node.c ?? []).filter((c): c is BtNodeData => c !== null);
}

function nodeColor(
  node: BtNodeData,
  activeIdx: number,
  selectedDec: BtNodeData | null,
): string {
  if (node.t === BT_NODE_LEAF && activeIdx > 0 && activeIdx === node.e) {
    return 'green';
  }
  if (activeIdx > 0 && activeIdx >= node.e && activeIdx <= lastIdx(node)) {
    return 'good';
  }
  if (selectedDec) {
    const abort = selectedDec.a ?? BT_ABORT_NONE;
    const inRange = node.e >= selectedDec.e && node.e <= lastIdx(selectedDec);
    const lowerPriority = node.e > lastIdx(selectedDec);
    if (
      (abort === BT_ABORT_SELF && inRange) ||
      (abort === BT_ABORT_LOWER_PRIORITY && lowerPriority) ||
      (abort === BT_ABORT_BOTH && (inRange || lowerPriority))
    ) {
      return 'orange';
    }
    if (node.e === selectedDec.e) {
      return 'blue';
    }
  }
  return 'default';
}

type BtNodeProps = {
  node: BtNodeData;
  activeIdx: number;
  selectedDec: BtNodeData | null;
  onSelectDec: (node: BtNodeData | null) => void;
};

function BtNodeTree(props: BtNodeProps) {
  const { node, activeIdx, selectedDec, onSelectDec } = props;
  const color = nodeColor(node, activeIdx, selectedDec);
  const badge = nodeTypeBadge(node.t);
  const abort = node.a ?? BT_ABORT_NONE;
  const kids = children(node);
  const isSelectedDec = selectedDec !== null && node.e === selectedDec.e;
  const isClickableDec =
    node.t === BT_NODE_DECORATOR && abort !== BT_ABORT_NONE;

  function handleClick() {
    if (!isClickableDec) return;
    onSelectDec(isSelectedDec ? null : node);
  }

  let borderColor: string;
  if (color === 'green' || color === 'good') {
    borderColor = '#00cc44';
  } else if (color === 'orange') {
    borderColor = '#ff8800';
  } else if (color === 'blue') {
    borderColor = '#4488ff';
  } else {
    borderColor = '#444';
  }

  const bgColor = color === 'green' ? '#005522' : '#1a1a1a';

  return (
    <div
      style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}
    >
      <div
        onClick={handleClick}
        style={{
          width: `${NODE_WIDTH}px`,
          minHeight: `${NODE_HEIGHT}px`,
          border: `2px solid ${borderColor}`,
          borderRadius: '6px',
          backgroundColor: bgColor,
          padding: '4px 6px',
          cursor: isClickableDec ? 'pointer' : 'default',
          boxSizing: 'border-box',
        }}
      >
        {/* Top row: badge + priority */}
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            fontSize: '10px',
            color: '#888',
            marginBottom: '2px',
          }}
        >
          <span style={{ fontWeight: 'bold' }}>{badge}</span>
          <span>#{node.p}</span>
        </div>

        {/* Label */}
        <div
          style={{
            fontSize: '11px',
            color: color === 'green' ? '#aaffcc' : '#ddd',
            textAlign: 'center',
            wordBreak: 'break-all',
            lineHeight: '1.2',
          }}
        >
          {node.l}
        </div>

        {/* Decorator badges */}
        {node.t === BT_NODE_DECORATOR && (
          <div
            style={{
              display: 'flex',
              gap: '3px',
              marginTop: '3px',
              flexWrap: 'wrap',
            }}
          >
            {abort !== BT_ABORT_NONE && (
              <span
                style={{
                  fontSize: '9px',
                  background: '#225588',
                  borderRadius: '3px',
                  padding: '0 3px',
                  color: '#aaccff',
                }}
              >
                OBS
              </span>
            )}
            {node.i && (
              <span
                style={{
                  fontSize: '9px',
                  background: '#552222',
                  borderRadius: '3px',
                  padding: '0 3px',
                  color: '#ffaaaa',
                }}
              >
                NOT
              </span>
            )}
            {abort === BT_ABORT_SELF && (
              <span style={{ fontSize: '9px', color: '#888' }}>SELF</span>
            )}
            {abort === BT_ABORT_LOWER_PRIORITY && (
              <span style={{ fontSize: '9px', color: '#888' }}>LO-PRI</span>
            )}
            {abort === BT_ABORT_BOTH && (
              <span style={{ fontSize: '9px', color: '#888' }}>BOTH</span>
            )}
          </div>
        )}
      </div>

      {/* Children */}
      {kids.length > 0 && (
        <>
          <div
            style={{
              width: '2px',
              height: `${V_GAP / 2}px`,
              background: '#555',
            }}
          />
          <div
            style={{
              display: 'flex',
              flexDirection: 'row',
              gap: `${H_GAP}px`,
              position: 'relative',
            }}
          >
            {kids.length > 1 && (
              <div
                style={{
                  position: 'absolute',
                  top: '0',
                  left: `${NODE_WIDTH / 2}px`,
                  right: `${NODE_WIDTH / 2}px`,
                  height: '2px',
                  background: '#555',
                }}
              />
            )}
            {kids.map((child) => (
              <div
                key={child.e}
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                }}
              >
                <div
                  style={{
                    width: '2px',
                    height: `${V_GAP / 2}px`,
                    background: '#555',
                  }}
                />
                <BtNodeTree
                  node={child}
                  activeIdx={activeIdx}
                  selectedDec={selectedDec}
                  onSelectDec={onSelectDec}
                />
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

export function BehaviorTreeViewer() {
  const { act, data } = useBackend<BehaviorTreeViewerData>();
  const {
    mob_name,
    controller_type,
    active_execution_index,
    awaiting_pick,
    roots,
  } = data;

  const [selectedDec, setSelectedDec] = useState<BtNodeData | null>(null);

  return (
    <Window title="Behavior Tree Viewer" width={1200} height={700}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow>
                  {mob_name ? (
                    <span>
                      <b>{mob_name}</b>
                      <span
                        style={{
                          color: '#888',
                          marginLeft: '8px',
                          fontSize: '11px',
                        }}
                      >
                        {controller_type}
                      </span>
                    </span>
                  ) : (
                    <span style={{ color: '#888' }}>No mob selected</span>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="crosshairs"
                    color={awaiting_pick ? 'yellow' : 'default'}
                    onClick={() => act('pick_mob')}
                  >
                    {awaiting_pick ? 'Click a mob...' : 'Pick Mob'}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="times"
                    color="red"
                    disabled={!mob_name}
                    onClick={() => act('clear')}
                  >
                    Clear
                  </Button>
                </Stack.Item>
              </Stack>
              {selectedDec && (
                <Box mt={1} fontSize="11px" color="blue">
                  Observer: <b>{selectedDec.l}</b> — highlighted nodes would be
                  cancelled. Click node again to deselect.
                  {(selectedDec.k?.length ?? 0) > 0 && (
                    <span style={{ color: '#888', marginLeft: '8px' }}>
                      Watching: {selectedDec.k!.join(', ')}
                    </span>
                  )}
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item grow style={{ minHeight: 0, overflow: 'auto' }}>
            <div style={{ padding: '16px' }}>
              {!roots || roots.length === 0 ? (
                <Box color="gray" textAlign="center" mt={4}>
                  {mob_name
                    ? 'No behavior nodes in controller.'
                    : 'Pick a mob to view its behavior tree.'}
                </Box>
              ) : (
                <div
                  style={{
                    display: 'flex',
                    flexDirection: 'row',
                    gap: '32px',
                    alignItems: 'flex-start',
                  }}
                >
                  {roots.map((root) => (
                    <BtNodeTree
                      key={root.e}
                      node={root}
                      activeIdx={active_execution_index}
                      selectedDec={selectedDec}
                      onSelectDec={setSelectedDec}
                    />
                  ))}
                </div>
              )}
            </div>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
