import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Section, Tabs, LabeledList } from '../components';

export const CrewControlConsole = props => {
  const { state } = props;
  const { act, data } = useBackend(props);
  const {
    crew = [],
  } = data;

  return (
    <Tabs>
      <Tabs.Tab
        key="crew"
        label={"Crew " + `(${crew.length})`}
        icon="list"
        lineHeight="23px">
        {() => (
          <Crew state={state} crew={crew} />
        )}
      </Tabs.Tab>
    </Tabs>
  );
};

const Crew = props => {
  const { state, crew} = props;
  const { act, data } = useBackend(props);

  if (!crew.length) {
    return (
      <Section>
        <NoticeBox textAlign="center">
          No crew members detected within access parameters
        </NoticeBox>
      </Section>
    );
  }

  return crew.map(crew => {
    return (
      <Section
        key={crew.ref}
        title={crew.name}
        buttons={(
          <Fragment>
            <Button.Confirm
              icon={crew.locked_down ? 'unlock' : 'lock'}
              color={crew.locked_down ? 'good' : 'default'}
              content={crew.locked_down ? "Release" : "Lockdown"}
              onClick={() => act('stopcrew', {
                ref: crew.ref,
              })} />
            <Button.Confirm
              icon="bomb"
              content="Detonate"
              color="bad"
              onClick={() => act('killcrew', {
                ref: crew.ref,
              })} />
          </Fragment>
        )}>
        <LabeledList>
          <LabeledList.Item label="Status">
            <Box color={crew.status
              ? 'bad'
              : crew.locked_down
                ? 'average'
                : 'good'}>
              {crew.status
                ? "Unresponsive"
                : crew.locked_down
                  ? "Locked Down"
                  : "Alive"}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};