import { sortBy } from "common/collections";
import { useBackend } from "../backend";
import { Box, Flex, ProgressBar, Section, Table } from "../components";
import { Window } from "../layouts";

const JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED = 1;
const JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS = 2;

const sortByPlaytime = sortBy(([_, playtime]) => -playtime);

const PlaytimeSection = props => {
  const { playtimes } = props;
  const sortedPlaytimes = sortByPlaytime(Object.entries(playtimes));
  const mostPlayed = sortedPlaytimes[0][1];

  return (
    <Table>
      {sortedPlaytimes.map(([jobName, playtime]) => {
        const ratio = playtime / mostPlayed;

        return (
          <Table.Row key={jobName}>
            <Table.Cell collapsing p={0.5} style={{
              "vertical-align": "middle",
            }}>
              <Box align="right">{jobName}</Box>
            </Table.Cell>

            <Table.Cell>
              <ProgressBar
                maxValue={mostPlayed}
                value={playtime}>
                <Flex>
                  <Flex.Item width={`${ratio * 100}%`} />

                  <Flex.Item>
                    {(playtime / 60).toLocaleString(undefined, {
                      "minimumFractionDigits": 1,
                      "maximumFractionDigits": 1,
                    })}h
                  </Flex.Item>
                </Flex>
              </ProgressBar>
            </Table.Cell>
          </Table.Row>
        );
      })}
    </Table>
  );
};

export const TrackedPlaytime = (props, context) => {
  const { data } = useBackend(context);
  const {
    failReason,
    jobPlaytimes,
    specialPlaytimes,

    livingTime,
    ghostTime,
  } = data;

  return (
    <Window
      title="Tracked Playtime"
      width={550}
      height={650}
      resizable>
      <Window.Content scrollable>
        {failReason && (
          failReason === JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED
            && <Box>This server has disabled tracking.</Box>
          || failReason === JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS
            && <Box>You have no records.</Box>
        ) || (
          <Box>
            <Section title="Total">
              <PlaytimeSection
                playtimes={{
                  "Ghost": ghostTime,
                  "Living": livingTime,
                }}
              />
            </Section>

            <Section title="Jobs">
              <PlaytimeSection
                playtimes={jobPlaytimes}
              />
            </Section>

            <Section title="Special">
              <PlaytimeSection
                playtimes={specialPlaytimes}
              />
            </Section>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
