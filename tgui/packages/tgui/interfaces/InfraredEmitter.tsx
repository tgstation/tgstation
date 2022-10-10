import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, Section, LabeledList } from '../components';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  visible: BooleanLike;
};

export const InfraredEmitter = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { on, visible } = data;

  return (
    <Window width={225} height={110}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'On' : 'Off'}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Visibility">
              <Button
                icon={visible ? 'eye' : 'eye-slash'}
                content={visible ? 'Visible' : 'Invisible'}
                selected={visible}
                onClick={() => act('visibility')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
