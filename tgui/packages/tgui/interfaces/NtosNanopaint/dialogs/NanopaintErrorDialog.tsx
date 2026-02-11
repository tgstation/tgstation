import { sendAct as act } from 'tgui/events/act';
import { Button, Dimmer, Section, Stack } from 'tgui-core/components';

type NanopaintErrorDialogProps = {
  message: string;
};

export const NanopaintErrorDialog = (props: NanopaintErrorDialogProps) => {
  const { message } = props;
  return (
    <Dimmer>
      <Section>
        <Stack
          vertical
          width="150px"
          height="100px"
          textAlign="center"
          align="center"
        >
          <Stack.Item align="start" fontSize="16px">
            Error
          </Stack.Item>
          <Stack.Item>{message}</Stack.Item>
          <Stack.Item>
            <Stack fill justify="space-evenly">
              <Stack.Item>
                <Button onClick={() => act('closeDialog')}>Ok</Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </Dimmer>
  );
};
