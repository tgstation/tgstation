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
      localStatusText: 'Optimal',
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
        <Flex align="center">
          <Flex.Item>
            <span>Main: </span>
            <span className={colorPrefix(statusMain.color)}>
              {data.power.main ? 'Online' : 'Offline'} {(!data.wires.main_1 || !data.wires.main_2) ? (
                <span> [Wires have been cut!] </span>
              ) : (
                <span>{data.power.main_timeleft > 0 && (<span> [{data.power.main_timeleft} seconds left] </span>)}</span>
              )}
            </span>
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon="lightbulb-o"
              disabled={!data.power.main}
              content="Disrupt"
              onClick={() => act(ref, 'disrupt-main')}
            />
          </Flex.Item>
        </Flex>
        <Flex align="center">
          <Flex.Item>
            <span>Backup: </span>
            <span className={colorPrefix(statusBackup.color)}>
              {data.power.backup ? 'Online' : 'Offline'} {(!data.wires.backup_1 || !data.wires.backup_2) ? (
                <span> [Wires have been cut!] </span>
              ) : (
                <span>{data.power.backup_timeleft > 0 && (<span> [{data.power.backup_timeleft} seconds left] </span>)}</span>
              )}
            </span>
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon="lightbulb-o"
              disabled={!data.power.backup}
              content="Disrupt"
              onClick={() => act(ref, 'disrupt-backup')}
            />
          </Flex.Item>
        </Flex>
        <Flex align="center">
          <Flex.Item>
            <span>Electrify: </span>
            <span className={colorPrefix(statusElectrify.color)}>
              {data.shock == 2 ? 'Safe' : 'Electrified'} {!data.wires.shock ? (
                <span> [Wires have been cut!] </span>
              ) : (
                <span>
                  {data.shock_timeleft > 0 && (<span> [{data.shock_timeleft} seconds left] </span>)}
                  {data.shock_timeleft == -1 && (<span> [Permanent] </span>)}
                </span>
              )}
            </span>
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon="wrench"
              disabled={!(data.wires.shock && data.shock == 0)}
              content="Restore"
              onClick={() => act(ref, 'shock-restore')}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="bolt"
              disabled={!data.wires.shock}
              content="Temporary"
              onClick={() => act(ref, 'shock-temp')}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="bolt"
              disabled={!data.wires.shock}
              content="Permanent"
              onClick={() => act(ref, 'shock-perm')}
            />
          </Flex.Item>
        </Flex>
      </Section>
      <Section title="Access and Door Control">
        <Flex align="center">
          <Flex.Item>
            <span>ID Scan:</span>
            {!data.wires.id_scanner && (<span className={colorPrefix("bad")}> [Wires have been cut!] </span>)}
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon={data.id_scanner ? "power-off" : "close"}
              content={data.id_scanner ? "Enabled" : "Disabled"}
              selected={data.id_scanner}
              disabled={!data.wires.id_scanner}
              onClick={() => act(ref, 'idscan-toggle')}
            />
          </Flex.Item>
        </Flex>
        <Flex align="center">
          <Flex.Item>
            <span>Emergency Access:</span>
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon={data.emergency ? "power-off" : "close"}
              content={data.emergency ? "Enabled" : "Disabled"}
              selected={data.emergency}
              onClick={() => act(ref, 'emergency-toggle')}
            />
          </Flex.Item>
        </Flex>
        <Box mt={2} />
        <Flex align="center">
          <Flex.Item>
            <span>Door Bolts:</span>
            {!data.wires.bolts && (<span className={colorPrefix("bad")}> [Wires have been cut!] </span>)}
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon={data.locked ? "lock" : "unlock"}
              content={data.locked ? "Lowered" : "Raised"}
              selected={data.locked}
              disabled={!data.wires.bolts}
              onClick={() => act(ref, 'bolt-toggle')}
            />
          </Flex.Item>
        </Flex>
        <Flex align="center">
          <Flex.Item>
            <span>Door Bolt Lights:</span>
            {!data.wires.lights && (<span className={colorPrefix("bad")}> [Wires have been cut!] </span>)}
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon={data.lights ? "power-off" : "close"}
              content={data.lights ? "Enabled" : "Disabled"}
              selected={data.lights}
              disabled={!data.wires.lights}
              onClick={() => act(ref, 'light-toggle')}
            />
          </Flex.Item>
        </Flex>
        <Flex align="center">
          <Flex.Item>
            <span>Door Force Sensors:</span>
            {!data.wires.safe && (<span className={colorPrefix("bad")}> [Wires have been cut!] </span>)}
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon={data.safe ? "power-off" : "close"}
              content={data.safe ? "Enabled" : "Disabled"}
              selected={data.safe}
              disabled={!data.wires.safe}
              onClick={() => act(ref, 'safe-toggle')}
            />
          </Flex.Item>
        </Flex>
        <Flex align="center">
          <Flex.Item>
            <span>Door Timing Safety:</span>
            {!data.wires.timing && (<span className={colorPrefix("bad")}> [Wires have been cut!] </span>)}
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon={data.speed ? "power-off" : "close"}
              content={data.speed ? "Enabled" : "Disabled"}
              selected={data.speed}
              disabled={!data.wires.timing}
              onClick={() => act(ref, 'speed-toggle')}
            />
          </Flex.Item>
        </Flex>
        <Box mt={2} />
        <Flex align="center">
          <Flex.Item>
            <span>Door Control:</span>
            {(data.locked || data.welded) ? (
              <span className={colorPrefix("bad")}> [Door is {data.locked ? "bolted" : ""}{(data.locked && data.welded) ? " and " : ""}{data.welded ? "welded" : ""}!] </span>
             ) : ""}
          </Flex.Item>
          <Flex.Item grow={1}/>
          <Flex.Item>
            <Button
              icon={data.opened ? "sign-out" : "sign-in"}
              content={data.opened ? "Open" : "Closed"}
              selected={data.opened}
              disabled={(data.locked || data.welded)}
              onClick={() => act(ref, 'open-close')}
            />
          </Flex.Item>
        </Flex>
      </Section>
    </Fragment>
  )
};
