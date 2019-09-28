import { act } from 'byond';
import { Fragment } from 'inferno';
import { decodeHtmlEntities } from 'string-tools';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { Flex } from '../components/Flex';
import { createLogger } from '../logging';
import { fixed } from '../math';

export const AIAirlock = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
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
      localStatusText: 'Optimal'
    },
  };
  function colorPrefix(color) {
    return 'color-' + color
  }
  const statusMain = dangerMap[data.power.main] || dangerMap[0];
  const statusBackup = dangerMap[data.power.backup] || dangerMap[0];
  const statusElectrify = dangerMap[data.shock] || dangerMap[0];
  return (
    <Fragment>
      <Section title="Power Status">
        <LabeledList>
          <LabeledList.Item
            label="Main"
            color={statusMain.color}
            buttons={(
              <Fragment align="right">
                <Button
                  icon="lightbulb-o"
                  disabled={!data.power.main}
                  content="Disrupt"
                  onClick={() => act(ref, 'disrupt-main')}
                  />
              </Fragment>
            )}>
              {data.power.main ? 'Online' : 'Offline'} {(!data.wires.main_1 || !data.wires.main_2) ? (
                <span> [Wires have been cut!] </span>
              ) : (
                <span>{data.power.main_timeleft > 0 && (<span> [{data.power.main_timeleft}s] </span>)}</span>
              )}
          </LabeledList.Item>
          <LabeledList.Item
            label="Backup"
            color={statusBackup.color}
            buttons={(
              <Fragment>
                <Button
                  icon="lightbulb-o"
                  disabled={!data.power.backup}
                  content="Disrupt"
                  onClick={() => act(ref, 'disrupt-backup')}
                />
              </Fragment>
            )}>
            {data.power.backup ? 'Online' : 'Offline'} {(!data.wires.backup_1 || !data.wires.backup_2) ? (
              <span> [Wires have been cut!] </span>
            ) : (
              <span>{data.power.backup_timeleft > 0 && (<span> [{data.power.backup_timeleft}s] </span>)}</span>
            )}
          </LabeledList.Item>
          <LabeledList.Item
            label="Electrify"
            color={statusElectrify.color}
            buttons={(
              <Fragment>
                <Button
                  icon="wrench"
                  disabled={!(data.wires.shock && data.shock == 0)}
                  content="Restore"
                  onClick={() => act(ref, 'shock-restore')}
                />
                <Button
                  icon="bolt"
                  disabled={!data.wires.shock}
                  content="Temporary"
                  onClick={() => act(ref, 'shock-temp')}
                />
                <Button
                  icon="bolt"
                  disabled={!data.wires.shock}
                  content="Permanent"
                  onClick={() => act(ref, 'shock-perm')}
                />
              </Fragment>
          )}>
            {data.shock == 2 ? 'Safe' : 'Electrified'} {!data.wires.shock ? (
              <span> [Wires have been cut!] </span>
            ) : (
              <span>
                {data.shock_timeleft > 0 && (<span> [{data.shock_timeleft}s] </span>)}
                {data.shock_timeleft == -1 && (<span> [Permanent] </span>)}
              </span>
            )}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Access and Door Control">
        <LabeledList>
          <LabeledList.Item
            label="ID Scan"
            color="bad"
            buttons={(
              <Fragment>
                <Button
                  icon={data.id_scanner ? "power-off" : "close"}
                  content={data.id_scanner ? "Enabled" : "Disabled"}
                  selected={data.id_scanner}
                  disabled={!data.wires.id_scanner}
                  onClick={() => act(ref, 'idscan-toggle')}
                />
              </Fragment>
          )}>
            {!data.wires.id_scanner && (<span> [Wires have been cut!] </span>)}
          </LabeledList.Item>
          <LabeledList.Item
            label="Emergency Access"
            buttons={(
              <Button
                icon={data.emergency ? "power-off" : "close"}
                content={data.emergency ? "Enabled" : "Disabled"}
                selected={data.emergency}
                onClick={() => act(ref, 'emergency-toggle')}
              />
           )}/>
          <LabeledList.Divider size={1}/>
          <LabeledList.Item
            label="Door Bolts"
            color="bad"
            buttons={(
              <Fragment>
                <Button
                  icon={data.locked ? "lock" : "unlock"}
                  content={data.locked ? "Lowered" : "Raised"}
                  selected={data.locked}
                  disabled={!data.wires.bolts}
                  onClick={() => act(ref, 'bolt-toggle')}
                />
              </Fragment>
          )}>
            {!data.wires.bolts && (<span> [Wires have been cut!] </span>)}
          </LabeledList.Item>
          <LabeledList.Item
            label="Door Bolt Lights"
            color="bad"
            buttons={(
              <Fragment>
                <Button
                  icon={data.lights ? "power-off" : "close"}
                  content={data.lights ? "Enabled" : "Disabled"}
                  selected={data.lights}
                  disabled={!data.wires.lights}
                  onClick={() => act(ref, 'light-toggle')}
                />
              </Fragment>
          )}>
            {!data.wires.lights && (<span> [Wires have been cut!] </span>)}
          </LabeledList.Item>
          <LabeledList.Item
            label="Door Force Sensors"
            color="bad"
            buttons={(
              <Fragment>
                <Button
                  icon={data.safe ? "power-off" : "close"}
                  content={data.safe ? "Enabled" : "Disabled"}
                  selected={data.safe}
                  disabled={!data.wires.safe}
                  onClick={() => act(ref, 'safe-toggle')}
                />
              </Fragment>
          )}>
            {!data.wires.safe && (<span> [Wires have been cut!] </span>)}
          </LabeledList.Item>
          <LabeledList.Item
            label="Door Timing Safety"
            color="bad"
            buttons={(
              <Fragment>
                <Button
                  icon={data.speed ? "power-off" : "close"}
                  content={data.speed ? "Enabled" : "Disabled"}
                  selected={data.speed}
                  disabled={!data.wires.timing}
                  onClick={() => act(ref, 'speed-toggle')}
                />
              </Fragment>
          )}>
            {!data.wires.timing && (<span> [Wires have been cut!] </span>)}
          </LabeledList.Item>
          <LabeledList.Divider size={1}/>
          <LabeledList.Item
            label="Door Control"
            color="bad"
            buttons={(
              <Fragment>
                <Button
                  icon={data.opened ? "sign-out" : "sign-in"}
                  content={data.opened ? "Open" : "Closed"}
                  selected={data.opened}
                  disabled={(data.locked || data.welded)}
                  onClick={() => act(ref, 'open-close')}
                />
              </Fragment>
          )}>
            {(data.locked || data.welded) ? (
              <span> [Door is {data.locked ? "bolted" : ""}{(data.locked && data.welded) ? " and " : ""}{data.welded ? "welded" : ""}!] </span>
            ) : ""}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  )
};
