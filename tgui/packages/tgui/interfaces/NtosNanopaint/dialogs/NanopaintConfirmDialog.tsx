import { sendAct as act } from 'tgui/events/act';
import { Button, Dimmer, Section, Stack } from 'tgui-core/components';

type NanopaintConfirmDialogProps = {
  title: string;
  message: string;
  action: string;
  params: Record<string, unknown>;
};

export const NanopaintConfirmDialog = (props: NanopaintConfirmDialogProps) => {
  const { title, message, action: confirmAct, params } = props;
  return (
    <Dimmer>
      <Section>
        <Stack vertical textAlign="center" align="center">
          <Stack.Item align="start" fontSize="16px">
            {title}
          </Stack.Item>
          <Stack.Item>{message}</Stack.Item>
          <Stack.Item>
            <Stack fill justify="space-evenly">
              <Stack.Item>
                <Button onClick={() => act(confirmAct, params)}>Yes</Button>
              </Stack.Item>
              <Stack.Item>
                <Button onClick={() => act('closeDialog')}>No</Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </Dimmer>
  );
};
