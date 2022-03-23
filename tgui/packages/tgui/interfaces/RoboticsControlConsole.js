import { useBackend, useSharedState } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const RoboticsControlConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const {
    can_hack,
    can_detonate,
    cyborgs = [],
    drones = [],
  } = data;
  return (
    <Window
      width={500}
      height={460}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Cyborgs ({cyborgs.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Drones ({drones.length})
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <Cyborgs
            cyborgs={cyborgs}
            can_hack={can_hack}
            can_detonate={can_detonate} />
        )}
        {tab === 2 && (
          <Drones drones={drones} />
        )}
      </Window.Content>
    </Window>
  );
};

const Cyborgs = (props, context) => {
  const { cyborgs, can_hack, can_detonate } = props;
  const { act, data } = useBackend(context);
  if (!cyborgs.length) {
    return (
      <NoticeBox>
        No cyborg units detected within access parameters
      </NoticeBox>
    );
  }
  return cyborgs.map(cyborg => {
    return (
      <Section
        key={cyborg.ref}
        title={cyborg.name}
        buttons={(
          <>
            {!!can_hack && !cyborg.emagged && (
              <Button
                icon="terminal"
                content="Hack"
                color="bad"
                onClick={() => act('magbot', {
                  ref: cyborg.ref,
                })} />
            )}
            <Button.Confirm
              icon={cyborg.locked_down ? 'unlock' : 'lock'}
              color={cyborg.locked_down ? 'good' : 'default'}
              content={cyborg.locked_down ? "Release" : "Lockdown"}
              onClick={() => act('stopbot', {
                ref: cyborg.ref,
              })} />
            {!!can_detonate && (
              <Button.Confirm
                icon="bomb"
                content="Detonate"
                color="bad"
                onClick={() => act('killbot', {
                  ref: cyborg.ref,
                })} />
            )}
          </>
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
          <LabeledList.Item label="Master AI">
            <Box color={cyborg.synchronization ? 'default' : 'average'}>
              {cyborg.synchronization || "None"}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};

const Drones = (props, context) => {
  const { drones } = props;
  const { act } = useBackend(context);

  if (!drones.length) {
    return (
      <NoticeBox>
        No drone units detected within access parameters
      </NoticeBox>
    );
  }

  return drones.map(drone => {
    return (
      <Section
        key={drone.ref}
        title={drone.name}
        buttons={(
          <Button.Confirm
            icon="bomb"
            content="Detonate"
            color="bad"
            onClick={() => act('killdrone', {
              ref: drone.ref,
            })} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Status">
            <Box color={drone.status
              ? 'bad'
              : 'good'}>
              {drone.status
                ? "Not Responding"
                : 'Nominal'}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};
