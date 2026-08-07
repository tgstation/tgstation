import { useCallback, useEffect, useReducer, useRef, useState } from 'react';
import { Tooltip } from 'tgui-core/components';
import { assetMap } from './assets';
import { playCollapseSound, playExpandSound, playSelectSound } from './audio';

type StationTrait = {
  ref: string;
  name: string;
  description: string;
  iconState: string;
  overlays: string[];
};

export type ServerState = {
  titleImageUrl: string;
  gamePhase: 'startup' | 'pregame' | 'setting_up' | 'playing' | 'postgame';
  isReady: boolean;
  canReady: boolean;
  canJoin: boolean;
  canObserve: boolean;
  assetsReady: boolean;
  countdown: string;
  playerCount: number;
  readyCount: number;
  adminReadyCount: number;
  adminCount: number;
  mapName: string;
  shiftTime: string;
  isAdmin: boolean;
  isLocalhost: boolean;
  stationTraits: StationTrait[];
  hasNewPoll: boolean;
  canPoll: boolean;
  overflowJob: string | null;
  traitFeedback: string | null;
};

type LobbyState = {
  isCollapsed: boolean;
  serverState: ServerState | null;
};

type LobbyAction =
  | { type: 'serverInit'; payload: ServerState }
  | { type: 'serverUpdate'; payload: Partial<ServerState> }
  | { type: 'setCollapsed'; collapsed: boolean };

const DEFAULT_STATE: LobbyState = {
  isCollapsed: false,
  serverState: null,
};

function lobbyReducer(state: LobbyState, action: LobbyAction): LobbyState {
  switch (action.type) {
    case 'serverInit':
      return { ...state, serverState: action.payload };
    case 'serverUpdate':
      if (!state.serverState) return state;
      return {
        ...state,
        serverState: { ...state.serverState, ...action.payload },
      };
    case 'setCollapsed':
      return { ...state, isCollapsed: action.collapsed };
    default:
      return state;
  }
}

function sendAction(action: string, payload?: Record<string, unknown>) {
  Byond.sendMessage('action', { action, ...payload });
}

// --- APNG flick system ---

async function getApngDuration(url: string): Promise<number> {
  try {
    const res = await fetch(url);
    const data = await res.arrayBuffer();
    const decoder = new ImageDecoder({ type: 'image/apng', data });
    await decoder.tracks.ready;
    let total = 0;
    for (let i = 0; i < decoder.tracks.selectedTrack!.frameCount; i++) {
      const result = await decoder.decode({ frameIndex: i });
      total += result.image.duration! / 1000;
      result.image.close();
    }
    decoder.close();
    return total;
  } catch {
    return 300;
  }
}

const durationCache = new Map<string, Promise<number>>();
const blobCache = new Map<string, string>();

function getCachedDuration(url: string): Promise<number> {
  let p = durationCache.get(url);
  if (!p) {
    p = getApngDuration(url);
    durationCache.set(url, p);
  }
  return p;
}

function preloadApng(assetKey: string) {
  const url = assetMap[assetKey];
  if (!url || blobCache.has(assetKey)) return;
  blobCache.set(assetKey, url);
  fetch(url)
    .then((r) => r.blob())
    .then((blob) => {
      const blobUrl = URL.createObjectURL(blob);
      blobCache.set(assetKey, blobUrl);
      getCachedDuration(blobUrl);
    })
    .catch(() => {});
}

function getPreloadedUrl(assetKey: string): string | null {
  return blobCache.get(assetKey) ?? assetMap[assetKey] ?? null;
}

function useFlick(assetKey: string): [() => void, React.ReactNode] {
  const [count, setCount] = useState(0);
  const [activeUrl, setActiveUrl] = useState<string | null>(null);

  useEffect(() => {
    preloadApng(assetKey);
  }, [assetKey]);

  const trigger = useCallback(() => {
    const url = getPreloadedUrl(assetKey);
    if (!url) return;
    setActiveUrl(url);
    setCount((c) => c + 1);
    getCachedDuration(url).then((ms) => {
      setTimeout(() => setActiveUrl(null), ms);
    });
  }, [assetKey]);

  const element = activeUrl ? (
    <img key={count} className="sprite-btn__pressed" src={activeUrl} alt="" />
  ) : null;

  return [trigger, element];
}

// --- Sprite button ---

