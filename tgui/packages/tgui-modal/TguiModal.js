import { Input } from 'tgui/components';

export const TguiModal = () => {
  return (
    <div className="tguimodal-window">
      <div className="tguimodal-button">{`>`}</div>
      <Input
        autoFocus
        className="tguimodal-input"
        maxLength={255}
        monospace
        onEscape={() => Byond.sendMessage('close')}
        onEnter={(_, value) => {
          if (!value || value.length > max_length) {
            Byond.sendMessage('close');
          } else {
            Byond.sendMessage('entry', value);
          }
        }}
        width="100%"
      />
    </div>
  );
};
