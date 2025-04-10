import { Button, LabeledList, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type Data = {
  enabled: BooleanLike;
  lethal: BooleanLike;
  locked: BooleanLike;
  shootCyborgs: BooleanLike;
  siliconUser: BooleanLike;
};

export const TurretControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { enabled, lethal, locked, siliconUser, shootCyborgs } = data;
  const isLocked = locked && !siliconUser;

  return (
    <Window width={305} height={siliconUser ? 168 : 164}>
      <Window.Content>
        <InterfaceLockNoticeBox />
        <Section>
          <LabeledList>
            <LabeledList.Item label="Turret Status">
              <Button
                icon={enabled ? 'power-off' : 'times'}
                content={enabled ? 'Enabled' : 'Disabled'}
                selected={enabled}
                disabled={isLocked}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Turret Mode">
              <Button
                icon={lethal ? 'exclamation-triangle' : 'minus-circle'}
                content={lethal ? 'Lethal' : 'Stun'}
                color={lethal ? 'bad' : 'average'}
                disabled={isLocked}
                onClick={() => act('mode')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Target Cyborgs">
              <Button
                icon={shootCyborgs ? 'check' : 'times'}
                content={shootCyborgs ? 'Yes' : 'No'}
                selected={shootCyborgs}
                disabled={isLocked}
                onClick={() => act('shoot_silicons')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
