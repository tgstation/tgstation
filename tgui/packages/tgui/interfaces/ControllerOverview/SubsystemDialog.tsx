import {
  Box,
  Button,
  Divider,
  LabeledList,
  Modal,
  Stack,
} from '../../components';
import { SubsystemData } from './types';

type Props = {
  subsystem: SubsystemData;
  onClose: () => void;
};

export function SubsystemDialog(props: Props) {
  const { subsystem, onClose } = props;
  const {
    cost_ms,
    init_order,
    initialization_failure_message,
    last_fire,
    name,
    next_fire,
    tick_overrun,
    tick_usage,
  } = subsystem;

  return (
    <Modal width="85%" ml={7}>
      <Stack fill>
        <Stack.Item grow fontSize="22px">
          {name}
        </Stack.Item>
        <Stack.Item>
          <Button color="bad" icon="times" onClick={onClose} />
        </Stack.Item>
      </Stack>
      <Divider />
      <Box p={1}>
        <LabeledList>
          <LabeledList.Item label="Init Order">{init_order}</LabeledList.Item>
          <LabeledList.Item label="Last Fire">{last_fire}</LabeledList.Item>
          <LabeledList.Item label="Next Fire">{next_fire}</LabeledList.Item>
          <LabeledList.Item label="Cost">{cost_ms}ms</LabeledList.Item>
          <LabeledList.Item label="Tick Usage">
            {(tick_usage * 0.01).toFixed(2)}%
          </LabeledList.Item>
          <LabeledList.Item label="Tick Overrun">
            {(tick_overrun * 0.01).toFixed(2)}%
          </LabeledList.Item>
          {initialization_failure_message && (
            <LabeledList.Item color="bad">
              {initialization_failure_message}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Box>
      <Stack fill justify="space-between">
        <Stack.Item />
        <Stack.Item>
          <Button color="good" onClick={onClose} px={3} py={1}>
            Close
          </Button>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}
