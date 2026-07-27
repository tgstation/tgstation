type Props = {
  onNavigate: (page: 'home') => void;
  onAction: (action: string) => void;
};

export function QuitPage({ onNavigate, onAction }: Props) {
  return (
    <div className="escape-menu__quit">
      <div className="escape-menu__quit-prompt">
        Вы уверены что хотите выйти?
      </div>
      <div className="escape-menu__quit-buttons">
        <button
          className="escape-menu__menu-button"
          onClick={() => onAction('quit')}
        >
          Да
        </button>
        <button
          className="escape-menu__menu-button"
          onClick={() => onNavigate('home')}
        >
          Нет
        </button>
      </div>
    </div>
  );
}
