import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import {
  Box,
  Button,
  InfinitePlane,
  Section,
  Stack,
} from 'tgui-core/components';

import { resolveAsset } from '../../assets';
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
  BT_NODE_SUBPLAN,
  BT_NODE_SUBTREE,
  type BtNodeData,
} from './types';

const NODE_WIDTH = 160;
const NODE_HEIGHT = 70;
const H_GAP = 12;
const V_GAP = 48;
const FADE_DURATION = 1500;

type AnimContextType = {
  recentNodes: Map<number, number>;
  now: number;
};
const AnimContext = createContext<AnimContextType>({
  recentNodes: new Map(),
  now: 0,
});

function fadeOf(
  recentNodes: Map<number, number>,
  execIdx: number,
  now: number,
): number {
  const ts = recentNodes.get(execIdx);
  if (ts === undefined) return 0;
  const age = now - ts;
  return age >= FADE_DURATION ? 0 : 1 - age / FADE_DURATION;
}

function lineColor(f: number): string {
  if (f < 0.01) return '#555';
  const v = Math.round(85 + 170 * f);
  return `rgb(${v}, ${v}, ${v})`;
}

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
    case BT_NODE_SUBPLAN:
      return 'PLAN';
    default:
      return '';
  }
}

function lastIdx(node: BtNodeData): number {
  return node.z ?? node.e;
}

function childNodes(
  node: BtNodeData,
  nodeMap: Map<number, BtNodeData>,
): BtNodeData[] {
  return (node.c ?? []).flatMap((idx) => {
    const n = nodeMap.get(idx);
    return n ? [n] : [];
  });
}

// The pixel width that the subtree rooted at `node` will occupy.
function treeWidth(node: BtNodeData, nodeMap: Map<number, BtNodeData>): number {
  const kids = childNodes(node, nodeMap);
  if (kids.length === 0) return NODE_WIDTH;
  const total = kids.reduce(
    (sum, kid, i) => sum + treeWidth(kid, nodeMap) + (i > 0 ? H_GAP : 0),
    0,
  );
  return Math.max(NODE_WIDTH, total);
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
  nodeIdx: number;
  nodeMap: Map<number, BtNodeData>;
  activeIdx: number;
  selectedDec: BtNodeData | null;
  onSelectDec: (idx: number | null) => void;
};

