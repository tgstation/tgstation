import { useEffect, useState } from 'react';

import type { ResourceLink } from '../EscapeMenu';

type ServerState = {
  stationName: string;
  canLeaveBody: boolean;
  canAdminHelp: boolean;
  hasTicketNotification: boolean;
  resources: ResourceLink[];
};

type Props = {
  serverState: ServerState;
  onNavigate: (page: 'admin' | 'leave_body' | 'quit') => void;
  onAction: (action: string) => void;
  showResources: boolean;
  onToggleResources: () => void;
};

const COLLAPSE_DURATION = 400;

export function HomePage({
  serverState,
  onNavigate,
  onAction,
  showResources,
  onToggleResources,
}: Props) {
  const [mounted, setMounted] = useState(false);
  const [collapsing, setCollapsing] = useState(false);

  useEffect(() => {
    if (showResources) {
      setMounted(true);
      setCollapsing(false);
    } else if (mounted) {
      setCollapsing(true);
      const timer = setTimeout(() => {
        setMounted(false);
        setCollapsing(false);
      }, COLLAPSE_DURATION);
      return () => clearTimeout(timer);
    }
  }, [showResources]);

  return (
    <>
      <div className="escape-menu__title">
        <div className="escape-menu__subtitle">Another day on...</div>
        <div className="escape-menu__station-name">
          {serverState.stationName}
        </div>
      </div>
      <div className="escape-menu__buttons">
        <MenuButton onClick={() => onAction('resume')}>Resume</MenuButton>
        <MenuButton onClick={() => onAction('character')}>Character</MenuButton>
        <MenuButton onClick={() => onAction('settings')}>Settings</MenuButton>
        <MenuButton
          onClick={() => onNavigate('admin')}
          disabled={!serverState.canAdminHelp}
          blinking={serverState.hasTicketNotification}
        >
          Admin Help
        </MenuButton>
        <MenuButton
          onClick={() => onNavigate('leave_body')}
          disabled={!serverState.canLeaveBody}
        >
          Leave Body
        </MenuButton>
        <MenuButton onClick={() => onNavigate('quit')}>Quit</MenuButton>
      </div>
      <div className="escape-menu__resources">
        {mounted && (
          <div
            className={
              'escape-menu__resource-list' +
              (collapsing ? ' escape-menu__resource-list--collapsing' : '')
            }
          >
            {serverState.resources.map((resource) => (
              <button
                key={resource.id}
                className="escape-menu__resource-button"
                title={resource.tooltip}
                onClick={() => onAction(`resource_${resource.id}`)}
              >
                <IconButton iconClass={resource.id} />
                <span className="escape-menu__resource-button-label">
                  {resource.label}
                </span>
              </button>
            ))}
          </div>
        )}
        <button
          className="escape-menu__resource-toggle"
          onClick={onToggleResources}
        >
          <IconButton iconClass="resources" />
          <span className="escape-menu__resource-label">Resources</span>
        </button>
      </div>
    </>
  );
}

function IconButton({ iconClass }: { iconClass: string }) {
  return (
    <div className="escape-menu__icon-button">
      <span className="escape-menu-icons40x40 template" />
      <span
        className={`escape-menu-icons40x40 ${iconClass} escape-menu__icon-overlay`}
      />
    </div>
  );
}

type MenuButtonProps = {
  children: React.ReactNode;
  onClick: () => void;
  disabled?: boolean;
  blinking?: boolean;
};

function MenuButton({
  children,
  onClick,
  disabled,
  blinking,
}: MenuButtonProps) {
  return (
    <button
      className={
        'escape-menu__menu-button' +
        (disabled ? ' escape-menu__menu-button--disabled' : '') +
        (blinking ? ' escape-menu__menu-button--blinking' : '')
      }
      onClick={disabled ? undefined : onClick}
    >
      {children}
    </button>
  );
}
