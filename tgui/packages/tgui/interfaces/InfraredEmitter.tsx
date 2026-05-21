import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  visible: BooleanLike;
};

export const InfraredEmitter = (props) => {
  const { act, data } = useBackend<Data>();
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
