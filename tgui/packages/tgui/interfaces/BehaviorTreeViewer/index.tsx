import { useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  BT_ABORT_BOTH,
  BT_ABORT_LOWER_PRIORITY,
  BT_ABORT_NONE,
  BT_ABORT_SELF,
  type BehaviorTreeViewerData,
  type BtNodeData,
} from './types';

const NODE_WIDTH = 160;
const NODE_HEIGHT = 70;
const H_GAP = 12;
const V_GAP = 48;

// Returns a short type badge string for composite/decorator nodes.
function nodeTypeBadge(nodeType: BtNodeData['node_type']): string {
  switch (nodeType) {
    case 'sequence':
      return 'SEQ';
    case 'selector':
      return 'SEL';
    case 'parallel':
      return 'PAR';
    case 'decorator':
      return 'DEC';
    case 'subtree':
      return 'SUB';
    default:
      return '';
  }
}

// Returns a human-readable color name for a node given current highlight state.
function nodeColor(
  node: BtNodeData,
  activeIdx: number,
  selectedDec: BtNodeData | null,
): string {
  // Running leaf: bright green fill
  if (
    node.node_type === 'leaf' &&
    activeIdx > 0 &&
    activeIdx === node.execution_index
  ) {
    return 'green';
  }
  // Active in path: green border tint
  if (
    activeIdx > 0 &&
    activeIdx >= node.execution_index &&
    activeIdx <= node.last_execution_index
  ) {
    return 'good';
  }
  // Would-be-cancelled by selected decorator
  if (selectedDec) {
    const abort = selectedDec.observer_abort;
    const inRange =
      node.execution_index >= selectedDec.execution_index &&
      node.execution_index <= selectedDec.last_execution_index;
    const lowerPriority =
      node.execution_index > selectedDec.last_execution_index;

    if (
      (abort === BT_ABORT_SELF && inRange) ||
      (abort === BT_ABORT_LOWER_PRIORITY && lowerPriority) ||
      (abort === BT_ABORT_BOTH && (inRange || lowerPriority))
    ) {
      return 'orange';
    }
    // Selected decorator itself: blue
    if (node.execution_index === selectedDec.execution_index) {
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
  const badge = nodeTypeBadge(node.node_type);
  const isSelectedDec =
    selectedDec !== null &&
    node.execution_index === selectedDec.execution_index;
  const isClickableDec =
    node.node_type === 'decorator' &&
    node.observer_abort !== BT_ABORT_NONE;

  function handleClick() {
    if (!isClickableDec) return;
    onSelectDec(isSelectedDec ? null : node);
  }

  // Node box border color
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
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      {/* Node box */}
      <div
        title={node.full_type}
        onClick={handleClick}
        style={{
          width: `${NODE_WIDTH}px`,
          minHeight: `${NODE_HEIGHT}px`,
          border: `2px solid ${borderColor}`,
          borderRadius: '6px',
          backgroundColor: bgColor,
          padding: '4px 6px',
          cursor: isClickableDec ? 'pointer' : 'default',
          position: 'relative',
          boxSizing: 'border-box',
        }}
      >
        {/* Top row: badge (left) + priority (right) */}
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10px', color: '#888', marginBottom: '2px' }}>
          <span style={{ fontWeight: 'bold' }}>{badge}</span>
          <span>#{node.priority_index}</span>
        </div>

        {/* Label */}
        <div style={{
          fontSize: '11px',
          color: color === 'green' ? '#aaffcc' : '#ddd',
          textAlign: 'center',
          wordBreak: 'break-all',
          lineHeight: '1.2',
        }}>
          {node.label}
        </div>

        {/* Decorator badges */}
        {node.node_type === 'decorator' && (
          <div style={{ display: 'flex', gap: '3px', marginTop: '3px', flexWrap: 'wrap' }}>
            {node.observer_abort !== BT_ABORT_NONE && (
              <span style={{
                fontSize: '9px',
                background: '#225588',
                borderRadius: '3px',
                padding: '0 3px',
                color: '#aaccff',
              }}>
                OBS
              </span>
            )}
            {node.invert && (
              <span style={{
                fontSize: '9px',
                background: '#552222',
                borderRadius: '3px',
                padding: '0 3px',
                color: '#ffaaaa',
              }}>
                NOT
              </span>
            )}
            {node.observer_abort === BT_ABORT_SELF && (
              <span style={{ fontSize: '9px', color: '#888' }}>SELF</span>
            )}
            {node.observer_abort === BT_ABORT_LOWER_PRIORITY && (
              <span style={{ fontSize: '9px', color: '#888' }}>LO-PRI</span>
            )}
            {node.observer_abort === BT_ABORT_BOTH && (
              <span style={{ fontSize: '9px', color: '#888' }}>BOTH</span>
            )}
          </div>
        )}
      </div>

      {/* Children row */}
      {node.children.length > 0 && (
        <>
          {/* Vertical connector from node to child row */}
          <div style={{ width: '2px', height: `${V_GAP / 2}px`, background: '#555' }} />
          <div style={{ display: 'flex', flexDirection: 'row', gap: `${H_GAP}px`, position: 'relative' }}>
            {/* Horizontal connector bar spanning children */}
            {node.children.length > 1 && (
              <div style={{
                position: 'absolute',
                top: '0',
                left: `${NODE_WIDTH / 2}px`,
                right: `${NODE_WIDTH / 2}px`,
                height: '2px',
                background: '#555',
              }} />
            )}
            {node.children.map((child) => (
              <div key={child.execution_index} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                {/* Vertical stub down to child */}
                <div style={{ width: '2px', height: `${V_GAP / 2}px`, background: '#555' }} />
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

  // Clear selected decorator when data changes (e.g. new mob picked)
  // Using key on the tree container handles this naturally.

  return (
    <Window title="Behavior Tree Viewer" width={1200} height={700}>
      <Window.Content>
        <Stack vertical fill>
          {/* Toolbar */}
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow>
                  {mob_name ? (
                    <span>
                      <b>{mob_name}</b>
                      <span style={{ color: '#888', marginLeft: '8px', fontSize: '11px' }}>
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
                  Observer: <b>{selectedDec.label}</b> — highlighted nodes would be cancelled. Click node again to deselect.
                  {selectedDec.observed_keys.length > 0 && (
                    <span style={{ color: '#888', marginLeft: '8px' }}>
                      Watching: {selectedDec.observed_keys.join(', ')}
                    </span>
                  )}
                </Box>
              )}
            </Section>
          </Stack.Item>

          {/* Tree canvas */}
          <Stack.Item grow>
            <div style={{
              overflow: 'auto',
              height: '100%',
              padding: '16px',
            }}>
              {roots.length === 0 ? (
                <Box color="gray" textAlign="center" mt={4}>
                  {mob_name ? 'No behavior nodes in controller.' : 'Pick a mob to view its behavior tree.'}
                </Box>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'row', gap: '32px', alignItems: 'flex-start' }}>
                  {roots.map((root) => (
                    <BtNodeTree
                      key={root.execution_index}
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
