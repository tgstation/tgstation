import { useState } from 'react';
import { Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { sanitizeText } from '../../sanitize';

import { CategoryBar } from './CategoryBar';
import { ControlBar } from './ControlBar';
import { InfoPanel } from './InfoPanel';
import { SelectedEventsPanel } from './SelectedEventsPanel';
import type { TimelineMark, TimelineRow } from './Timeline';
import { Timeline } from './Timeline';
import type { Category, EventEntry, EventLoggerData, Track } from './types';
import { buildCategoryColors } from './types';

// Build the marks in the track

function buildMarks(
  tracks: Track[],
  categories: Category[],
  colors: Record<string, string>,
  timeStart: number | null,
  selectedEventIds: Set<number>,
): TimelineMark<EventEntry[]>[] {
  const marks: TimelineMark<EventEntry[]>[] = [];

  const enabledCats = new Set(
    categories.filter((c) => c.enabled).map((c) => c.name),
  );

  for (const track of tracks) {
    // Group events by tick
    const byTick: Map<number, EventEntry[]> = new Map();
    for (const evt of track.events) {
      if (!enabledCats.has(evt.category)) continue;
      const existing = byTick.get(evt.tick);
      if (existing) {
        existing.push(evt);
      } else {
        byTick.set(evt.tick, [evt]);
      }
    }

    for (const [tick, evts] of byTick) {
      const isSelected = evts.some((e) => selectedEventIds.has(e.id));
      const isMulti = evts.length > 1;
      // Use first event's category color; if mixed, still use first
      const color = colors[evts[0].category] || '#888';
      const isSpatial = evts.some((e) => e.log_type !== 'text');

      marks.push({
        rowId: track.ref,
        tick,
        color,
        isCircle: !isSpatial,
        isSelected,
        isMulti,
        count: evts.length,
        tooltip: isMulti
          ? `${evts.length} events at tick ${tick - (timeStart ?? 0)}`
          : evts[0].info.replace(/<[^>]*>/g, ''),
        tooltipHtml: isMulti
          ? null
          : sanitizeText(evts[0].info, false, undefined, [
              'style',
              'background',
            ]),
        data: evts,
      });
    }
  }

  return marks;
}

// Event logger root

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

  const [zoom, setZoom] = useState(1);
  const [autoScroll, setAutoScroll] = useState(true);
  const [selectedEventIds, setSelectedEventIds] = useState<Set<number>>(
    new Set(),
  );

  const colors = buildCategoryColors(categories);

  const rows: TimelineRow[] = tracks.map((track) => ({
    id: track.ref,
    renderLabel: () => (
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          width: '100%',
          gap: '4px',
          overflow: 'hidden',
        }}
      >
        <span
          style={{
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
            flex: 1,
            cursor: 'pointer',
          }}
          title={track.name.replace(/<[^>]*>/g, '')}
          onClick={() => handleSelectTrack(track)}
          dangerouslySetInnerHTML={{ __html: sanitizeText(track.name) }}
        />
        <button
          title="Remove track and all its events"
          onClick={(e) => {
            e.stopPropagation();
            act('remove_track', { ref: track.ref });
          }}
          style={{
            flexShrink: 0,
            background: 'rgba(255,80,80,0.15)',
            border: '1px solid rgba(255,80,80,0.4)',
            borderRadius: '3px',
            color: '#ff8080',
            cursor: 'pointer',
            fontSize: '10px',
            lineHeight: 1,
            padding: '1px 4px',
          }}
        >
          ✕
        </button>
      </div>
    ),
  }));

  const marks = buildMarks(
    tracks,
    categories,
    colors,
    time_start,
    selectedEventIds,
  );

  function handleSelectTrack(track: Track) {
    act('select_track', { ref: track.ref });
    setSelectedEventIds(new Set());
  }

  function handleMarkClick(mark: TimelineMark<EventEntry[]>, ctrl: boolean) {
    const evtIds = mark.data.map((e) => e.id);

    // Find the track this mark belongs to so we can select it
    const track = tracks.find((t) => t.ref === mark.rowId);
    if (track && selected_ref !== track.ref) {
      act('select_track', { ref: track.ref });
    }

    // Select events on server (for overlay rendering)
    act('select_events', { ids: evtIds });

    setSelectedEventIds((prev) => {
      if (ctrl) {
        // Toggle group: if all already selected, deselect; else add
        const allSelected = evtIds.every((id) => prev.has(id));
        const next = new Set(prev);
        if (allSelected) {
          for (const id of evtIds) next.delete(id);
        } else {
          for (const id of evtIds) next.add(id);
        }
        return next;
      }
      // Replace selection
      return new Set(evtIds);
    });
  }

  return (
    <Window title="Event Logger" width={1600} height={1080}>
      <Window.Content>
        <Stack vertical fill className="EventLogger">
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

          {/* Timeline */}
          <Stack.Item grow={2} basis={0} style={{ minHeight: 0 }}>
            <div style={{ height: '100%' }}>
              <Timeline<EventEntry[]>
                rows={rows}
                marks={marks}
                timeStart={time_start}
                timeCurrent={time_current}
                zoom={zoom}
                running={running}
                autoScroll={autoScroll}
                onMarkClick={handleMarkClick}
                onEmptyClick={() => {
                  setSelectedEventIds(new Set());
                  act('select_events', { ids: [] });
                }}
                onZoomChange={setZoom}
              />
            </div>
          </Stack.Item>

          {/* Bottom row: track info + selected events */}
          <Stack.Item grow={3} basis={0} style={{ minHeight: 0 }}>
            <Stack fill>
              <Stack.Item grow={1} basis={0}>
                <InfoPanel
                  tracks={tracks}
                  selectedRef={selected_ref}
                  selectedEventIds={selectedEventIds}
                />
              </Stack.Item>
              <Stack.Item grow={1} basis={0}>
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
