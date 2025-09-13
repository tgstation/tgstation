import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const dangerMap = {
  2: {
    color: 'good',
    localStatusText: 'Offline',
  },
  1: {
    color: 'average',
    localStatusText: 'Caution',
  },
  0: {
    color: 'bad',
    localStatusText: 'Optimal',
  },
};

export const AiAirlock = (props) => {
  const { act, data } = useBackend();
  const statusMain = dangerMap[data.power.main] || dangerMap[0];
  const statusBackup = dangerMap[data.power.backup] || dangerMap[0];
  const statusElectrify = dangerMap[data.shock] || dangerMap[0];
  return (
    <Window width={500} height={390}>
      <Window.Content>
        <Section title="Power Status">
          <LabeledList>
            <LabeledList.Item
              label="Main"
              color={statusMain.color}
              buttons={
                <Button
                  icon="lightbulb-o"
                  disabled={!data.power.main}
                  content="Disrupt"
                  onClick={() => act('disrupt-main')}
                />
              }
            >
              {data.power.main ? 'Online' : 'Offline'}{' '}
              {((!data.wires.main_1 || !data.wires.main_2) &&
                '[Wires have been cut!]') ||
                (data.power.main_timeleft > 0 &&
                  `[${data.power.main_timeleft}s]`)}
            </LabeledList.Item>
            <LabeledList.Item
              label="Backup"
              color={statusBackup.color}
              buttons={
                <Button
                  icon="lightbulb-o"
                  disabled={!data.power.backup}
                  content="Disrupt"
                  onClick={() => act('disrupt-backup')}
                />
              }
            >
              {data.power.backup ? 'Online' : 'Offline'}{' '}
              {((!data.wires.backup_1 || !data.wires.backup_2) &&
                '[Wires have been cut!]') ||
                (data.power.backup_timeleft > 0 &&
                  `[${data.power.backup_timeleft}s]`)}
            </LabeledList.Item>
            <LabeledList.Item
              label="Electrify"
              color={statusElectrify.color}
              buttons={
                <>
                  <Button
                    icon="wrench"
                    disabled={!(data.wires.shock && data.shock === 0)}
                    content="Restore"
                    onClick={() => act('shock-restore')}
                  />
                  <Button
                    icon="bolt"
                    disabled={!data.wires.shock}
                    content="Temporary"
                    onClick={() => act('shock-temp')}
                  />
                  <Button
                    icon="bolt"
                    disabled={!data.wires.shock}
                    content="Permanent"
                    onClick={() => act('shock-perm')}
                  />
                </>
              }
            >
              {data.shock === 2 ? 'Safe' : 'Electrified'}{' '}
              {(!data.wires.shock && '[Wires have been cut!]') ||
                (data.shock_timeleft > 0 && `[${data.shock_timeleft}s]`) ||
                (data.shock_timeleft === -1 && '[Permanent]')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Access and Door Control">
          <LabeledList>
            <LabeledList.Item
              label="ID Scan"
              color="bad"
              buttons={
                <Button
                  icon={data.id_scanner ? 'power-off' : 'times'}
                  content={data.id_scanner ? 'Enabled' : 'Disabled'}
                  selected={data.id_scanner}
                  disabled={!data.wires.id_scanner}
                  onClick={() => act('idscan-toggle')}
                />
              }
            >
              {!data.wires.id_scanner && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Emergency Access"
              buttons={
                <Button
                  icon={data.emergency ? 'power-off' : 'times'}
                  content={data.emergency ? 'Enabled' : 'Disabled'}
                  selected={data.emergency}
                  onClick={() => act('emergency-toggle')}
                />
              }
            />
            <LabeledList.Divider />
            <LabeledList.Item
              label="Door Bolts"
              color="bad"
              buttons={
                <Button
                  icon={data.locked ? 'lock' : 'unlock'}
                  content={data.locked ? 'Lowered' : 'Raised'}
                  selected={data.locked}
                  disabled={!data.wires.bolts}
                  onClick={() => act('bolt-toggle')}
                />
              }
            >
              {!data.wires.bolts && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Door Feedback"
              color="bad"
              buttons={
                <Button
                  icon={data.feedback ? 'power-off' : 'times'}
                  content={data.feedback ? 'Enabled' : 'Disabled'}
                  selected={data.feedback}
                  disabled={!data.wires.feedback}
                  onClick={() => act('light-toggle')}
                />
              }
            >
              {!data.wires.feedback && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Door Force Sensors"
              color="bad"
              buttons={
                <Button
                  icon={data.safe ? 'power-off' : 'times'}
                  content={data.safe ? 'Enabled' : 'Disabled'}
                  selected={data.safe}
                  disabled={!data.wires.safe}
                  onClick={() => act('safe-toggle')}
                />
              }
            >
              {!data.wires.safe && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Door Timing Safety"
              color="bad"
              buttons={
                <Button
                  icon={data.speed ? 'power-off' : 'times'}
                  content={data.speed ? 'Enabled' : 'Disabled'}
                  selected={data.speed}
                  disabled={!data.wires.timing}
                  onClick={() => act('speed-toggle')}
                />
              }
            >
              {!data.wires.timing && '[Wires have been cut!]'}
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item
              label="Door Control"
              color="bad"
              buttons={
                <Button
                  icon={data.opened ? 'sign-out-alt' : 'sign-in-alt'}
                  content={data.opened ? 'Open' : 'Closed'}
                  selected={data.opened}
                  disabled={data.locked || data.welded}
                  onClick={() => act('open-close')}
                />
              }
            >
              {!!(data.locked || data.welded) && (
                <span>
                  [Door is {data.locked ? 'bolted' : ''}
                  {data.locked && data.welded ? ' and ' : ''}
                  {data.welded ? 'welded' : ''}!]
                </span>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