function SpriteButton({
  spriteClass,
  iconState,
  enabled = true,
  onClick,
  children,
  pressedKey,
}: {
  spriteClass: string;
  iconState: string;
  enabled?: boolean;
  onClick?: React.MouseEventHandler;
  children?: React.ReactNode;
  pressedKey?: string;
}) {
  const displayState = enabled ? iconState : `${iconState}_disabled`;
  const key = pressedKey ?? iconState;
  const [triggerFlick, flickElement] = useFlick(`${key}_pressed.png`);

  return (
    <button
      className={`sprite-btn ${!enabled ? 'sprite-btn--disabled' : ''}`}
      onClick={(e) => {
        if (!enabled) return;
        playSelectSound();
        triggerFlick();
        onClick?.(e);
      }}
      disabled={!enabled}
    >
      <span className={`${spriteClass} ${displayState} sprite-btn__normal`} />
      <span
        className={`${spriteClass} ${iconState}_highlighted sprite-btn__hover`}
      />
      {flickElement}
      {children}
    </button>
  );
}

// --- Trait feedback toast ---

function TraitFeedback({ text }: { text: string }) {
  const [visible, setVisible] = useState(true);

  useEffect(() => {
    setVisible(true);
    const timer = setTimeout(() => setVisible(false), 1500);
    return () => clearTimeout(timer);
  }, [text]);

  if (!visible) return null;

  return (
    <div className="lobby__el lobby__trait-feedback" key={text}>
      {text}
    </div>
  );
}

// --- Shutter animation timing ---
const SHUTTER_MOVE_MS = 400;
const SHUTTER_WAIT_MS = 200;
const EASE_OUT = 'cubic-bezier(0.33, 1, 0.68, 1)';
const EASE_IN = 'cubic-bezier(0.32, 0, 0.67, 0)';

