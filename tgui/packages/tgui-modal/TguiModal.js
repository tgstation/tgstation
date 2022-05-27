import { Input } from 'tgui/components';

export const TguiModal = () => {
  return (
    <div className="tginput-window">
      <div className="tginput-channel">{`>`}</div>
      <Input
        autoFocus
        monospace
        onEscape={() => Byond.sendMessage('close')}
        onEnter={(_, value) => {
          if (!value) {
            Byond.sendMessage('close');
          } else {
            Byond.sendMessage('entry', value);
          }
        }}
        className="tginput-input"
        maxLength={255}
        width="100%"
      />
    </div>
  );
};
