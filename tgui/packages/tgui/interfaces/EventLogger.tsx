import { useEffect, useRef, useState } from 'react';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// ── Types ────────────────────────────────────────────────────────────────────

type Category = {
  name: string;
  enabled: boolean;
};

type TrackInfoEntry = {
  category: string;
  title: string;
  entry: string;
};

type BaseEvent = {
  id: number;
  tick: number;
  category: string;
  log_type: 'text' | 'location' | 'turfs' | 'lines' | 'path' | 'maptext';
  info: string;
  track_info?: TrackInfoEntry[];
};

type TextEvent = BaseEvent & { log_type: 'text' };

type LocationEvent = BaseEvent & {
  log_type: 'location';
  x: number;
  y: number;
  z: number;
};

type TurfsEvent = BaseEvent & {
  log_type: 'turfs';
  coords: Array<{ x: number; y: number; z: number }>;
};

type LinesEvent = BaseEvent & {
  log_type: 'lines';
  x1: number;
  y1: number;
  z1: number;
  x2: number;
  y2: number;
  z2: number;
};

type PathEvent = BaseEvent & {
  log_type: 'path';
  coords: Array<{ x: number; y: number; z: number }>;
};

type MapTextEvent = BaseEvent & {
  log_type: 'maptext';
  x: number;
  y: number;
  z: number;
  text: string;
};

type EventEntry =
  | TextEvent
  | LocationEvent
  | TurfsEvent
  | LinesEvent
  | PathEvent
  | MapTextEvent;

type InfoPair = { title: string; entry: string };

type Track = {
  name: string;
  ref: string;
  events: EventEntry[];
  info: InfoPair[];
};

type EventLoggerData = {
  running: boolean;
  time_start: number | null;
  time_current: number;
  categories: Category[];
  tracks: Track[];
  selected_ref: string | null;
  awaiting_pick: boolean;
};

// ── Category colour palette (mirrors DM _build_category_colors) ──────────────

const CATEGORY_PALETTE = [
  '#4fc3f7',
  '#81c784',
  '#ffb74d',
  '#e57373',
  '#ba68c8',
  '#4dd0e1',
  '#fff176',
  '#f06292',
  '#a1887f',
  '#90a4ae',
];

function buildCategoryColors(categories: Category[]): Record<string, string> {
  const map: Record<string, string> = {};
  categories.forEach((cat, i) => {
    map[cat.name] = CATEGORY_PALETTE[i % CATEGORY_PALETTE.length];
  });
  return map;
}

const LOG_TYPE_LABELS: Record<string, string> = {
  text: 'TXT',
  location: 'LOC',
  turfs: 'TURF',
  lines: 'LINE',
  path: 'PATH',
  maptext: 'MAPTXT',
};

const LOG_TYPE_COLORS: Record<string, string> = {
  text: '#aaaaaa',
  location: '#4fc3f7',
  turfs: '#81c784',
  lines: '#ffb74d',
  path: '#ce93d8',
  maptext: '#ffe082',
};

// ── Coord helper ──────────────────────────────────────────────────────────────

function getEventPrimaryCoord(
  evt: EventEntry,
): { x: number; y: number; z: number } | null {
  switch (evt.log_type) {
    case 'location':
    case 'maptext':
      return { x: evt.x, y: evt.y, z: evt.z };
    case 'turfs':
    case 'path':
      return evt.coords.length > 0 ? evt.coords[0] : null;
    case 'lines':
      return { x: evt.x1, y: evt.y1, z: evt.z1 };
    default:
      return null;
  }
}

// ────────────────────────────────────────────────────────────────────────────

type LogTypeBadgeProps = { log_type: string };

function LogTypeBadge(props: LogTypeBadgeProps) {
  const { log_type } = props;
  return (
    <Box
      inline
      style={{
        background: LOG_TYPE_COLORS[log_type] || '#555',
        color: '#000',
        borderRadius: '3px',
        padding: '0 4px',
        fontSize: '10px',
        fontWeight: 'bold',
        marginRight: '6px',
        verticalAlign: 'middle',
      }}
    >
      {LOG_TYPE_LABELS[log_type] || log_type.toUpperCase()}
    </Box>
  );
}

