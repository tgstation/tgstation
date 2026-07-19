type Props = {
  onNavigate: (page: 'home') => void;
  onAction: (action: string) => void;
};

export function LeaveBodyPage({ onNavigate, onAction }: Props) {
  return (
    <>
      <BackButton onClick={() => onNavigate('home')} />
      <div className="escape-menu__leave-body">
        <LargeButton
          label="Suicide"
          iconClass="leave-suicide"
          onClick={() => onAction('suicide')}
        />
        <LargeButton
          label="Ghost"
          iconClass="leave-ghost"
          onClick={() => onAction('ghost')}
        />
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

type LargeButtonProps = {
  label: string;
  iconClass: string;
  onClick: () => void;
};

function LargeButton({ label, iconClass, onClick }: LargeButtonProps) {
  return (
    <button className="escape-menu__large-button" onClick={onClick}>
      <div className="escape-menu__icon-button">
        <span className="escape-menu-icons96x96 leave-template" />
        <span
          className={`escape-menu-icons96x96 ${iconClass} escape-menu__icon-overlay`}
        />
      </div>
      <div className="escape-menu__large-button-label">{label}</div>
    </button>
  );
}