function BtNodeTree(props: BtNodeProps) {
  const { nodeIdx, nodeMap, activeIdx, selectedDec, onSelectDec } = props;
  const node = nodeMap.get(nodeIdx);
  if (!node) return null;
  const color = nodeColor(node, activeIdx, selectedDec);
  const badge = nodeTypeBadge(node.t);
  const abort = node.a ?? BT_ABORT_NONE;
  const kids = childNodes(node, nodeMap);
  const { recentNodes, now } = useContext(AnimContext);
  const nodeFade = fadeOf(recentNodes, nodeIdx, now);
  const kidFades = kids.map((k) => fadeOf(recentNodes, k.e, now));
  const isSelectedDec = selectedDec !== null && node.e === selectedDec.e;
  const isClickableDec =
    node.t === BT_NODE_DECORATOR && abort !== BT_ABORT_NONE;

  function handleClick() {
    if (!isClickableDec) return;
    onSelectDec(isSelectedDec ? null : nodeIdx);
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

  const nodeTreeWidth = treeWidth(node, nodeMap);
  const connectorCx = nodeTreeWidth / 2;
  let cumChildX = 0;
  const childCenters = kids.map((kid) => {
    const center = cumChildX + treeWidth(kid, nodeMap) / 2;
    cumChildX += treeWidth(kid, nodeMap) + H_GAP;
    return center;
  });

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
          boxShadow:
            nodeFade > 0.01
              ? `0 0 ${Math.round(4 + nodeFade * 14)}px rgba(255, 255, 255, ${(nodeFade * 0.85).toFixed(2)})`
              : undefined,
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
          <svg
            width={nodeTreeWidth}
            height={V_GAP}
            style={{ display: 'block', flexShrink: 0 }}
          >
            {/* Vertical from parent center down to junction */}
            <line
              x1={connectorCx}
              y1={0}
              x2={connectorCx}
              y2={V_GAP / 2}
              stroke={lineColor(nodeFade)}
              strokeWidth={2}
            />
            {/* Per-child: horizontal arm from spine to child, then vertical down */}
            {kids.map((kid, i) => {
              const kx = childCenters[i];
              const fade = kidFades[i] ?? 0;
              return (
                <g key={kid.e}>
                  <line
                    x1={Math.min(connectorCx, kx)}
                    y1={V_GAP / 2}
                    x2={Math.max(connectorCx, kx)}
                    y2={V_GAP / 2}
                    stroke={lineColor(fade)}
                    strokeWidth={2}
                  />
                  <line
                    x1={kx}
                    y1={V_GAP / 2}
                    x2={kx}
                    y2={V_GAP}
                    stroke={lineColor(fade)}
                    strokeWidth={2}
                  />
                </g>
              );
            })}
          </svg>
          <div
            style={{ display: 'flex', flexDirection: 'row', gap: `${H_GAP}px` }}
          >
            {kids.map((child) => (
              <BtNodeTree
                key={child.e}
                nodeIdx={child.e}
                nodeMap={nodeMap}
                activeIdx={activeIdx}
                selectedDec={selectedDec}
                onSelectDec={onSelectDec}
              />
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
    fired_indices,
    awaiting_pick,
    roots,
    nodes,
  } = data;

  const nodeMap = useMemo(() => {
    const map = new Map<number, BtNodeData>();
    for (const node of nodes) {
      map.set(node.e, node);
    }
    return map;
  }, [nodes]);

  const [selectedDecIdx, setSelectedDecIdx] = useState<number | null>(null);
  const selectedDec =
    selectedDecIdx !== null ? (nodeMap.get(selectedDecIdx) ?? null) : null;

  const recentNodesRef = useRef<Map<number, number>>(new Map());
  const animRafRef = useRef<number | null>(null);
  const [animNow, setAnimNow] = useState<number>(() => Date.now());

  const startAnimLoop = useCallback(() => {
    if (animRafRef.current !== null) return;
    const tick = () => {
      const curNow = Date.now();
      let anyFading = false;
      for (const ts of recentNodesRef.current.values()) {
        if (curNow - ts < FADE_DURATION) {
          anyFading = true;
          break;
        }
      }
      if (anyFading) {
        setAnimNow(curNow);
        animRafRef.current = requestAnimationFrame(tick);
      } else {
        animRafRef.current = null;
      }
    };
    animRafRef.current = requestAnimationFrame(tick);
  }, []);

  useEffect(() => {
    return () => {
      if (animRafRef.current !== null) {
        cancelAnimationFrame(animRafRef.current);
      }
    };
  }, []);

  useEffect(() => {
    if (!fired_indices?.length && active_execution_index <= 0) return;
    const curNow = Date.now();
    const toStamp = new Set<number>(fired_indices ?? []);
    if (active_execution_index > 0) toStamp.add(active_execution_index);
    for (const node of nodes) {
      for (const idx of toStamp) {
        if (node.e <= idx && idx <= (node.z ?? node.e)) {
          recentNodesRef.current.set(node.e, curNow);
        }
      }
    }
    startAnimLoop();
  }, [active_execution_index, fired_indices, nodes, startAnimLoop]);

  const animCtxValue = useMemo(
    () => ({ recentNodes: recentNodesRef.current, now: animNow }),
    [animNow],
  );

  return (
    <Window title="Behavior Tree Viewer" width={1200} height={700}>
      <Window.Content
        fitted
        style={{
          backgroundImage: 'none',
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        <div style={{ flexShrink: 0 }}>
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
                  onClick={() => act('pick_target')}
                >
                  {awaiting_pick ? 'Click your target...' : 'Pick Mob'}
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
        </div>
        <div style={{ flex: 1, position: 'relative', overflow: 'hidden' }}>
          <AnimContext.Provider value={animCtxValue}>
            <InfinitePlane
              width="100%"
              height="100%"
              backgroundImage={resolveAsset('grid_background.png')}
              imageWidth={900}
              initialLeft={16}
              initialTop={16}
            >
              {roots && roots.length > 0 && (
                <div
                  style={{
                    padding: '16px',
                    display: 'flex',
                    flexDirection: 'row',
                    gap: '32px',
                    alignItems: 'flex-start',
                  }}
                >
                  {roots.map((rootIdx) => (
                    <BtNodeTree
                      key={rootIdx}
                      nodeIdx={rootIdx}
                      nodeMap={nodeMap}
                      activeIdx={active_execution_index}
                      selectedDec={selectedDec}
                      onSelectDec={setSelectedDecIdx}
                    />
                  ))}
                </div>
              )}
            </InfinitePlane>
          </AnimContext.Provider>
          {(!roots || roots.length === 0) && (
            <Box
              color="gray"
              textAlign="center"
              style={{
                position: 'absolute',
                top: '50%',
                left: '50%',
                transform: 'translate(-50%, -50%)',
                zIndex: 5,
                pointerEvents: 'none',
              }}
            >
              {mob_name
                ? 'No behavior nodes in controller.'
                : 'Pick a mob to view its behavior tree.'}
            </Box>
          )}
        </div>
      </Window.Content>
    </Window>
  );
}
