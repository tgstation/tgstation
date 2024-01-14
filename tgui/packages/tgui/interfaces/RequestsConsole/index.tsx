import { useBackend } from '../../backend';
import { Button, Stack } from '../../components';
import { Window } from '../../layouts';
import { RequestsData } from './types';
import { RequestsConsoleHeader } from './RequestsConsoleHeader';
import { RequestMainScreen } from './RequestsConsoleMainScreen';

export const RequestsConsole = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { department } = data;
  return (
    <Window title={department + ' Requests Console'} width={500} height={600}>
      <Window.Content>
        <RequestsConsoleContent />
      </Window.Content>
    </Window>
  );
};

const RequestsConsoleContent = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  return (
    <Stack vertical fill>
      <RequestsConsoleHeader />
      <RequestMainScreen />
      <RequestsConsoleFooter />
    </Stack>
  );
};

const RequestsConsoleFooter = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { silent } = data;
  return (
    <Stack.Item>
      <Button.Checkbox
        fluid
        checked={!silent}
        content={'Speaker'}
        onClick={() => {
          act('toggle_silent');
        }}
      />
    </Stack.Item>
  );
};