// ── ControlBar ────────────────────────────────────────────────────────────────

type ControlBarProps = {
  running: boolean;
  zoom: number;
  awaitingPick: boolean;
  autoScroll: boolean;
  onAutoScrollChange: (val: boolean) => void;
  act: (action: string, params?: object) => void;
};

function ControlBar(props: ControlBarProps) {
  const { running, zoom, awaitingPick, autoScroll, onAutoScrollChange, act } =
    props;
  return (
    <Stack align="center" p={0.5}>
      <Stack.Item>
        <Button
          icon={running ? 'stop' : 'play'}
          color={running ? 'bad' : 'good'}
          onClick={() => act('toggle_running')}
        >
          {running ? 'Stop' : 'Start'}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="trash"
          color="average"
          onClick={() => act('clear')}
          disabled={running}
        >
          Clear
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="crosshairs"
          color={awaitingPick ? 'caution' : 'transparent'}
          selected={awaitingPick}
          onClick={() => act('start_pick_target')}
        >
          {awaitingPick ? 'Click a target...' : 'Pick Target'}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="angles-right"
          selected={autoScroll}
          tooltip="Auto-scroll timeline to the latest event"
          onClick={() => onAutoScrollChange(!autoScroll)}
        >
          Follow
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Box inline color="label">
          Zoom: {zoom}x
        </Box>
      </Stack.Item>
    </Stack>
  );
}

// ── CategoryBar ───────────────────────────────────────────────────────────────

type CategoryBarProps = {
  categories: Category[];
  colors: Record<string, string>;
  act: (action: string, params?: object) => void;
};

