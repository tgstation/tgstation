import { useSelector } from 'common/redux';
import { Button } from 'tgui/components';

const initialState: {
  url?: string,
} = {
  url: undefined,
};

export const reconnectReducer = (state = initialState, action) => {
  const { type, payload } = action;

  if (type === 'reconnect/sendServerUrl') {
    return {
      url: payload.url,
    };
  }

  return state;
};

export const ReconnectButton = (props, context) => {
  const { url } = useSelector(context, state => state.reconnect);

  return url && (
    <Button color="white" onClick={() => {
      location.href = `byond://${url}`;
      Byond.command('.quit');
    }}>
      Reconnect
    </Button>
  );
};
