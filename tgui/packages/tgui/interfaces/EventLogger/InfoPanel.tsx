import type { ReactNode } from 'react';
import { useState } from 'react';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';
import type { Track, TrackInfoEntry } from './types';
import { CATEGORY_PALETTE } from './types';

// Renders a string with **bold** markup as React spans.
export function renderMarkup(text: string): ReactNode {
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

export type InfoPanelProps = {
  tracks: Track[];
  selectedRef: string | null;
  selectedEventIds: Set<number>;
};

export function InfoPanel(props: InfoPanelProps) {
  const { tracks, selectedRef, selectedEventIds } = props;
  const track = selectedRef ? tracks.find((t) => t.ref === selectedRef) : null;

  const [disabledInfoCats, setDisabledInfoCats] = useState<Set<string>>(
    new Set(),
  );

  // Resolve which track_info snapshot to display and whether it's event-specific
  let snapshotEntries: TrackInfoEntry[] | null = null;
  let isLatest = false;

  if (selectedEventIds.size > 0) {
    // Find the highest-id selected event that carries a snapshot
    let bestId = -1;
    for (const t of tracks) {
      for (const evt of t.events) {
        if (
          selectedEventIds.has(evt.id) &&
          evt.track_info?.length &&
          evt.id > bestId
        ) {
          bestId = evt.id;
          snapshotEntries = evt.track_info;
        }
      }
    }
  }

  if (!snapshotEntries && track) {
    let latestId = -1;
    for (const evt of track.events) {
      if (evt.track_info?.length && evt.id > latestId) {
        latestId = evt.id;
        snapshotEntries = evt.track_info;
      }
    }
    if (snapshotEntries) isLatest = true;
  }

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
      if (next.has(cat)) next.delete(cat);
      else next.add(cat);
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
      {!track && !snapshotEntries ? (
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
