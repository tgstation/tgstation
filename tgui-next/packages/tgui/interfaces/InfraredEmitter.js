import { useBackend } from '../backend';
import { Button, Section, LabeledList } from '../components';

export const InfraredEmitter = props => {
  const { act, data } = useBackend(props);
  const {
    on,
    visible,
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Status">
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? 'On' : 'Off'}
            selected={on}
            onClick={() => act('power')} />
        </LabeledList.Item>
        <LabeledList.Item label="Visibility">
          <Button
            icon={visible ? 'eye' : 'eye-slash'}
            content={visible ? 'Visible' : 'Invisible'}
            selected={visible}
            onClick={() => act('visibility')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
