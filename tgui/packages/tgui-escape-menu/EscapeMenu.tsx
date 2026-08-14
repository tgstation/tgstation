import './styles/main.scss';

import { useEffect, useReducer, useRef } from 'react';

import { playCloseSounds, playOpenSounds } from './audio';
import { AdminPage } from './pages/AdminPage';
import { HomePage } from './pages/HomePage';
import { LeaveBodyPage } from './pages/LeaveBodyPage';
import { PlayersPage } from './pages/PlayersPage';
import { QuitPage } from './pages/QuitPage';
import { updateScaling } from './scaling';

type Page = 'home' | 'admin' | 'players' | 'leave_body' | 'quit';

export type PlayerInfo = {
  ckey: string;
  displayName: string;
  rank?: string;
  feedbackLink?: string;
  ping?: number;
  ignored: boolean;
  isSelf?: boolean;
};

export type ServerState = {
  stationName: string;
  roundId: string;
  mapName: string;
  mapFeedbackLink: string | null;
  mapWebmap: string | null;
  serverTime: string;
  shiftTime: string;
  timeDilation: string;
  canLeaveBody: boolean;
  canAdminHelp: boolean;
  canSeeNotes: boolean;
  hasTicketNotification: boolean;
  resources: ResourceLink[];
  admins: PlayerInfo[];
  players: PlayerInfo[];
  ignoredOffline: string[];
  suicideIcon: string | null;
};

export type ResourceLink = {
  id: string;
  label: string;
  tooltip: string;
};

type State = {
  page: Page;
  isOpen: boolean;
  showResources: boolean;
  serverState: ServerState | null;
};

type Action =
  | { type: 'open' }
  | { type: 'close' }
  | { type: 'navigate'; page: Page }
  | { type: 'toggleResources' }
  | { type: 'serverUpdate'; state: Partial<ServerState> };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'open':
      return { ...state, isOpen: true };
    case 'close':
      return { ...state, isOpen: false, page: 'home', showResources: false };
    case 'navigate':
      return { ...state, page: action.page, showResources: false };
    case 'toggleResources':
      return { ...state, showResources: !state.showResources };
    case 'serverUpdate':
      return {
        ...state,
        serverState: { ...state.serverState!, ...action.state },
      };
  }
}

const initialState: State = {
  page: 'home',
  isOpen: false,
  showResources: false,
  serverState: null,
};

function sendAction(action: string, payload?: Record<string, unknown>) {
  Byond.sendMessage('action', { action, ...payload });
}

let resizeFrozen = false;
export function isResizeFrozen() {
  return resizeFrozen;
}

function openMenu(dispatch: React.Dispatch<Action>) {
  setTimeout(() => {
    resizeFrozen = false;
    updateScaling();
  }, 100);
  playOpenSounds();
  sendAction('opened');
  dispatch({ type: 'open' });
}

function closeMenu(dispatch: React.Dispatch<Action>) {
  resizeFrozen = true;
  Byond.winset('mapwindow.escape_menu', { 'is-visible': false });
  Byond.winset('map', { focus: true });
  playCloseSounds();
  sendAction('closed');
  dispatch({ type: 'close' });
}

export function EscapeMenu() {
  const [state, dispatch] = useReducer(reducer, initialState);
  const isOpenRef = useRef(false);
  isOpenRef.current = state.isOpen;

  useEffect(() => {
    Byond.subscribeTo('init', (data: ServerState) => {
      dispatch({ type: 'serverUpdate', state: data });
    });

    Byond.subscribeTo('state', (data: Partial<ServerState>) => {
      dispatch({ type: 'serverUpdate', state: data });
    });

    Byond.subscribeTo('toggle', () => {
      if (isOpenRef.current) {
        closeMenu(dispatch);
      } else {
        openMenu(dispatch);
      }
    });
  }, []);

  if (!state.serverState) {
    return null;
  }

  const navigate = (page: Page) => dispatch({ type: 'navigate', page });

  const handleAction = (action: string, payload?: Record<string, unknown>) => {
    sendAction(action, payload);
  };

  const handleClose = () => closeMenu(dispatch);

  const refocusMap = () => {
    Byond.winset('map', { focus: true });
  };

  return (
    <div className="escape-menu" onClick={refocusMap}>
      <div className="escape-menu__overlay" />
      <div className="escape-menu__content">
        <Details serverState={state.serverState} />
        {state.page === 'home' && (
          <HomePage
            serverState={state.serverState}
            onNavigate={navigate}
            onAction={handleAction}
            onClose={handleClose}
            showResources={state.showResources}
            onToggleResources={() => dispatch({ type: 'toggleResources' })}
          />
        )}
        {state.page === 'admin' && (
          <AdminPage
            serverState={state.serverState}
            onNavigate={navigate}
            onAction={handleAction}
            onClose={handleClose}
          />
        )}
        {state.page === 'players' && (
          <PlayersPage
            serverState={state.serverState}
            onNavigate={navigate}
            onAction={handleAction}
          />
        )}
        {state.page === 'leave_body' && (
          <LeaveBodyPage
            serverState={state.serverState}
            onNavigate={navigate}
            onAction={handleAction}
            onClose={handleClose}
          />
        )}
        {state.page === 'quit' && (
          <QuitPage onNavigate={navigate} onAction={handleAction} />
        )}
      </div>
    </div>
  );
}

function Details({ serverState }: { serverState: ServerState }) {
  return (
    <div className="escape-menu__details">
      <div>Round ID: {serverState.roundId || 'Unset'}</div>
      <div>Server Time: {serverState.serverTime}</div>
      <div>Shift Time: {serverState.shiftTime}</div>
      <div>
        Map:{' '}
        {serverState.mapFeedbackLink ? (
          <span
            className="escape-menu__details-link"
            onClick={() => Byond.command(`.url ${serverState.mapFeedbackLink}`)}
          >
            {serverState.mapName || 'Loading...'}
          </span>
        ) : (
          serverState.mapName || 'Loading...'
        )}
        {!!serverState.mapWebmap && (
          <span
            className="escape-menu__details-link"
            onClick={() => Byond.command(`.url ${serverState.mapWebmap}`)}
          >
            {` (Open Map)`}
          </span>
        )}
      </div>
      <div>Time Dilation: {serverState.timeDilation}%</div>
    </div>
  );
}
