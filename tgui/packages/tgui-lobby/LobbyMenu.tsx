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
  transparent: boolean;
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
    return FALLBACK_APNG_DURATION_MS;
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

/** Helper to get an icon URL from the asset map */
function icon(name: string): string | undefined {
  return assetMap[`${name}.png`];
}

function SpriteButton({
  iconState,
  enabled = true,
  onClick,
  children,
  pressedKey,
}: {
  iconState: string;
  enabled?: boolean;
  onClick?: React.MouseEventHandler;
  children?: React.ReactNode;
  pressedKey?: string;
}) {
  const displayState = enabled ? iconState : `${iconState}_disabled`;
  const key = pressedKey ?? iconState;
  const [triggerFlick, flickElement] = useFlick(`${key}_pressed.png`);
  const [triggerEnabled, enabledElement] = useFlick(`${iconState}_enabled.png`);
  const prevEnabled = useRef(enabled);

  useEffect(() => {
    if (enabled && !prevEnabled.current) {
      triggerEnabled();
    }
    prevEnabled.current = enabled;
  }, [enabled, triggerEnabled]);

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
      <img className="sprite-btn__normal" src={icon(displayState)} alt="" />
      <img
        className="sprite-btn__hover"
        src={icon(`${iconState}_highlighted`)}
        alt=""
      />
      {flickElement}
      {enabledElement}
      {children}
    </button>
  );
}

const scaleCss = (px: number) => `calc(${px}px * var(--lobby-scale, 1))`;

/** Wrapper for absolutely-positioned lobby elements that collapse with the menu. */
function LobbyElement({
  top,
  left,
  zIndex,
  collapsed,
  slide,
  children,
  elRef,
  style,
  noCollapse,
}: {
  top: number;
  left: number;
  zIndex?: number;
  collapsed: boolean;
  slide?: boolean;
  children: React.ReactNode;
  elRef?: React.Ref<HTMLDivElement>;
  style?: React.CSSProperties;
  /** Don't apply collapse animation (e.g. shutter is JS-animated) */
  noCollapse?: boolean;
}) {
  const collapseClass =
    !noCollapse && collapsed
      ? slide
        ? 'lobby__el--collapse-slide'
        : 'lobby__el--collapse-up'
      : '';
  return (
    <div
      ref={elRef}
      className={`lobby__el ${collapseClass}`}
      style={{
        top: scaleCss(top),
        left: scaleCss(left),
        zIndex,
        ...style,
      }}
    >
      {children}
    </div>
  );
}

function TraitFeedback({ text }: { text: string }) {
  const [visible, setVisible] = useState(true);

  useEffect(() => {
    setVisible(true);
    const timer = setTimeout(() => setVisible(false), TRAIT_FEEDBACK_MS);
    return () => clearTimeout(timer);
  }, [text]);

  if (!visible) return null;

  return (
    <div className="lobby__el lobby__trait-feedback" key={text}>
      {text}
    </div>
  );
}

const SHUTTER_TRAVEL_PX = 143;
const SHUTTER_MOVE_MS = 400;
const SHUTTER_WAIT_MS = 200;
const COLLAPSE_SLIDE_PX = 134;
const LOCALHOST_HANDLE_SHIFT_PX = 50;
const LOCALHOST_HANDLE_SHIFT_MS = 200;
const TRAIT_FEEDBACK_MS = 1500;
const MAX_TRAITS_PER_COLUMN = 3;
const FALLBACK_APNG_DURATION_MS = 300;
const EASE_OUT = 'cubic-bezier(0.33, 1, 0.68, 1)';
const EASE_IN = 'cubic-bezier(0.32, 0, 0.67, 0)';

function getLobbyScale(): number {
  return parseFloat(
    document.documentElement.style.getPropertyValue('--lobby-scale') || '1',
  );
}

