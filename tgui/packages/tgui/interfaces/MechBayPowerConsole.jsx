import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { formatEnergy } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const MechBayPowerConsole = (props) => {
  const { act, data } = useBackend();
  const { recharge_port } = data;
  const mech = recharge_port && recharge_port.mech;
  const cell = mech && mech.cell;
  return (
    <Window width={400} height={200}>
      <Window.Content>
        <Section
          title="Mech status"
          textAlign="center"
          buttons={
            <Button
              icon="sync"
              content="Sync"
              onClick={() => act('reconnect')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Integrity">
              {(!recharge_port && (
                <NoticeBox>No power port detected. Please re-sync.</NoticeBox>
              )) ||
                (!mech && <NoticeBox>No mech detected.</NoticeBox>) || (
                  <ProgressBar
                    value={mech.health / mech.maxhealth}
                    ranges={{
                      good: [0.7, Infinity],
                      average: [0.3, 0.7],
                      bad: [-Infinity, 0.3],
                    }}
                  />
                )}
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              {(!recharge_port && (
                <NoticeBox>No power port detected. Please re-sync.</NoticeBox>
              )) ||
                (!mech && <NoticeBox>No mech detected.</NoticeBox>) ||
                (!cell && <NoticeBox>No cell is installed.</NoticeBox>) || (
                  <ProgressBar
                    value={cell.charge / cell.maxcharge}
                    ranges={{
                      good: [0.7, Infinity],
                      average: [0.3, 0.7],
                      bad: [-Infinity, 0.3],
                    }}
                  >
                    {formatEnergy(cell.charge) +
                      '/' +
                      formatEnergy(cell.maxcharge)}
                  </ProgressBar>
                )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
