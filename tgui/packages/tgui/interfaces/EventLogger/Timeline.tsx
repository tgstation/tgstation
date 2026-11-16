import type { ReactNode } from 'react';
import { useEffect, useRef, useState } from 'react';

export type TimelineMark<T = unknown> = {
  rowId: string;
  tick: number;
  color: string;
  isCircle: boolean;
  isSelected: boolean;
  isMulti: boolean;
  count: number;
  tooltip: string;
  tooltipHtml?: string | null;
  data: T;
};

export type TimelineRow = {
  id: string;
  renderLabel: () => ReactNode;
};

export type TimelineProps<T = unknown> = {
  rows: TimelineRow[];
  marks: TimelineMark<T>[];
  timeStart: number | null;
  timeCurrent: number;
  zoom: number;
  running: boolean;
  autoScroll: boolean;
  /** Ticks between interval ruler lines (default 50 = 5 s at 10 t/s). */
  intervalTicks?: number;
  /** How many ticks are in one second (default 10 as byond is in deciseconds). */
  ticksPerSecond?: number;
  onMarkClick: (mark: TimelineMark<T>, ctrl: boolean) => void;
  onEmptyClick: () => void;
  onZoomChange: (next: number) => void;
};

// Constants

const LABEL_WIDTH = 240;
const ROW_HEIGHT = 36;
const RULER_HEIGHT = 20;
const MARK_RADIUS = 7;
const ZOOM_MAX = 40;

// Component

