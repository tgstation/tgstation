import { Box, Button, Flex } from '../../components';

import { useBackend } from '../../backend';

type InputButtonsData = {
  large_buttons: boolean;
  swapped_buttons: boolean;
};

type InputButtonsProps = {
  input: string | number | string[];
  message?: string;
};

export const InputButtons = (props: InputButtonsProps, context) => {
  const { act, data } = useBackend<InputButtonsData>(context);
  const { large_buttons, swapped_buttons } = data;
  const { input, message } = props;
  const submitButton = (
    <Button
      color="good"
      fluid={!!large_buttons}
      height={!!large_buttons && 2}
      onClick={() => act('submit', { entry: input })}
      m={0.5}
      pl={2}
      pr={2}
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
      m={0.5}
      pl={2}
      pr={2}
      pt={large_buttons ? 0.33 : 0}
      textAlign="center"
      width={!large_buttons && 6}>
      {large_buttons ? 'CANCEL' : 'Cancel'}
    </Button>
  );

  return (
    <Flex
      align="center"
      direction={!swapped_buttons ? 'row' : 'row-reverse'}
      fill
      justify="space-around">
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