export function LobbyMenu() {
  const [state, dispatch] = useReducer(lobbyReducer, DEFAULT_STATE);
  const [animating, setAnimating] = useState(false);
  const [tvActive, setTvActive] = useState(true);
  const shutterRef = useRef<HTMLDivElement>(null);
  const collapseRef = useRef<HTMLDivElement>(null);

  const ss = state.serverState;

  useEffect(() => {
    Byond.subscribeTo('init', (payload: ServerState) => {
      dispatch({ type: 'serverInit', payload });
    });

    Byond.subscribeTo('state', (payload: Partial<ServerState>) => {
      dispatch({ type: 'serverUpdate', payload });
    });
  }, []);

  useEffect(() => {
    const bg = ss?.transparent ? 'transparent' : '#000';
    document.documentElement.style.setProperty('--lobby-bg', bg);
    document.documentElement.style.backgroundColor = bg;
    document.body.style.backgroundColor = bg;
  }, [ss?.transparent]);

  if (!ss) {
    return null;
  }

  const backgroundStyle = ss.transparent
    ? undefined
    : ss.titleImageUrl
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

  async function handleToggleCollapse() {
    if (animating) return;
    setAnimating(true);

    const shutter = shutterRef.current;

    if (!collapsed) {
      playCollapseSound();
      setTvActive(false);

      if (shutter) {
        const dist = SHUTTER_TRAVEL_PX * getLobbyScale();

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

      if (ss?.isLocalhost && collapseRef.current) {
        const shift = LOCALHOST_HANDLE_SHIFT_PX * getLobbyScale();
        collapseRef.current.animate(
          [
            {
              transform: `translateY(${-COLLAPSE_SLIDE_PX * getLobbyScale()}px)`,
            },
            {
              transform: `translateY(${-COLLAPSE_SLIDE_PX * getLobbyScale()}px) translateX(${-shift}px)`,
            },
          ],
          {
            duration: LOCALHOST_HANDLE_SHIFT_MS,
            easing: EASE_OUT,
            fill: 'forwards',
          },
        );
      }
    } else {
      playExpandSound();

      if (ss?.isLocalhost && collapseRef.current) {
        const scale = getLobbyScale();
        const shift = 50 * scale;
        const yOff = -COLLAPSE_SLIDE_PX * scale;
        for (const a of collapseRef.current.getAnimations()) a.cancel();
        await collapseRef.current.animate(
          [
            { transform: `translateY(${yOff}px) translateX(${-shift}px)` },
            { transform: `translateY(${yOff}px)` },
          ],
          {
            duration: LOCALHOST_HANDLE_SHIFT_MS,
            easing: EASE_IN,
            fill: 'forwards',
          },
        ).finished;
        for (const a of collapseRef.current.getAnimations()) a.cancel();
      }

      if (shutter) {
        const dist = SHUTTER_TRAVEL_PX * getLobbyScale();

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
        const dist = SHUTTER_TRAVEL_PX * getLobbyScale();

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

      setTvActive(true);
    }

    setAnimating(false);
  }

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
    <div
      className={`lobby ${ss.transparent ? 'lobby--transparent' : ''}`}
      style={backgroundStyle}
    >
      <div className="lobby__anchor">
        <LobbyElement top={0} left={-61} zIndex={1} collapsed={collapsed}>
          <img className="lobby__sprite" src={icon('background')} alt="" />
        </LobbyElement>

        {!!ss.canReady && (
          <LobbyElement top={8} left={-65} zIndex={3} collapsed={collapsed}>
            <SpriteButton
              iconState={ss.isReady ? 'ready' : 'not_ready'}
              onClick={() => sendAction('ready_toggle')}
            />
          </LobbyElement>
        )}

        {!!ss.canJoin && (
          <LobbyElement top={13} left={-58} zIndex={3} collapsed={collapsed}>
            <SpriteButton
              iconState="join_game"
              onClick={(e) => sendAction('join', { ctrlClick: e.ctrlKey })}
            />
          </LobbyElement>
        )}

        <LobbyElement top={40} left={-54} zIndex={3} collapsed={collapsed}>
          <SpriteButton
            iconState="observe"
            enabled={!!ss.canObserve}
            onClick={() => sendAction('observe')}
          />
        </LobbyElement>

        <LobbyElement top={70} left={-54} zIndex={3} collapsed={collapsed}>
          <SpriteButton
            iconState="character_setup"
            enabled={!!ss.assetsReady}
            onClick={() => sendAction('character_setup')}
          />
        </LobbyElement>

        <LobbyElement
          top={-143}
          left={-73}
          zIndex={5}
          collapsed={collapsed}
          noCollapse
          elRef={shutterRef}
        >
          <img className="lobby__sprite" src={icon('shutter')} alt="" />
        </LobbyElement>

        <LobbyElement
          top={82}
          left={-54}
          collapsed={collapsed}
          slide
          elRef={collapseRef}
        >
          <button
            className="sprite-btn sprite-btn--no-press"
            onClick={handleToggleCollapse}
            disabled={animating}
          >
            <img
              className="sprite-btn__normal"
              src={icon(collapseIcon)}
              alt=""
            />
            <img
              className="sprite-btn__hover"
              src={icon(`${collapseIcon}_highlighted`)}
              alt=""
            />
            <img className="lobby__blip" src={icon(blipState)} alt="" />
          </button>
        </LobbyElement>

        {[
          {
            id: 'poll',
            left: -26,
            enabled: !!ss.canPoll,
            badge: ss.hasNewPoll,
          },
          { id: 'crew_manifest', left: 2 },
          { id: 'settings', left: 29, enabled: !!ss.assetsReady },
          { id: 'changelog', left: 57 },
        ].map(({ id, left, enabled, badge }) => (
          <LobbyElement
            key={id}
            top={122}
            left={left}
            zIndex={6}
            collapsed={collapsed}
          >
            <SpriteButton
              iconState={id}
              enabled={enabled}
              onClick={() => sendAction(id)}
            >
              {!!badge && (
                <img className="lobby__badge" src={icon('new_poll')} alt="" />
              )}
            </SpriteButton>
          </LobbyElement>
        ))}

        {!!ss.isLocalhost && (
          <LobbyElement top={146} left={-54} zIndex={3} collapsed={collapsed}>
            <SpriteButton
              iconState="start_now"
              onClick={() => sendAction('start_now')}
            />
          </LobbyElement>
        )}

        {ss.stationTraits.map((trait, i) => (
          <LobbyElement
            key={trait.ref}
            top={40 + (i % MAX_TRAITS_PER_COLUMN) * 27}
            left={-85 - Math.floor(i / MAX_TRAITS_PER_COLUMN) * 27}
            zIndex={3}
            collapsed={collapsed}
          >
            <Tooltip content={trait.description} position="left">
              <div className="lobby__trait-wrapper">
                <SpriteButton
                  iconState={trait.iconState}
                  onClick={() => sendAction('sign_up', { ref: trait.ref })}
                >
                  {trait.overlays.map((overlay) => (
                    <img
                      key={overlay}
                      className="lobby__trait-overlay"
                      src={icon(overlay)}
                      alt=""
                    />
                  ))}
                </SpriteButton>
              </div>
            </Tooltip>
          </LobbyElement>
        ))}

        {!!ss.traitFeedback && <TraitFeedback text={ss.traitFeedback} />}
      </div>

      <div className={`lobby__tv ${collapsed ? 'lobby__tv--collapsed' : ''}`}>
        <div className="info-tv">
          <img className="info-tv__layer" src={icon('newplayer')} alt="" />
          <img
            className="info-tv__layer info-tv__overlay"
            src={icon('newplayer_overlay')}
            alt=""
          />
          {tvActive && (
            <div className="info-tv__text">
              {tvLines.map((line, i) => (
                <div key={i}>{line}</div>
              ))}
            </div>
          )}
          {tvActive && !collapsed && (
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