function CategoryBar(props: CategoryBarProps) {
  const { categories, colors, act } = props;
  if (!categories.length) {
    return (
      <Box p={0.5} color="label" italic>
        No categories logged yet.
      </Box>
    );
  }
  return (
    <Stack wrap p={0.5}>
      {categories.map((cat) => (
        <Stack.Item key={cat.name}>
          <Button
            selected={cat.enabled}
            style={{
              borderLeft: `4px solid ${colors[cat.name] || '#888'}`,
            }}
            onClick={() => act('toggle_category', { name: cat.name })}
          >
            {cat.name}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}

// Time line

const LABEL_WIDTH = 160;
const ROW_HEIGHT = 32;
const MARK_SIZE = 10;
const MIN_TIME_RANGE = 10; // minimum denominator in ticks to avoid div-by-zero

type TimelinePanelProps = {
  tracks: Track[];
  categories: Category[];
  colors: Record<string, string>;
  timeStart: number;
  timeCurrent: number;
  zoom: number;
  running: boolean;
  selectedRef: string | null;
  selectedEventIds: Set<number>;
  autoScroll: boolean;
  onSelectTrack: (ref: string) => void;
  onClickEvents: (evts: EventEntry[], ctrlKey: boolean) => void;
  onZoomChange: (newZoom: number) => void;
  act: (action: string, params?: object) => void;
};

function TimelinePanel(props: TimelinePanelProps) {
  const {
    tracks,
    categories,
    colors,
    timeStart,
    timeCurrent,
    zoom,
    running,
    selectedRef,
    selectedEventIds,
    autoScroll,
    onSelectTrack,
    onClickEvents,
    onZoomChange,
    act,
  } = props;

  const scrollRef = useRef<HTMLDivElement>(null);
  const anchorRef = useRef<{
    timeFraction: number;
    mouseOffsetX: number;
  } | null>(null);

  const enabledCategories = new Set(
    categories.filter((c) => c.enabled).map((c) => c.name),
  );

  const timeRange = Math.max(timeCurrent - timeStart, MIN_TIME_RANGE);
  const contentWidth = timeRange * zoom;
  const totalWidth = LABEL_WIDTH + contentWidth;

  // After zoom changes, reposition scroll so the mouse anchor stays fixed
  useEffect(() => {
    const container = scrollRef.current;
    const anchor = anchorRef.current;
    if (!container || !anchor) return;
    anchorRef.current = null;
    const newContentWidth = timeRange * zoom;
    const targetScroll =
      LABEL_WIDTH + anchor.timeFraction * newContentWidth - anchor.mouseOffsetX;
    container.scrollLeft = Math.max(0, targetScroll);
  }, [zoom]);

  // Auto-scroll to the right when new events arrive (only while logger is running)
  useEffect(() => {
    if (!autoScroll || !running) return;
    const container = scrollRef.current;
    if (!container) return;
    container.scrollLeft = container.scrollWidth;
  }, [timeCurrent, autoScroll, running]);

  // Handle our zooming on scroll wheel. Could not find how to do this otherwise so this is a bit shit. If someone knows how to do this correctly let me know
  useEffect(() => {
    const container = scrollRef.current;
    if (!container) return;
    const handler = (e: WheelEvent) => {
      e.preventDefault();
      const delta = e.deltaY < 0 ? 1 : -1;
      const rect = container.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const currentContentWidth = timeRange * zoom;
      const contentMouseX = mouseX + container.scrollLeft - LABEL_WIDTH;
      anchorRef.current = {
        timeFraction: Math.max(0, contentMouseX) / currentContentWidth,
        mouseOffsetX: mouseX,
      };
      onZoomChange(Math.min(40, Math.max(1, zoom + delta)));
    };
    container.addEventListener('wheel', handler, { passive: false });
    return () => container.removeEventListener('wheel', handler);
  }, [zoom, timeRange, onZoomChange]);

  return (
    <div
      ref={scrollRef}
      style={{
        overflowX: 'auto',
        overflowY: 'scroll',
        height: '100%',
        background: '#1a1a1a',
      }}
    >
      <div
        style={{
          width: `${totalWidth}px`,
          minWidth: '100%',
          minHeight: '100%',
        }}
      >
        {tracks.map((track) => {
          const isSelected = track.ref === selectedRef;
          return (
            <div
              key={track.ref}
              style={{
                display: 'flex',
                height: `${ROW_HEIGHT}px`,
                borderBottom: '1px solid #2a2a2a',
                background: isSelected ? '#2a3a2a' : undefined,
                cursor: 'pointer',
              }}
              onClick={() => onSelectTrack(track.ref)}
            >
              {/* Sticky label */}
              <div
                style={{
                  width: `${LABEL_WIDTH}px`,
                  minWidth: `${LABEL_WIDTH}px`,
                  padding: '0 6px',
                  lineHeight: `${ROW_HEIGHT}px`,
                  fontSize: '11px',
                  color: isSelected ? '#7ec87e' : '#aaa',
                  overflow: 'hidden',
                  whiteSpace: 'nowrap',
                  textOverflow: 'ellipsis',
                  position: 'sticky',
                  left: 0,
                  background: isSelected ? '#1e2e1e' : '#1a1a1a',
                  borderRight: '1px solid #333',
                  zIndex: 2,
                  display: 'flex',
                  alignItems: 'center',
                }}
              >
                <span
                  style={{
                    flex: 1,
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                  }}
                  title={track.name}
                >
                  {track.name}
                </span>
                <span
                  title="Stop tracking this datum"
                  onClick={(e) => {
                    e.stopPropagation();
                    act('disable_evlogging', { ref: track.ref });
                  }}
                  style={{
                    flexShrink: 0,
                    marginLeft: '4px',
                    cursor: 'pointer',
                    color: '#666',
                    fontSize: '10px',
                    lineHeight: 1,
                    padding: '1px 3px',
                    borderRadius: '2px',
                  }}
                  //Is there a better way to do this???
                  onMouseEnter={(e) => {
                    (e.currentTarget as HTMLElement).style.color = '#e57373';
                  }}
                  onMouseLeave={(e) => {
                    (e.currentTarget as HTMLElement).style.color = '#666';
                  }}
                >
                  ✕
                </span>
              </div>

              {/* Event marks */}
              <div
                style={{
                  position: 'relative',
                  width: `${contentWidth}px`,
                  minWidth: `calc(100% - ${LABEL_WIDTH}px)`,
                  height: `${ROW_HEIGHT}px`,
                  overflow: 'hidden',
                }}
              >
                {(() => {
                  // Group enabled events by tick so same-frame events share one mark
                  const tickGroups = new Map<number, EventEntry[]>();
                  for (const evt of track.events) {
                    if (!enabledCategories.has(evt.category)) continue;
                    if (!tickGroups.has(evt.tick)) tickGroups.set(evt.tick, []);
                    tickGroups.get(evt.tick)!.push(evt);
                  }
                  return [...tickGroups.entries()].map(([tick, evts]) => {
                    const first = evts[0];
                    const leftPct = (tick - timeStart) / timeRange;
                    const leftPx = leftPct * contentWidth - MARK_SIZE / 2;
                    const isAnySelected = evts.some((e) =>
                      selectedEventIds.has(e.id),
                    );
                    const color = colors[first.category] || '#888';
                    const allText = evts.every((e) => e.log_type === 'text');
                    const isMulti = evts.length > 1;
                    const tooltip = evts
                      .map((e) => `[${e.log_type}] ${e.info}`)
                      .join('\n');
                    return (
                      <div
                        key={tick}
                        title={tooltip}
                        onClick={(e) => {
                          e.stopPropagation();
                          onClickEvents(evts, e.ctrlKey);
                        }}
                        style={{
                          position: 'absolute',
                          left: `${leftPx}px`,
                          top: `${(ROW_HEIGHT - MARK_SIZE) / 2}px`,
                          width: `${MARK_SIZE}px`,
                          height: `${MARK_SIZE}px`,
                          borderRadius: allText ? '50%' : '2px',
                          background: color,
                          opacity: isAnySelected ? 1 : 0.65,
                          outline: isAnySelected ? `2px solid #fff` : undefined,
                          boxShadow: isMulti
                            ? `0 0 0 2px ${color}88`
                            : undefined,
                          cursor: 'pointer',
                          zIndex: isAnySelected ? 2 : 1,
                        }}
                      >
                        {isMulti && (
                          <span
                            style={{
                              position: 'absolute',
                              top: '-7px',
                              right: '-7px',
                              fontSize: '8px',
                              background: '#111',
                              color: '#fff',
                              borderRadius: '3px',
                              padding: '0 2px',
                              lineHeight: '11px',
                              pointerEvents: 'none',
                            }}
                          >
                            {evts.length}
                          </span>
                        )}
                      </div>
                    );
                  });
                })()}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// Info panel stuff below

// Renders a string with **bold** markup as React spans. Preserves newlines via pre-wrap. I don't think theres an existing way to do this.
function renderMarkup(text: string): React.ReactNode {
  const parts = text.split('**');
  return (
    <span style={{ whiteSpace: 'pre-wrap' }}>
      {parts.map((part, i) =>
        i % 2 === 1 ? (
          <strong key={i}>{part}</strong>
        ) : (
          <span key={i}>{part}</span>
        ),
      )}
    </span>
  );
}

type InfoPanelProps = {
  tracks: Track[];
  selectedRef: string | null;
  selectedEventIds: Set<number>;
};

function InfoPanel(props: InfoPanelProps) {
  const { tracks, selectedRef, selectedEventIds } = props;
  const track = selectedRef ? tracks.find((t) => t.ref === selectedRef) : null;

  const [disabledInfoCats, setDisabledInfoCats] = useState<Set<string>>(
    new Set(),
  );

  // Resolve which track_info snapshot to display and whether it's event-specific
  let snapshotEntries: TrackInfoEntry[] | null = null;
  let isLatest = false;

  if (selectedEventIds.size === 1) {
    const [id] = selectedEventIds;
    for (const t of tracks) {
      const evt = t.events.find((e) => e.id === id);
      if (evt?.track_info?.length) {
        snapshotEntries = evt.track_info;
        break;
      }
    }
  }

  if (!snapshotEntries && track) {
    // Fall back to the most recent event on the selected track that has track_info
    let latestId = -1;
    for (const evt of track.events) {
      if (evt.track_info?.length && evt.id > latestId) {
        latestId = evt.id;
        snapshotEntries = evt.track_info;
      }
    }
    if (snapshotEntries) {
      isLatest = true;
    }
  }

  // Derive ordered unique categories + assign palette colors
  const infoCategoryOrder: string[] = [];
  const infoCategoryColors: Record<string, string> = {};
  if (snapshotEntries) {
    for (const entry of snapshotEntries) {
      const cat = entry.category || 'Info';
      if (!infoCategoryColors[cat]) {
        infoCategoryColors[cat] =
          CATEGORY_PALETTE[infoCategoryOrder.length % CATEGORY_PALETTE.length];
        infoCategoryOrder.push(cat);
      }
    }
  }

  function toggleInfoCat(cat: string) {
    setDisabledInfoCats((prev) => {
      const next = new Set(prev);
      if (next.has(cat)) {
        next.delete(cat);
      } else {
        next.add(cat);
      }
      return next;
    });
  }

  function renderSnapshot(entries: TrackInfoEntry[]) {
    const grouped: Record<string, TrackInfoEntry[]> = {};
    for (const entry of entries) {
      const cat = entry.category || 'Info';
      if (disabledInfoCats.has(cat)) continue;
      if (!grouped[cat]) grouped[cat] = [];
      grouped[cat].push(entry);
    }
    return Object.entries(grouped).map(([cat, items]) => (
      <Section key={cat} title={cat}>
        <LabeledList>
          {items.map((item) => (
            <LabeledList.Item key={item.title} label={item.title}>
              {renderMarkup(item.entry)}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    ));
  }

  return (
    <Section
      title={isLatest ? 'Track Info (latest snapshot)' : 'Track Info'}
      fill
      scrollable
    >
      {!track ? (
        <Box color="label" italic>
          No track selected. Click a row in the timeline.
        </Box>
      ) : !snapshotEntries ? (
        <Box color="label" italic>
          No snapshot available. Events on this track do not carry info
          snapshots.
        </Box>
      ) : (
        <>
          {infoCategoryOrder.length > 1 && (
            <Stack wrap mb={0.5}>
              {infoCategoryOrder.map((cat) => (
                <Stack.Item key={cat}>
                  <Button
                    selected={!disabledInfoCats.has(cat)}
                    style={{
                      borderLeft: `4px solid ${infoCategoryColors[cat]}`,
                    }}
                    onClick={() => toggleInfoCat(cat)}
                  >
                    {cat}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          )}
          {renderSnapshot(snapshotEntries)}
        </>
      )}
    </Section>
  );
}

// ── SelectedEventsPanel ───────────────────────────────────────────────────────

type SelectedEventsPanelProps = {
  tracks: Track[];
  selectedEventIds: Set<number>;
  act: (action: string, params?: object) => void;
};

function SelectedEventsPanel(props: SelectedEventsPanelProps) {
  const { tracks, selectedEventIds, act } = props;
  const scrollRef = useRef<HTMLDivElement>(null);

  // Build id→event lookup
  const eventById: Record<number, EventEntry> = {};
  for (const track of tracks) {
    for (const evt of track.events) {
      eventById[evt.id] = evt;
    }
  }

  const selected = [...selectedEventIds]
    .sort((a, b) => a - b)
    .map((id) => eventById[id])
    .filter(Boolean);

  // Scroll to bottom when selection changes
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [selectedEventIds.size]);

  return (
    <Section title="Selected Events" fill>
      <div
        ref={scrollRef}
        style={{ overflowY: 'auto', height: '100%', padding: '4px' }}
      >
        {!selected.length ? (
          <Box color="label" italic>
            No events selected. Click marks in the timeline. Hold Ctrl to select
            multiple.
          </Box>
        ) : (
          selected.map((evt) => {
            const coord = getEventPrimaryCoord(evt);
            return (
              <Box
                key={evt.id}
                mb={0.5}
                style={{
                  borderLeft: '3px solid #444',
                  paddingLeft: '6px',
                  fontSize: '11px',
                  display: 'flex',
                  alignItems: 'baseline',
                  gap: '4px',
                }}
              >
                <LogTypeBadge log_type={evt.log_type} />
                {coord && (
                  <Button
                    icon="location-arrow"
                    compact
                    tooltip={`TP to (${coord.x},${coord.y},${coord.z})`}
                    onClick={() => act('teleport_to_event', { id: evt.id })}
                  />
                )}
                <Box inline color="label" mr={0.5}>
                  #{evt.id}
                </Box>
                <span style={{ whiteSpace: 'pre-wrap', flex: 1 }}>
                  {evt.info}
                </span>
              </Box>
            );
          })
        )}
      </div>
    </Section>
  );
}

// ── Root component ────────────────────────────────────────────────────────────

export function EventLogger() {
  const { act, data } = useBackend<EventLoggerData>();
  const {
    running,
    time_start,
    time_current,
    categories,
    tracks,
    selected_ref,
    awaiting_pick,
  } = data;

  const [zoom, setZoom] = useState(4);
  const [autoScroll, setAutoScroll] = useState(true);
  const [selectedEventIds, setSelectedEventIds] = useState<Set<number>>(
    new Set(),
  );

  const colors = buildCategoryColors(categories);

  const timeStart = time_start ?? time_current;

  const timelineHeight = 360;

  function handleSelectTrack(ref: string) {
    act('select_track', { ref });
  }

  function handleClickEvents(evts: EventEntry[], ctrlKey: boolean) {
    // Select the track that owns the first event
    const ownerTrack = tracks.find((t) =>
      t.events.some((e) => e.id === evts[0].id),
    );
    if (ownerTrack) act('select_track', { ref: ownerTrack.ref });

    setSelectedEventIds((prev) => {
      const next = new Set(prev);
      if (ctrlKey) {
        // Toggle whole group: if all selected, deselect all; else select all
        const allSelected = evts.every((e) => next.has(e.id));
        if (allSelected) {
          for (const e of evts) next.delete(e.id);
        } else {
          for (const e of evts) next.add(e.id);
        }
      } else {
        const allSelected = evts.every((e) => next.has(e.id));
        if (allSelected && next.size === evts.length) {
          // Only this group was selected — deselect
          next.clear();
        } else {
          next.clear();
          for (const e of evts) next.add(e.id);
        }
      }
      act('select_events', { ids: [...next] });
      return next;
    });
  }

  return (
    <Window title="Event Logger" width={1600} height={1080}>
      <Window.Content>
        <Stack fill vertical>
          {/* Control bar */}
          <Stack.Item>
            <ControlBar
              running={running}
              zoom={zoom}
              awaitingPick={awaiting_pick}
              autoScroll={autoScroll}
              onAutoScrollChange={setAutoScroll}
              act={act}
            />
          </Stack.Item>

          {/* Category toggles */}
          <Stack.Item>
            <CategoryBar categories={categories} colors={colors} act={act} />
          </Stack.Item>

          {/* Timeline — full width row, height capped so bottom panels stay visible */}
          <Stack.Item>
            <div style={{ height: `${timelineHeight}px` }}>
              <TimelinePanel
                tracks={tracks}
                categories={categories}
                colors={colors}
                timeStart={timeStart}
                timeCurrent={time_current}
                zoom={zoom}
                running={running}
                selectedRef={selected_ref}
                selectedEventIds={selectedEventIds}
                autoScroll={autoScroll}
                onSelectTrack={handleSelectTrack}
                onClickEvents={handleClickEvents}
                onZoomChange={setZoom}
                act={act}
              />
            </div>
          </Stack.Item>

          {/* Bottom row: track info + selected events side by side */}
          <Stack.Item height={200}>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <InfoPanel
                  tracks={tracks}
                  selectedRef={selected_ref}
                  selectedEventIds={selectedEventIds}
                />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <SelectedEventsPanel
                  tracks={tracks}
                  selectedEventIds={selectedEventIds}
                  act={act}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
