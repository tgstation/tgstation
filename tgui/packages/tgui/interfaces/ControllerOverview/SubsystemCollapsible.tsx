import { useBackend } from '../../backend';
import { Button, Collapsible, LabeledList } from '../../components';
import { SubsystemData } from './types';

type Props = {
  subsystem: SubsystemData;
};

export function SubsystemCollapsible(props: Props) {
  const { act } = useBackend();
  const { subsystem } = props;
  const {
    can_fire,
    cost_ms,
    doesnt_fire,
    init_order,
    initialization_failure_message,
    initialized,
    last_fire,
    name,
    next_fire,
    ref,
    tick_overrun,
    tick_usage,
  } = subsystem;

  let icon = 'play';
  if (!initialized) {
    icon = 'circle-exclamation';
  } else if (doesnt_fire) {
    icon = 'check';
  } else if (!can_fire) {
    icon = 'pause';
  }

  return (
    <Collapsible
      title={name}
      icon={icon}
      buttons={
        <Button
          icon="wrench"
          tooltip="View Variables"
          onClick={() => {
            act('view_variables', { ref: ref });
          }}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Init Order">{init_order}</LabeledList.Item>
        <LabeledList.Item label="Last Fire">{last_fire}</LabeledList.Item>
        <LabeledList.Item label="Next Fire">{next_fire}</LabeledList.Item>
        <LabeledList.Item label="Cost">{cost_ms}ms</LabeledList.Item>
        <LabeledList.Item label="Tick Usage">
          {(tick_usage * 0.01).toFixed(2)}%
        </LabeledList.Item>
        <LabeledList.Item label="Tick Overrun">
          {(tick_overrun * 0.01).toFixed(2)}%``
        </LabeledList.Item>
        {initialization_failure_message ? (
          <LabeledList.Item color="bad">
            {initialization_failure_message}
          </LabeledList.Item>
        ) : undefined}
      </LabeledList>
    </Collapsible>
  );
}