export function Timeline<T = unknown>(props: TimelineProps<T>) {
  const {
    rows,
    marks,
    timeStart,
    timeCurrent,
    zoom,
    running,
    autoScroll,
    intervalTicks = 50,
    ticksPerSecond = 10,
    onMarkClick,
    onEmptyClick,
    onZoomChange,
  } = props;

  const scrollRef = useRef<HTMLDivElement>(null);
  const outerRef = useRef<HTMLDivElement>(null);
  const anchorRef = useRef<{ tick: number; px: number } | null>(null);
  const [containerWidth, setContainerWidth] = useState(0);
  const [hoverTooltip, setHoverTooltip] = useState<{
    x: number;
    y: number;
    html: string;
  } | null>(null);

  // Track container width so we can compute fit-zoom
  useEffect(() => {
    const el = outerRef.current;
    if (!el) return;
    const ro = new ResizeObserver((entries) => {
      setContainerWidth(entries[0].contentRect.width);
    });
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  // Derived timing

  const elapsed = timeStart !== null ? Math.max(0, timeCurrent - timeStart) : 0;

  const contentAreaWidth = Math.max(0, containerWidth - LABEL_WIDTH);

  /**
   * The virtual duration used for layout. Always at least contentAreaWidth ticks,
   * so at 1x zoom (1px/tick) the timeline always fills the full viewport.
   * As real elapsed time exceeds this, fitZoom drops below 1 and you can zoom out.
   */
  const effectiveElapsed = Math.max(elapsed, contentAreaWidth);

  /**
   * The zoom level at which the full timeline exactly fills the content area.
   * fitZoom == 1 until elapsed overflows the viewport, then shrinks below 1.
   */
  const fitZoom =
    effectiveElapsed > 0 && contentAreaWidth > 0
      ? contentAreaWidth / effectiveElapsed
      : 1;

  // Whenever the stored zoom is below fitZoom, bring it back up (e.g. on open).
  useEffect(() => {
    if (zoom < fitZoom) {
      onZoomChange(fitZoom);
    }
  }, [fitZoom]); // eslint-disable-line react-hooks/estive-deps

  /** px per tick at current zoom — never less than fitZoom */
  const pxPerTick = Math.max(fitZoom, zoom);

  // Ruler interval: auto-double when lines get too close
  let rulerInterval = intervalTicks;
  const minRulerSpacingPx = 60;
  while (rulerInterval * pxPerTick < minRulerSpacingPx) {
    rulerInterval *= 2;
  }

  /** Total content width in px — uses effectiveElapsed so ruler/rows fill the viewport */
  const contentWidth = effectiveElapsed * pxPerTick + rulerInterval * pxPerTick;

  // Auto-scroll: only scroll if the playhead would be off-screen to the right

  useEffect(() => {
    if (!autoScroll || !running || !scrollRef.current) return;
    const container = scrollRef.current;
    const playheadLeft = elapsed * pxPerTick;
    const visibleRight = container.scrollLeft + container.clientWidth;
    if (playheadLeft > visibleRight) {
      container.scrollLeft = playheadLeft - container.clientWidth + 40;
    }
  });

  // Zoom on wheel

  function handleWheel(e: React.WheelEvent<HTMLDivElement>) {
    e.preventDefault();
    const container = scrollRef.current;
    if (!container) return;

    // Save anchor: which tick is under the mouse
    const rect = container.getBoundingClientRect();
    const localX = Math.max(0, e.clientX - rect.left);
    const mouseX = localX + container.scrollLeft;
    const tickUnderMouse = mouseX / pxPerTick;
    anchorRef.current = { tick: tickUnderMouse, px: localX };

    const delta = e.deltaY > 0 ? -1 : 1;
    let next: number;
    if (pxPerTick < 1) {
      next = pxPerTick + delta * 0.1;
    } else {
      next = pxPerTick + delta * 1;
    }
    // Floor is fitZoom so you can never see empty space past the end
    next = Math.max(fitZoom, Math.min(ZOOM_MAX, parseFloat(next.toFixed(1))));
    onZoomChange(next);
  }

  // Re-anchor scroll after zoom change
  useEffect(() => {
    const anchor = anchorRef.current;
    const container = scrollRef.current;
    if (!anchor || !container) return;
    anchorRef.current = null;
    container.scrollLeft = anchor.tick * pxPerTick - anchor.px;
  }, [pxPerTick]);

  // Render

  const contentHeight = rows.length * ROW_HEIGHT + RULER_HEIGHT;

  // Build a map from rowId -> row index for fast position lookup
  const rowIndex: Record<string, number> = {};
  rows.forEach((row, i) => {
    rowIndex[row.id] = i;
  });

  // Ruler tick labels

  const rulerLabels: { tick: number; label: string; leftPx: number }[] = [];
  for (let t = 0; t <= effectiveElapsed + rulerInterval; t += rulerInterval) {
    const seconds = t / ticksPerSecond;
    const leftPx = Math.max(0, t * pxPerTick);
    rulerLabels.push({ tick: t, label: `${seconds}s`, leftPx });
  }

  // Render ruler vertical guide lines (behind rows)

  const rulerGuides = rulerLabels.map(({ tick, leftPx }) => (
    <div
      key={tick}
      style={{
        position: 'absolute',
        left: `${leftPx}px`,
        top: 0,
        bottom: 0,
        width: '1px',
        background: 'rgba(255,255,255,0.07)',
        pointerEvents: 'none',
        zIndex: 0,
      }}
    />
  ));

  // Render mark dots grouped by row

  const markEls = marks.map((mark, i) => {
    const idx = rowIndex[mark.rowId];
    if (idx === undefined) return null;
    const tickOffset = timeStart !== null ? mark.tick - timeStart : mark.tick;
    const rawLeft = Math.max(0, tickOffset * pxPerTick);
    const topPx = RULER_HEIGHT + idx * ROW_HEIGHT + ROW_HEIGHT / 2;

    const size = mark.isMulti ? MARK_RADIUS * 2 + 4 : MARK_RADIUS * 2;

    return (
      <div
        key={i}
        onClick={(e) => {
          e.stopPropagation();
          onMarkClick(mark, e.ctrlKey || e.metaKey);
        }}
        onMouseEnter={(e) => {
          if (mark.tooltipHtml) {
            setHoverTooltip({
              x: e.clientX,
              y: e.clientY,
              html: mark.tooltipHtml,
            });
          }
        }}
        onMouseMove={(e) => {
          if (mark.tooltipHtml) {
            setHoverTooltip({
              x: e.clientX,
              y: e.clientY,
              html: mark.tooltipHtml,
            });
          }
        }}
        onMouseLeave={() => setHoverTooltip(null)}
        style={{
          position: 'absolute',
          left: `${rawLeft - size / 2}px`,
          top: `${topPx - size / 2}px`,
          width: `${size}px`,
          height: `${size}px`,
          borderRadius: mark.isCircle ? '50%' : '2px',
          background: mark.color,
          opacity: mark.isSelected ? 1 : 0.75,
          border: mark.isSelected
            ? '2px solid #fff'
            : '1px solid rgba(0,0,0,0.4)',
          cursor: 'pointer',
          zIndex: mark.isSelected ? 2 : 1,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '9px',
          fontWeight: 'bold',
          color: '#000',
          userSelect: 'none',
        }}
      >
        {mark.isMulti && mark.count > 1 ? mark.count : null}
      </div>
    );
  });

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'row',
        width: '100%',
        height: '100%',
        background: '#1a1a1a',
        overflow: 'hidden',
      }}
      ref={outerRef}
      onWheel={handleWheel}
    >
      {/* Row labels column */}
      <div
        style={{
          flexShrink: 0,
          width: `${LABEL_WIDTH}px`,
          background: '#1a1a1a',
          borderRight: '1px solid #333',
          display: 'flex',
          flexDirection: 'column',
          zIndex: 1,
        }}
      >
        {/* Ruler header space */}
        <div
          style={{
            height: `${RULER_HEIGHT}px`,
            borderBottom: '1px solid #333',
            flexShrink: 0,
          }}
        />
        {/* Row labels */}
        {rows.map((row) => (
          <div
            key={row.id}
            style={{
              height: `${ROW_HEIGHT}px`,
              padding: '0 6px',
              display: 'flex',
              alignItems: 'center',
              overflow: 'hidden',
              borderBottom: '1px solid #222',
              fontSize: '11px',
              color: '#ccc',
              flexShrink: 0,
            }}
          >
            {row.renderLabel()}
          </div>
        ))}
      </div>

      {/* Scrollable content area */}
      <div
        ref={scrollRef}
        style={{
          flex: 1,
          overflowX: 'auto',
          overflowY: 'hidden',
          minWidth: 0,
        }}
      >
        {/* Inner content panel */}
        <div
          onClick={onEmptyClick}
          style={{
            position: 'relative',
            width: `${contentWidth}px`,
            height: `${contentHeight}px`,
            minHeight: '100%',
          }}
        >
          {/* Ruler strip */}
          <div
            style={{
              position: 'sticky',
              top: 0,
              left: 0,
              height: `${RULER_HEIGHT}px`,
              width: '100%',
              zIndex: 4,
              background: '#111',
              borderBottom: '1px solid #333',
            }}
          >
            {rulerLabels.map(({ tick, label, leftPx }) => (
              <div
                key={tick}
                style={{
                  position: 'absolute',
                  left: `${leftPx}px`,
                  top: 0,
                  fontSize: '10px',
                  color: '#888',
                  paddingLeft: '3px',
                  lineHeight: `${RULER_HEIGHT}px`,
                  whiteSpace: 'nowrap',
                  userSelect: 'none',
                }}
              >
                {label}
              </div>
            ))}
          </div>
          {/* Row stripes + guides (behind marks) */}
          {rulerGuides}
          {rows.map((row, i) => (
            <div
              key={row.id}
              style={{
                position: 'absolute',
                top: `${RULER_HEIGHT + i * ROW_HEIGHT}px`,
                left: 0,
                right: 0,
                height: `${ROW_HEIGHT}px`,
                background:
                  i % 2 === 0 ? 'rgba(255,255,255,0.02)' : 'transparent',
                borderBottom: '1px solid #222',
              }}
            />
          ))}
          {/* Marks */}
          {markEls}
          {/* Playhead */}
          {!!running && timeStart !== null && (
            <div
              style={{
                position: 'absolute',
                left: `${elapsed * pxPerTick}px`,
                top: `${RULER_HEIGHT}px`,
                bottom: 0,
                width: '2px',
                background: '#ff5252',
                zIndex: 3,
                pointerEvents: 'none',
              }}
            />
          )}
        </div>
      </div>
      {hoverTooltip && (
        <div
          className="evlog-mark-tooltip"
          style={{
            position: 'fixed',
            left: `${hoverTooltip.x + 14}px`,
            top: `${hoverTooltip.y - 10}px`,
          }}
          dangerouslySetInnerHTML={{ __html: hoverTooltip.html }}
        />
      )}
    </div>
  );
}
