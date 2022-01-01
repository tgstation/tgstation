import { useBackend } from '../../backend';
import { Box, Button, Stack } from '../../components';

type InputButtonsData = {
  preferences: Preferences;
};

type InputButtonsProps = {
  input: string | number;
  message?: string;
};

export type Preferences = {
  large_buttons: boolean;
  swapped_buttons: boolean;
};

export const InputButtons = (props: InputButtonsProps, context) => {
  const { act, data } = useBackend<InputButtonsData>(context);
  const { large_buttons = false, swapped_buttons = true } = data.preferences;
  const { input, message } = props;

  const submitButton = (
    <Button
      color="good"
      fluid={!!large_buttons}
      height={!!large_buttons && 2}
      onClick={() => act('submit', { entry: input })}
      pt={large_buttons ? 0.33 : 0}
      textAlign="center"
      tooltip={large_buttons && message}
      width={!large_buttons && 6}>
      {large_buttons ? 'SUBMIT' : 'Submit'}
    </Button>
  );
  const cancelButton = (
    <Button
      color="bad"
      fluid={!!large_buttons}
      height={!!large_buttons && 2}
      onClick={() => act('cancel')}
      pt={large_buttons ? 0.33 : 0}
      textAlign="center"
      width={!large_buttons && 6}>
      {large_buttons ? 'CANCEL' : 'Cancel'}
    </Button>
  );
  const leftButton = !swapped_buttons ? cancelButton : submitButton;
  const rightButton = !swapped_buttons ? submitButton : cancelButton;

  return (
    <Stack>
      {large_buttons ? (
        <Stack.Item grow>{leftButton}</Stack.Item>
      ) : (
        <Stack.Item>{leftButton}</Stack.Item>
      )}
      {!large_buttons && (
        <Stack.Item grow>
          <Box color="label" textAlign="center">
            {message}
          </Box>
        </Stack.Item>
      )}
      {large_buttons ? (
        <Stack.Item grow>{rightButton}</Stack.Item>
      ) : (
        <Stack.Item>{rightButton}</Stack.Item>
      )}
    </Stack>
  );
};
