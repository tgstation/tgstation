type Props = {
  onNavigate: (page: 'home') => void;
  onAction: (action: string) => void;
};

export function QuitPage({ onNavigate, onAction }: Props) {
  return (
    <div className="escape-menu__quit">
      <div className="escape-menu__quit-prompt">
        Are you sure you wish to quit?
      </div>
      <div className="escape-menu__quit-buttons">
        <button
          className="escape-menu__menu-button"
          onClick={() => onAction('quit')}
        >
          Yes
        </button>
        <button
          className="escape-menu__menu-button"
          onClick={() => onNavigate('home')}
        >
          No
        </button>
      </div>
    </div>
  );
}
