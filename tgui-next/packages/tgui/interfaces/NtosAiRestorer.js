import { Section, Box, Button, NoticeBox, ProgressBar, LabeledList } from "../components";
import { useBackend } from "../backend";
import { Fragment } from "inferno";

export const NtosAiRestorer = props => {
  const { act, data } = useBackend(props);

  const {
    nocard,
    error,
    name,
    ai_laws,
    isDead,
    restoring,
  } = data;

  return (
    <Fragment>
      {error && (
        <NoticeBox>
          {error}
        </NoticeBox>
      )}
      <Section>
        <Button
          fluid
          icon="eject"
          content={name || "----------"}
          disabled={!name}
          onClick={() => act('PRG_eject')}
        />
        {!nocard && (
          <Section
            title="System Status"
            level={2}
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
                  value={100}
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
            <Section title="laws" level={3}>
              {ai_laws.map(law => (
                <Box key={law} className="candystripe">
                  {law}
                </Box>
              ))}
            </Section>
          </Section>
        )}
      </Section>
    </Fragment>
  );
};
