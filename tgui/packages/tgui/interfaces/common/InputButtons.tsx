import { useBackend } from '../../backend';
import { Box, Button, Flex } from '../../components';

type InputButtonsData = {
  large_buttons: boolean;
  swapped_buttons: boolean;
};

type InputButtonsProps = {
  input: string | number | string[];
  on_submit?: () => void;
  on_cancel?: () => void;
  message?: string;
};

export const InputButtons = (props: InputButtonsProps) => {
  const { act, data } = useBackend<InputButtonsData>();
  const { large_buttons, swapped_buttons } = data;
  const { input, message, on_submit, on_cancel } = props;

  let on_submit_actual = on_submit;
  if (!on_submit_actual) {
    on_submit_actual = () => {
      act('submit', { entry: input });
    };
  }

  let on_cancel_actual = on_cancel;
  if (!on_cancel_actual) {
    on_cancel_actual = () => {
      act('cancel');
    };
  }

  const submitButton = (
    <Button
      color="good"
      fluid={!!large_buttons}
      height={!!large_buttons && 2}
      onClick={on_submit_actual}
      m={0.5}
      pl={2}
      pr={2}
      pt={large_buttons ? 0.33 : 0}
      textAlign="center"
      tooltip={large_buttons && message}
      width={!large_buttons && 6}
    >
      {large_buttons ? 'SUBMIT' : 'Submit'}
    </Button>
  );
  const cancelButton = (
    <Button
      color="bad"
      fluid={!!large_buttons}
      height={!!large_buttons && 2}
      onClick={on_cancel_actual}
      m={0.5}
      pl={2}
      pr={2}
      pt={large_buttons ? 0.33 : 0}
      textAlign="center"
      width={!large_buttons && 6}
    >
      {large_buttons ? 'CANCEL' : 'Cancel'}
    </Button>
  );

  return (
    <Flex
      align="center"
      direction={!swapped_buttons ? 'row' : 'row-reverse'}
      fill
      justify="space-around"
    >
      {large_buttons ? (
        <Flex.Item grow>{cancelButton}</Flex.Item>
      ) : (
        <Flex.Item>{cancelButton}</Flex.Item>
      )}
      {!large_buttons && message && (
        <Flex.Item>
          <Box color="label" textAlign="center">
            {message}
          </Box>
        </Flex.Item>
      )}
      {large_buttons ? (
        <Flex.Item grow>{submitButton}</Flex.Item>
      ) : (
        <Flex.Item>{submitButton}</Flex.Item>
      )}
    </Flex>
  );
};
