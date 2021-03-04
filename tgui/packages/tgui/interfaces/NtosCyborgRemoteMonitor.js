import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosCyborgRemoteMonitor = (props, context) => {
  return (
    <NtosWindow
      width={600}
      height={800}>
      <NtosWindow.Content scrollable>
        <NtosCyborgRemoteMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCyborgRemoteMonitorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    card,
    cyborgs = [],
  } = data;

  if (!cyborgs.length) {
    return (
      <NoticeBox>
        No cyborg units detected.
      </NoticeBox>
    );
  }

  return (
    <>
      {!card && (
        <NoticeBox>
          Certain features require an ID card login.
        </NoticeBox>
      )}
      {cyborgs.map(cyborg => {
        return (
          <Section
            key={cyborg.ref}
            title={cyborg.name}
            buttons={(
              <Button
                icon="terminal"
                content="Send Message"
                color="blue"
                disabled={!card}
                onClick={() => act('messagebot', {
                  ref: cyborg.ref,
                })} />
            )}>
            <LabeledList>
              <LabeledList.Item label="Status">
                <Box color={cyborg.status
                  ? 'bad'
                  : cyborg.locked_down
                    ? 'average'
                    : 'good'}>
                  {cyborg.status
                    ? "Not Responding"
                    : cyborg.locked_down
                      ? "Locked Down"
                      : cyborg.shell_discon
                        ? "Nominal/Disconnected"
                        : "Nominal"}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Charge">
                <Box color={cyborg.charge <= 30
                  ? 'bad'
                  : cyborg.charge <= 70
                    ? 'average'
                    : 'good'}>
                  {typeof cyborg.charge === 'number'
                    ? cyborg.charge + "%"
                    : "Not Found"}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Model">
                {cyborg.module}
              </LabeledList.Item>
              <LabeledList.Item label="Upgrades">
                {cyborg.upgrades}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        );
      })}
    </>
  );
};
