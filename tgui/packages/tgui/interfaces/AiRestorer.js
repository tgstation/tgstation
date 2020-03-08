import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Section, Box, Button, NoticeBox, ProgressBar, LabeledList } from "../components";

export const AiRestorer = props => {
  const { act, data } = useBackend(props);
  const {
    AI_present,
    error,
    name,
    laws,
    isDead,
    restoring,
    health,
    ejectable,
  } = data;

  return (
    <Fragment>
      {error && (
        <NoticeBox textAlign="center">
          {error}
        </NoticeBox>
      )}
      {!!ejectable && (
        <Button
          fluid
          icon="eject"
          content={AI_present ? name : "----------"}
          disabled={!AI_present}
          onClick={() => act('PRG_eject')}
        />
      )}
      {!!AI_present && (
        <Section
          title={ejectable ? "System Status" : name}
          buttons={(
            <Box
              inline
              bold
              color={isDead ? 'bad' : 'good'}>
              {isDead ? "Nonfunctional" : "Functional"}
            </Box>
          )}>
          <LabeledList>
            <LabeledList.Item label="Integrity">
              <ProgressBar
                value={health}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [70, Infinity],
                  average: [50, 70],
                  bad: [-Infinity, 50],
                }} />
            </LabeledList.Item>
          </LabeledList>
          {!!restoring && (
            <Box
              bold
              textAlign="center"
              fontSize="20px"
              color="good"
              mt={1}>
              RECONSTRUCTION IN PROGRESS
            </Box>
          )}
          <Button
            fluid
            icon="plus"
            content="Begin Reconstruction"
            disabled={restoring}
            mt={1}
            onClick={() => act('PRG_beginReconstruction')}
          />
          <Section title="Laws" level={2}>
            {laws.map(law => (
              <Box key={law} className="candystripe">
                {law}
              </Box>
            ))}
          </Section>
        </Section>
      )}
    </Fragment>
  );
};
