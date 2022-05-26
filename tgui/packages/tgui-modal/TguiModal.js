import { Input } from 'tgui/components';

export const TguiModal = () => {
  return (
    <div className="window">
      <Input
        autoFocus
        onEscape={() => Byond.sendMessage('close')}
        onEnter={(_, value) => Byond.sendMessage('entry', value)}
        className="input"
        maxLength={255}
        width="100%"
      />
    </div>
  );
};