export function LobbyMenu() {
  const [state, dispatch] = useReducer(lobbyReducer, DEFAULT_STATE);
  const [animating, setAnimating] = useState(false);
  const shutterRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    Byond.subscribeTo('init', (payload: ServerState) => {
      dispatch({ type: 'serverInit', payload });
    });

    Byond.subscribeTo('state', (payload: Partial<ServerState>) => {
      dispatch({ type: 'serverUpdate', payload });
    });
  }, []);

  const ss = state.serverState;
  if (!ss) {
    return null;
  }

  const backgroundStyle = ss.titleImageUrl
    ? {
        backgroundImage: `url(${ss.titleImageUrl})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
      }
    : undefined;

  const collapsed = state.isCollapsed;
  const blipEnabled = ss.gamePhase === 'pregame' || ss.gamePhase === 'startup';
  const collapseIcon = collapsed ? 'expand' : 'collapse';

  let blipState = 'ready_blip_disabled';
  if (blipEnabled) {
    blipState = ss.isReady ? 'ready_blip_ready' : 'ready_blip_not_ready';
  }

  // Compute the shutter travel distance from CSS --icon-scale
  function getShutterDistance(): number {
    const scale = parseFloat(
      getComputedStyle(document.documentElement).getPropertyValue(
        '--icon-scale',
      ) || '1',
    );
    // 143px at native scale = shutter travel distance
    return 143 * scale;
  }

  async function handleToggleCollapse() {
    if (animating) return;
    setAnimating(true);

    const shutter = shutterRef.current;

    if (!collapsed) {
      playCollapseSound();

      if (shutter) {
        const dist = getShutterDistance();

        await shutter.animate(
          [
            { transform: 'translateY(0)' },
            { transform: `translateY(${dist}px)` },
          ],
          { duration: SHUTTER_MOVE_MS, easing: EASE_OUT, fill: 'forwards' },
        ).finished;

        await new Promise((r) => setTimeout(r, SHUTTER_WAIT_MS));

        for (const a of shutter.getAnimations()) a.cancel();
        shutter.animate(
          [
            { transform: `translateY(${dist}px)` },
            { transform: 'translateY(0)' },
          ],
          { duration: SHUTTER_MOVE_MS, easing: EASE_IN, fill: 'forwards' },
        );
      }

      dispatch({ type: 'setCollapsed', collapsed: true });

      await new Promise((r) => setTimeout(r, SHUTTER_MOVE_MS));
      if (shutter) {
        for (const a of shutter.getAnimations()) a.cancel();
      }
    } else {
      // EXPANDING
      playExpandSound();

      if (shutter) {
        const dist = getShutterDistance();

        shutter.animate(
          [
            { transform: 'translateY(0)' },
            { transform: `translateY(${dist}px)` },
          ],
          { duration: SHUTTER_MOVE_MS, easing: EASE_OUT, fill: 'forwards' },
        );
      }

      dispatch({ type: 'setCollapsed', collapsed: false });

      await new Promise((r) => setTimeout(r, SHUTTER_MOVE_MS));

      if (shutter) {
        const dist = getShutterDistance();

        await new Promise((r) => setTimeout(r, SHUTTER_WAIT_MS));

        for (const a of shutter.getAnimations()) a.cancel();
        await shutter.animate(
          [
            { transform: `translateY(${dist}px)` },
            { transform: 'translateY(0)' },
          ],
          { duration: SHUTTER_MOVE_MS, easing: EASE_IN, fill: 'forwards' },
        ).finished;

        for (const a of shutter.getAnimations()) a.cancel();
      }
    }

    setAnimating(false);
  }

  // Info TV text
  const roundStarted = ss.gamePhase === 'playing';
  const postgame = ss.gamePhase === 'postgame';
  let tvLines: string[];
  if (postgame) {
    tvLines = ['Game ended,', 'restart soon'];
  } else if (roundStarted) {
    tvLines = [
      ss.mapName,
      `${ss.playerCount} player${ss.playerCount !== 1 ? 's' : ''} online`,
      `${ss.shiftTime} in`,
    ];
  } else if (ss.isAdmin) {
    tvLines = [
      `Starting in ${ss.countdown}`,
      `${ss.playerCount} player${ss.playerCount !== 1 ? 's' : ''}`,
      `${ss.readyCount} players ready`,
      `${ss.adminReadyCount} / ${ss.adminCount} admins ready`,
    ];
  } else {
    tvLines = [
      ss.countdown,
      `${ss.playerCount} player${ss.playerCount !== 1 ? 's' : ''}`,
    ];
  }

  return (
    <div className="lobby" style={backgroundStyle}>
      <div className="lobby__anchor">
        {/* Background panel */}
        <div
          className={`lobby__el lobby__el--bg ${collapsed ? 'lobby__el--collapse-up' : ''}`}
        >
          <span className="lobby-icons151x123 background lobby__sprite" />
        </div>

        {/* Ready button (pregame) */}
        {!!ss.canReady && (
          <div
            className={`lobby__el lobby__el--ready ${collapsed ? 'lobby__el--collapse-up' : ''}`}
          >
            <SpriteButton
              spriteClass="lobby-icons160x28"
              iconState={ss.isReady ? 'ready' : 'not_ready'}
              onClick={() => sendAction('ready_toggle')}
            />
          </div>
        )}

        {/* Join Game button (round started) */}
        {!!ss.canJoin && (
          <div
            className={`lobby__el lobby__el--join ${collapsed ? 'lobby__el--collapse-up' : ''}`}
          >
            <SpriteButton
              spriteClass="lobby-icons145x21"
              iconState="join_game"
              onClick={(e) => sendAction('join', { ctrlClick: e.ctrlKey })}
            />
          </div>
        )}

        {/* Observe */}
        <div
          className={`lobby__el lobby__el--observe ${collapsed ? 'lobby__el--collapse-up' : ''}`}
        >
          <SpriteButton
            spriteClass="lobby-icons139x22"
            iconState="observe"
            enabled={!!ss.canObserve}
            onClick={() => sendAction('observe')}
          />
        </div>

        {/* Character Setup */}
        <div
          className={`lobby__el lobby__el--character ${collapsed ? 'lobby__el--collapse-up' : ''}`}
        >
          <SpriteButton
            spriteClass="lobby-icons139x37"
            iconState="character_setup"
            enabled={!!ss.assetsReady}
            onClick={() => sendAction('character_setup')}
          />
        </div>

        {/* Shutter — animated via JS Web Animations API */}
        <div className="lobby__el lobby__el--shutter" ref={shutterRef}>
          <span className="lobby-icons175x130 shutter lobby__sprite" />
        </div>

        {/* Collapse/Expand button — moves less than other elements */}
        <div
          className={`lobby__el lobby__el--collapse ${collapsed ? 'lobby__el--collapse-slide' : ''}`}
        >
          <button
            className="sprite-btn sprite-btn--no-press"
            onClick={handleToggleCollapse}
            disabled={animating}
          >
            <span
              className={`lobby-icons26x66 ${collapseIcon} sprite-btn__normal`}
            />
            <span
              className={`lobby-icons26x66 ${collapseIcon}_highlighted sprite-btn__hover`}
            />
            <span className={`lobby-icons26x66 ${blipState} lobby__blip`} />
          </button>
        </div>

        {/* Bottom buttons */}
        <div
          className={`lobby__el lobby__el--bottom-poll ${collapsed ? 'lobby__el--collapse-up' : ''}`}
        >
          <SpriteButton
            spriteClass="lobby-icons24x24"
            iconState="bottom-poll"
            pressedKey="poll"
            enabled={!!ss.canPoll}
            onClick={() => sendAction('poll')}
          >
            {!!ss.hasNewPoll && (
              <span className="lobby-icons24x26 new_poll lobby__badge" />
            )}
          </SpriteButton>
        </div>
        <div
          className={`lobby__el lobby__el--bottom-manifest ${collapsed ? 'lobby__el--collapse-up' : ''}`}
        >
          <SpriteButton
            spriteClass="lobby-icons24x24"
            iconState="bottom-crew_manifest"
            pressedKey="crew_manifest"
            onClick={() => sendAction('crew_manifest')}
          />
        </div>
        <div
          className={`lobby__el lobby__el--bottom-settings ${collapsed ? 'lobby__el--collapse-up' : ''}`}
        >
          <SpriteButton
            spriteClass="lobby-icons24x24"
            iconState="bottom-settings"
            pressedKey="settings"
            enabled={!!ss.assetsReady}
            onClick={() => sendAction('settings')}
          />
        </div>
        <div
          className={`lobby__el lobby__el--bottom-changelog ${collapsed ? 'lobby__el--collapse-up' : ''}`}
        >
          <SpriteButton
            spriteClass="lobby-icons24x24"
            iconState="bottom-changelog"
            pressedKey="changelog"
            onClick={() => sendAction('changelog')}
          />
        </div>

        {/* Start Now — localhost only */}
        {!!ss.isLocalhost && (
          <div
            className={`lobby__el lobby__el--start-now ${collapsed ? 'lobby__el--collapse-up' : ''}`}
          >
            <SpriteButton
              spriteClass="lobby-icons138x48"
              iconState="start_now"
              onClick={() => sendAction('start_now')}
            />
          </div>
        )}

        {/* Station trait sign-up buttons */}
        {ss.stationTraits.map((trait, i) => (
          <div
            key={trait.ref}
            className={`lobby__el lobby__el--trait ${collapsed ? 'lobby__el--collapse-up' : ''}`}
            style={
              {
                '--trait-col': Math.floor(i / 3),
                '--trait-row': i % 3,
              } as React.CSSProperties
            }
          >
            <Tooltip content={trait.description} position="bottom">
              <SpriteButton
                spriteClass="lobby-icons24x24"
                iconState={trait.iconState}
                onClick={() => sendAction('sign_up', { ref: trait.ref })}
              >
                {trait.overlays.map((overlay) => (
                  <span
                    key={overlay}
                    className={`lobby-icons24x24 ${overlay} lobby__trait-overlay`}
                  />
                ))}
              </SpriteButton>
            </Tooltip>
          </div>
        ))}

        {/* Trait feedback toast */}
        {!!ss.traitFeedback && <TraitFeedback text={ss.traitFeedback} />}
      </div>

      {/* Info TV — positioned from the right edge */}
      <div className={`lobby__tv ${collapsed ? 'lobby__tv--collapsed' : ''}`}>
        <div className="info-tv">
          <span className="lobby-icons128x96 tv-newplayer info-tv__layer" />
          <span className="lobby-icons128x96 tv-newplayer_overlay info-tv__layer info-tv__overlay" />
          <div className="info-tv__text">
            {tvLines.map((line, i) => (
              <div key={i}>{line}</div>
            ))}
          </div>
          {!collapsed && (
            <>
              {assetMap['static_base.png'] && (
                <img
                  className="info-tv__static"
                  src={assetMap['static_base.png']}
                  alt=""
                />
              )}
              {assetMap['scanline.png'] && (
                <img
                  className="info-tv__scanlines"
                  src={assetMap['scanline.png']}
                  alt=""
                />
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
