import type { PlayerInfo, ServerState } from '../EscapeMenu';

type Props = {
  serverState: ServerState;
  onNavigate: (page: 'home') => void;
  onAction: (action: string, payload?: Record<string, unknown>) => void;
};

export function PlayersPage({ serverState, onNavigate, onAction }: Props) {
  return (
    <>
      <BackButton onClick={() => onNavigate('home')} />
      <div className="escape-menu__player-list">
        {serverState.admins.length > 0 ? (
          <PlayerSection title="Admins">
            {serverState.admins.map((admin) => (
              <PlayerEntry
                key={admin.ckey}
                player={admin}
                onToggleIgnore={() =>
                  onAction('toggle_ignore', { ckey: admin.ckey })
                }
              />
            ))}
          </PlayerSection>
        ) : (
          <div className="escape-menu__player-section-title">
            No Admins Online!
          </div>
        )}
        <PlayerSection title="Players">
          {serverState.players.map((player) => (
            <PlayerEntry
              key={player.ckey}
              player={player}
              onToggleIgnore={() =>
                onAction('toggle_ignore', { ckey: player.ckey })
              }
            />
          ))}
        </PlayerSection>
        {serverState.ignoredOffline.length > 0 && (
          <PlayerSection title="Ignored (Offline)">
            {serverState.ignoredOffline.map((ckey) => (
              <div
                key={ckey}
                className="escape-menu__player-entry escape-menu__player-entry--ignored"
              >
                <span
                  className="escape-menu__player-name"
                  onClick={() => onAction('toggle_ignore', { ckey })}
                >
                  {ckey}
                </span>
              </div>
            ))}
          </PlayerSection>
        )}
      </div>
    </>
  );
}

function BackButton({ onClick }: { onClick: () => void }) {
  return (
    <button className="escape-menu__back-button" onClick={onClick}>
      <div className="escape-menu__icon-button">
        <span className="escape-menu-icons40x40 template" />
        <span className="escape-menu-icons40x40 back escape-menu__icon-overlay" />
      </div>
      <span>Back</span>
    </button>
  );
}

function PlayerSection({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="escape-menu__player-section">
      <div className="escape-menu__player-section-title">{title}</div>
      <div className="escape-menu__player-grid">{children}</div>
    </div>
  );
}

function PlayerEntry({
  player,
  onToggleIgnore,
}: {
  player: PlayerInfo;
  onToggleIgnore: () => void;
}) {
  return (
    <div
      className={
        'escape-menu__player-entry' +
        (player.ignored ? ' escape-menu__player-entry--ignored' : '')
      }
    >
      <span
        className="escape-menu__player-name"
        onClick={player.isSelf ? undefined : onToggleIgnore}
      >
        {player.displayName}
        {player.ping !== undefined && (
          <span className="escape-menu__player-ping"> ({player.ping}ms)</span>
        )}
      </span>
      {player.rank && (
        <span
          className={
            'escape-menu__player-rank' +
            (player.feedbackLink ? ' escape-menu__player-rank--link' : '')
          }
          onClick={
            player.feedbackLink
              ? () => Byond.command(`.url ${player.feedbackLink}`)
              : undefined
          }
        >
          {player.rank}
        </span>
      )}
    </div>
  );
}
