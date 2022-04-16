import { Button } from 'tgui/components';

let url: string | null = null;

setInterval(() => {
  Byond.winget('', 'url').then(currentUrl => {
    if (currentUrl) {
      url = currentUrl;
    }
  });
}, 5000);

export const ReconnectButton = (props, context) => {
  return url && (
    <>
      <Button color="white" onClick={() => {
        Byond.command('.reconnect');
      }}>
        Reconnect
      </Button>

      <Button color="white" onClick={() => {
        location.href = `byond://${url}`;
        Byond.command('.quit');
      }}>
        Relaunch game
      </Button>
    </>
  );
};
