import './styles/main.scss';

import { useEffect, useReducer, useRef } from 'react';

import { playCloseSounds, playOpenSounds } from './audio';
import { AdminPage } from './pages/AdminPage';
import { HomePage } from './pages/HomePage';
import { LeaveBodyPage } from './pages/LeaveBodyPage';
import { QuitPage } from './pages/QuitPage';

type Page = 'home' | 'admin' | 'leave_body' | 'quit';

export type ServerState = {
  stationName: string;
  roundId: string;
  mapName: string;
  serverTime: number;
  shiftTime: string | null;
  timeDilation: string;
  canLeaveBody: boolean;
  canAdminHelp: boolean;
  canSeeNotes: boolean;
  hasTicketNotification: boolean;
  resources: ResourceLink[];
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
      return { ...state, isOpen: true, page: 'home', showResources: false };
    case 'close':
      return { ...state, isOpen: false, showResources: false };
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

function sendAction(action: string) {
  Byond.sendMessage('action', { action });
}

function openMenu(dispatch: React.Dispatch<Action>) {
  playOpenSounds();
  dispatch({ type: 'open' });
}

function closeMenu(dispatch: React.Dispatch<Action>) {
  Byond.winset('mapwindow.escape_menu', { 'is-visible': false });
  Byond.winset('map', { focus: true });
  playCloseSounds();
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

    document.addEventListener('keydown', (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        closeMenu(dispatch);
      }
    });
  }, []);

  if (!state.serverState || !state.isOpen) {
    return null;
  }

  const navigate = (page: Page) => dispatch({ type: 'navigate', page });

  const handleAction = (action: string) => {
    if (action === 'resume') {
      closeMenu(dispatch);
      return;
    }
    sendAction(action);
    if (
      ['character', 'settings', 'create_ticket', 'pray', 'see_notes'].includes(
        action,
      )
    ) {
      closeMenu(dispatch);
    }
  };

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
            showResources={state.showResources}
            onToggleResources={() => dispatch({ type: 'toggleResources' })}
          />
        )}
        {state.page === 'admin' && (
          <AdminPage
            serverState={state.serverState}
            onNavigate={navigate}
            onAction={handleAction}
          />
        )}
        {state.page === 'leave_body' && (
          <LeaveBodyPage onNavigate={navigate} onAction={handleAction} />
        )}
        {state.page === 'quit' && (
          <QuitPage onNavigate={navigate} onAction={handleAction} />
        )}
      </div>
    </div>
  );
}

function formatTime(deciseconds: number): string {
  const totalSeconds = Math.floor(deciseconds / 10);
  const h = String(Math.floor(totalSeconds / 3600) % 24).padStart(2, '0');
  const m = String(Math.floor(totalSeconds / 60) % 60).padStart(2, '0');
  const s = String(totalSeconds % 60).padStart(2, '0');
  return `${h}:${m}:${s}`;
}

function Details({ serverState }: { serverState: ServerState }) {
  return (
    <div className="escape-menu__details">
      <div>Round ID: {serverState.roundId || 'Unset'}</div>
      <div>Server Time: {formatTime(serverState.serverTime)}</div>
      <div>Shift Time: {serverState.shiftTime ?? 'Pre-Game'}</div>
      <div>Map: {serverState.mapName || 'Loading...'}</div>
      <div>Time Dilation: {serverState.timeDilation}%</div>
    </div>
  );
}
