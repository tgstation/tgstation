import {
  Box,
  NumberInput,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type RulesetReport = {
  name: string;
  weight: number;
  max_candidates: number;
  min_candidates: number;
  comment: string | null;
};

type Data = {
  tier: number;
  num_players: number;
  ruleset_report: RulesetReport[];
};

export const DynamicTester = () => {
  const { data, act } = useBackend<Data>();
  const { tier, num_players, ruleset_report } = data;

  const total_weight = ruleset_report.reduce(
    (acc, report) => acc + report.weight,
    0,
  );
  const rulesets_with_weight_percentages = ruleset_report.map((report) => {
    const percentage = Math.round((report.weight / total_weight) * 100);
    return {
      ...report,
      percentage,
    };
  });

  return (
    <Window width={500} height={400}>
      <Window.Content>
        <Section scrollable height="100%" width="100%">
          <Stack vertical fill>
            <Stack.Item>
              Tier:{' '}
              <NumberInput
                value={tier}
                onChange={(e) => act('set_tier', { tier: e })}
              />
            </Stack.Item>
            <Stack.Item>
              Number of players:{' '}
              <NumberInput
                value={num_players}
                onChange={(e) => act('set_num_players', { num_players: e })}
              />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Table>
                <Table.Row header>
                  <Table.Cell>Ruleset</Table.Cell>
                  <Table.Cell>Weight</Table.Cell>
                  <Table.Cell>Odds</Table.Cell>
                  <Table.Cell>Max Antags</Table.Cell>
                  <Table.Cell>Min Antags</Table.Cell>
                </Table.Row>
                {rulesets_with_weight_percentages.map((report) => (
                  <Table.Row key={report.name}>
                    {report.comment ? (
                      <Table.Cell>
                        <Tooltip content={report.comment} position="right">
                          <Box
                            inline
                            style={{
                              borderBottom:
                                '2px dotted rgba(255, 255, 255, 0.8)',
                            }}
                          >
                            {report.name}
                          </Box>
                        </Tooltip>
                      </Table.Cell>
                    ) : (
                      <Table.Cell>{report.name}</Table.Cell>
                    )}
                    <Table.Cell>{report.weight}</Table.Cell>
                    <Table.Cell>{report.percentage}%</Table.Cell>
                    <Table.Cell>{report.max_candidates}</Table.Cell>
                    <Table.Cell>{report.min_candidates}</Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
