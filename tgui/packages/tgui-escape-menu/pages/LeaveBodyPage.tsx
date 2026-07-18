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
          description="Perform a dramatic suicide in game"
          iconClass="escape-menu-icons96x96 leave-template"
          onClick={() => onAction('suicide')}
        />
        <LargeButton
          label="Ghost"
          description="Exit quietly, leaving your body"
          iconClass="escape-menu-icons96x96 leave-ghost"
          onClick={() => onAction('ghost')}
        />
      </div>
    </>
  );
}

function BackButton({ onClick }: { onClick: () => void }) {
  return (
    <button className="escape-menu__back-button" onClick={onClick}>
      <span className="escape-menu-icons40x40 back" />
      <span>Back</span>
    </button>
  );
}

type LargeButtonProps = {
  label: string;
  description: string;
  iconClass: string;
  onClick: () => void;
};

function LargeButton({
  label,
  description,
  iconClass,
  onClick,
}: LargeButtonProps) {
  return (
    <button className="escape-menu__large-button" onClick={onClick}>
      <span className={iconClass} />
      <div className="escape-menu__large-button-label">{label}</div>
      <div className="escape-menu__large-button-desc">{description}</div>
    </button>
  );
}
