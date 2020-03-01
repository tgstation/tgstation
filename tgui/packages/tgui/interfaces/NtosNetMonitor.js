import { Section, Box, Button, NoticeBox, ProgressBar, LabeledList, NumberInput } from "../components";
import { useBackend } from "../backend";
import { Fragment } from "inferno";

export const NtosNetMonitor = props => {
  const { act, data } = useBackend(props);

  const {
    ntnetrelays,
    ntnetstatus,
    config_softwaredownload,
    config_peertopeer,
    config_communication,
    config_systemcontrol,
    idsalarm,
    idsstatus,
    ntnetmaxlogs,
    maxlogs,
    minlogs,
    ntnetlogs = [],
  } = data;

  return (
    <Fragment>
      <NoticeBox>
        WARNING: Disabling wireless transmitters when using
        a wireless device may prevent you from reenabling them!
      </NoticeBox>
      <Section
        title="Wireless Connectivity"
        buttons={(
          <Button.Confirm
            icon={ntnetstatus ? 'power-off' : 'times'}
            content={ntnetstatus ? 'ENABLED' : 'DISABLED'}
            selected={ntnetstatus}
            onClick={() => act('toggleWireless')} />
        )}>
        {ntnetrelays ? (
          <LabeledList>
            <LabeledList.Item label="Active NTNet Relays">
              {ntnetrelays}
            </LabeledList.Item>
          </LabeledList>
        ) : "No Relays Connected"}
      </Section>
      <Section title="Firewall Configuration">
        <LabeledList>
          <LabeledList.Item
            label="Software Downloads"
            buttons={(
              <Button
                icon={config_softwaredownload ? 'power-off' : 'times'}
                content={config_softwaredownload ? 'ENABLED' : 'DISABLED'}
                selected={config_softwaredownload}
                onClick={() => act('toggle_function', { id: "1" })} />
            )} />
          <LabeledList.Item
            label="Peer to Peer Traffic"
            buttons={(
              <Button
                icon={config_peertopeer ? 'power-off' : 'times'}
                content={config_peertopeer ? 'ENABLED' : 'DISABLED'}
                selected={config_peertopeer}
                onClick={() => act('toggle_function', { id: "2" })} />
            )} />
          <LabeledList.Item
            label="Communication Systems"
            buttons={(
              <Button
                icon={config_communication ? 'power-off' : 'times'}
                content={config_communication ? 'ENABLED' : 'DISABLED'}
                selected={config_communication}
                onClick={() => act('toggle_function', { id: "3" })} />
            )} />
          <LabeledList.Item
            label="Remote System Control"
            buttons={(
              <Button
                icon={config_systemcontrol ? 'power-off' : 'times'}
                content={config_systemcontrol ? 'ENABLED' : 'DISABLED'}
                selected={config_systemcontrol}
                onClick={() => act('toggle_function', { id: "4" })} />
            )} />
        </LabeledList>
      </Section>
      <Section title="Security Systems">
        {!!idsalarm && (
          <Fragment>
            <NoticeBox>
              NETWORK INCURSION DETECTED
            </NoticeBox>
            <Box italics>
              Abnormal activity has been detected in the network.
              Check system logs for more information
            </Box>
          </Fragment>
        )}
        <LabeledList>
          <LabeledList.Item
            label="IDS Status"
            buttons={(
              <Fragment>
                <Button
                  icon={idsstatus ? 'power-off' : 'times'}
                  content={idsstatus ? 'ENABLED' : 'DISABLED'}
                  selected={idsstatus}
                  onClick={() => act('toggleIDS')} />
                <Button
                  icon="sync"
                  content="Reset"
                  color="bad"
                  onClick={() => act('resetIDS')} />
              </Fragment>
            )} />
          <LabeledList.Item
            label="Max Log Count"
            buttons={(
              <NumberInput
                value={ntnetmaxlogs}
                minValue={minlogs}
                maxValue={maxlogs}
                width="39px"
                onChange={(e, value) => act('updatemaxlogs', {
                  new_number: value,
                })}
              />
            )} />
        </LabeledList>
        <Section
          title="System Log"
          level={2}
          buttons={(
            <Button.Confirm
              icon="trash"
              content="Clear Logs"
              onClick={() => act('purgelogs')} />
          )}>
          {ntnetlogs.map(log => (
            <Box key={log.entry} className="candystripe">
              {log.entry}
            </Box>
          ))}
        </Section>
      </Section>
    </Fragment>
  );
};
