import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  hasPowercell: BooleanLike;
  on: BooleanLike;
  open: BooleanLike;
  anchored: BooleanLike;
  powerLevel: number;
};

export const Electrolyzer = (props) => {
  const { act, data } = useBackend<Data>();
  const { hasPowercell, on, open, anchored, powerLevel } = data;

  return (
    <Window width={400} height={305}>
      <Window.Content>
        <Section
          title="Power"
          buttons={
            <>
              <Button
                icon="eject"
                content="Eject Cell"
                disabled={!hasPowercell || !open}
                onClick={() => act('eject')}
              />
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'On' : 'Off'}
                selected={on}
                disabled={!hasPowercell && !anchored}
                onClick={() => act('power')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Cell" color={!hasPowercell ? 'bad' : ''}>
              {(hasPowercell && (
                <ProgressBar
                  value={powerLevel / 100}
                  ranges={{
                    good: [0.6, Infinity],
                    average: [0.3, 0.6],
                    bad: [-Infinity, 0.3],
                  }}
                />
              )) ||
                'None'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
