import { useEffect, useRef } from 'react';
import { Box, Button, Section } from 'tgui-core/components';
import { sanitizeText } from '../../sanitize';
import type { EventEntry, Track } from './types';
import {
  getEventPrimaryCoord,
  LOG_TYPE_COLORS,
  LOG_TYPE_LABELS,
} from './types';

type LogTypeBadgeProps = { log_type: string };

export function LogTypeBadge(props: LogTypeBadgeProps) {
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

export type SelectedEventsPanelProps = {
  tracks: Track[];
  selectedEventIds: Set<number>;
  act: (action: string, params?: object) => void;
};

export function SelectedEventsPanel(props: SelectedEventsPanelProps) {
  const { tracks, selectedEventIds, act } = props;
  const scrollRef = useRef<HTMLDivElement>(null);

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
                <span
                  style={{ whiteSpace: 'pre-wrap', flex: 1 }}
                  dangerouslySetInnerHTML={{
                    __html: sanitizeText(evt.info, false, undefined, [
                      'style',
                      'background',
                    ]),
                  }}
                />
              </Box>
            );
          })
        )}
      </div>
    </Section>
  );
}
