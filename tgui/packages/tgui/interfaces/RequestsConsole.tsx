import { useBackend } from '../backend';
import { Button, Stack } from '../components';
import { Window } from '../layouts';
import { RequestsData } from './RequestsConsole/Types';
import { RequestsConsoleHeader } from './RequestsConsole/RequestsConsoleHeader';
import { RequestMainScreen } from './RequestsConsole/RequestsConsoleMainScreen';

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

export const RequestsConsoleContent = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  return (
    <Stack vertical fill>
      <RequestsConsoleHeader />
      <RequestMainScreen />
      <RequestsConsoleFooter />
    </Stack>
  );
};

export const RequestsConsoleFooter = (props, context) => {
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
