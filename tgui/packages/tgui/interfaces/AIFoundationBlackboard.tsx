import { useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { Window } from '../layouts';
import {
  type ConfigPatchPayload,
  type CrewActionEntry,
  type CrewSummary,
  type GatewayStatus,
  type PolicySnapshot,
  type TimelineEntry,
  useAIFoundationStore,
} from '../stores/ai_foundation';

const BACKPRESSURE_LABELS: Record<number, string> = {
  0: 'None',
  1: 'Light',
  2: 'Heavy',
  3: 'Critical',
};

const DEFAULT_MULTIPLIERS: Record<string, number> = {
  'Routine Upkeep': 1.6,
  'Maintenance & Logistics': 1.35,
  'Medical Response': 0.9,
  'Security & Emergency': 0.8,
  'Social & Support': 1.1,
};

const DEFAULT_EMERGENCY: Record<string, number> = {
  blue: 0.85,
  red: 0.7,
  delta: 0.6,
};

const DEFAULT_SAFETY = {
  max_hazard_score: 0.65,
  max_chain_failures: 2,
};

const DEFAULT_RATE_LIMITS = {
  item_toggle_seconds: 5,
  aggressive_action_seconds: 8,
};

const DEFAULT_GATEWAY = {
  planner_url: 'http://127.0.0.1:15151/plan',
  parser_url: 'http://127.0.0.1:15152/parse',
  planner_timeout_ds: 50,
  parser_timeout_ds: 50,
  retry_ds: 20,
};

const DEFAULT_TELEMETRY_MINUTES = 30;

const PRESETS: Array<{
  id: string;
  label: string;
  multipliers: Record<string, number>;
  emergency: Record<string, number>;
}> = [
  {
    id: 'default',
    label: 'Default',
    multipliers: DEFAULT_MULTIPLIERS,
    emergency: DEFAULT_EMERGENCY,
  },
  {
    id: 'cautious',
    label: 'Cautious',
    multipliers: {
      'Routine Upkeep': 1.2,
      'Maintenance & Logistics': 1.05,
      'Medical Response': 0.8,
      'Security & Emergency': 0.7,
      'Social & Support': 0.9,
    },
    emergency: {
      blue: 0.75,
      red: 0.6,
      delta: 0.5,
    },
  },
  {
    id: 'assertive',
    label: 'Assertive',
    multipliers: {
      'Routine Upkeep': 2.1,
      'Maintenance & Logistics': 1.75,
      'Medical Response': 1.1,
      'Security & Emergency': 1.0,
      'Social & Support': 1.35,
    },
    emergency: {
      blue: 0.95,
      red: 0.8,
      delta: 0.7,
    },
  },
];

const toBoolean = (value?: BooleanLike) =>
  value === true || value === 1 || value === '1' || value === 'true';

const toFixed = (value: number | undefined, digits = 2) =>
  Number.isFinite(value) ? value!.toFixed(digits) : '—';

const formatTimestamp = (value?: string) => value || '—';

const formatSecondsAgo = (deltaSeconds: number | undefined) => {
  if (deltaSeconds === undefined || !Number.isFinite(deltaSeconds)) {
    return 'Unknown';
  }
  if (deltaSeconds < 1) {
    return '<1s';
  }
  if (deltaSeconds < 60) {
    return `${deltaSeconds.toFixed(1)}s`;
  }
  const minutes = Math.floor(deltaSeconds / 60);
  const seconds = Math.floor(deltaSeconds % 60);
  return `${minutes}m ${seconds}s`;
};

const formatResult = (result?: string) => {
  if (!result) {
    return '—';
  }
  return result.replace('_', ' ').toUpperCase();
};

export const AIFoundationBlackboard = () => {
  const {
    crew,
    rawCrew,
    search,
    setSearch,
    selectedProfile,
    setSelectedProfile,
    selectedSummary,
    selectedTimeline,
    timelineLoading,
    autoRefresh,
    setAutoRefresh,
    refresh,
    loadTimeline,
    clearTimeline,
    patchConfig,
    gatewayStatus,
    policy,
    lastPatchResponse,
    blackboard,
    lastRefreshDs,
    nowDs,
    refreshCooldownDs,
  } = useAIFoundationStore();

  const lastRefreshSeconds = useMemo(() => {
    if (!lastRefreshDs || !nowDs) {
      return undefined;
    }
    return Math.max(0, (nowDs - lastRefreshDs) / 10);
  }, [lastRefreshDs, nowDs]);

  const selectedTimelineEntries: TimelineEntry[] = useMemo(() => {
    const records = selectedTimeline?.entries;
    if (!records?.length) {
      return [];
    }
    return records.slice().sort((a, b) => a.sequence_id - b.sequence_id);
  }, [selectedTimeline]);

  const actionWeightEntries = Object.entries(
    selectedSummary?.action_category_weights || {},
  );
  const recentActions: CrewActionEntry[] = selectedSummary?.recent_actions || [];

  const plannerEnabled = toBoolean(gatewayStatus?.feature_enabled);
  const backpressureLabel =
    BACKPRESSURE_LABELS[gatewayStatus?.backpressure_state ?? 0] || 'Unknown';
  const tickUsage = gatewayStatus?.tick_usage ?? 0;

  return (
    <Window title="AI Foundation Blackboard" width={960} height={600} resizable>
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item grow basis="35%">
            <Stack fill vertical>
              <Stack.Item>
                <Section title="Controls">
                  <Stack vertical gap={1}>
                    <Stack.Item>
                      <Input
                        autoFocus
                        icon="search"
                        placeholder="Filter by profile, job, or status"
                        value={search}
                        onChange={(value) => setSearch(value)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Stack align="center" justify="space-between">
                        <Stack.Item grow>
                          <Button.Checkbox
                            checked={autoRefresh}
                            icon="sync"
                            tooltip={`Auto refresh every ${(refreshCooldownDs / 10).toFixed(1)}s`}
                            onClick={() => setAutoRefresh(!autoRefresh)}
                          >
                            Auto Refresh
                          </Button.Checkbox>
                        </Stack.Item>
                        <Stack.Item>
                          <Button icon="rotate" onClick={refresh}>
                            Refresh Now
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Box color="label">
                        Last update: {formatSecondsAgo(lastRefreshSeconds)} ago
                      </Box>
                      <Box color="label">
                        Snapshot: {blackboard?.generated_at || '—'}
                      </Box>
                      <Box color="label">
                        Controllers online: {rawCrew.length}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section fill title="Active Crew">
                  {crew.length === 0 ? (
                    <NoticeBox info>No AI crew are currently active.</NoticeBox>
                  ) : (
                    <Table height="100%" scrollable>
                      <Table.Row header>
                        <Table.Cell collapsing>ID</Table.Cell>
                        <Table.Cell>Job</Table.Cell>
                        <Table.Cell collapsing>Status</Table.Cell>
                      </Table.Row>
                      {crew.map((summary: CrewSummary) => {
                        const isSelected = summary.profile_id === selectedProfile;
                        return (
                          <Table.Row
                            key={summary.profile_id}
                            style={{
                              cursor: 'pointer',
                              backgroundColor: isSelected
                                ? 'rgba(64, 160, 255, 0.25)'
                                : undefined,
                            }}
                            onClick={() => setSelectedProfile(summary.profile_id)}
                          >
                            <Table.Cell collapsing>{summary.profile_id}</Table.Cell>
                            <Table.Cell>
                              <Box bold>{summary.job_id || 'Unassigned'}</Box>
                              <Box color="label" ellipsis>
                                {summary.current_objective || 'No objective'}
                              </Box>
                            </Table.Cell>
                            <Table.Cell collapsing>
                              <StatusBadge status={summary.status} />
                            </Table.Cell>
                          </Table.Row>
                        );
                      })}
                    </Table>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Divider />

          <Stack.Item grow>
            <Stack fill vertical>
              <Stack.Item>
                <Section
                  title={selectedSummary ? selectedSummary.profile_id : 'Crew Details'}
                  buttons={
                    selectedProfile && (
                      <Stack align="center" gap={1}>
                        <Stack.Item>
                          <Button
                            icon="arrows-rotate"
                            tooltip="Reload timeline"
                            onClick={() => loadTimeline(selectedProfile, true)}
                          >
                            Reload
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="trash"
                            tooltip="Clear cached timeline"
                            onClick={() => clearTimeline(selectedProfile)}
                          />
                        </Stack.Item>
                      </Stack>
                    )
                  }
                >
                  {!selectedSummary ? (
                    <NoticeBox info>Select an AI profile to inspect details.</NoticeBox>
                  ) : (
                    <Stack vertical gap={1}>
                      <Stack.Item>
                        <LabeledList>
                          <LabeledList.Item label="Job">
                            {selectedSummary.job_id || 'Unassigned'}
                          </LabeledList.Item>
                          <LabeledList.Item label="Status">
                            <StatusBadge status={selectedSummary.status} />
                          </LabeledList.Item>
                          <LabeledList.Item label="Current Objective">
                            {selectedSummary.current_objective || '—'}
                          </LabeledList.Item>
                          <LabeledList.Item label="Recent Action">
                            {recentActions.length ? (
                              <RecentAction action={recentActions[0]} />
                            ) : (
                              'No telemetry recorded'
                            )}
                          </LabeledList.Item>
                        </LabeledList>
                      </Stack.Item>
                      <Divider />
                      <Stack.Item>
                        <Section title="Action Weights">
                          {actionWeightEntries.length === 0 ? (
                            <NoticeBox info>
                              No action taxonomy weights available.
                            </NoticeBox>
                          ) : (
                            <Table>
                              <Table.Row header>
                                <Table.Cell>Category</Table.Cell>
                                <Table.Cell collapsing>Multiplier</Table.Cell>
                              </Table.Row>
                              {actionWeightEntries.map(([category, weight]) => (
                                <Table.Row key={category}>
                                  <Table.Cell>{category}</Table.Cell>
                                  <Table.Cell collapsing>{toFixed(weight, 2)}</Table.Cell>
                                </Table.Row>
                              ))}
                            </Table>
                          )}
                        </Section>
                      </Stack.Item>
                    </Stack>
                  )}
                </Section>
              </Stack.Item>

              <Stack.Item grow>
                <Section
                  fill
                  title="Decision Timeline"
                  buttons={
                    timelineLoading && (
                      <Box color="label" italic>
                        Loading…
                      </Box>
                    )
                  }
                >
                  {!selectedProfile ? (
                    <NoticeBox info>Select an AI profile to view planner telemetry.</NoticeBox>
                  ) : selectedTimeline?.error ? (
                    <NoticeBox danger>
                      Failed to load timeline: {selectedTimeline.error}
                    </NoticeBox>
                  ) : !selectedTimelineEntries.length ? (
                    <NoticeBox info>No timeline entries found for this profile.</NoticeBox>
                  ) : (
                    <Table height="100%" scrollable>
                      <Table.Row header>
                        <Table.Cell collapsing>#</Table.Cell>
                        <Table.Cell>Action</Table.Cell>
                        <Table.Cell collapsing>Bonus</Table.Cell>
                        <Table.Cell collapsing>Rollouts</Table.Cell>
                        <Table.Cell collapsing>Result</Table.Cell>
                        <Table.Cell collapsing>Timestamp</Table.Cell>
                        <Table.Cell>Notes</Table.Cell>
                      </Table.Row>
                      {selectedTimelineEntries.map((entry) => (
                        <Table.Row key={entry.sequence_id}>
                          <Table.Cell collapsing>{entry.sequence_id}</Table.Cell>
                          <Table.Cell>{entry.selected_action}</Table.Cell>
                          <Table.Cell collapsing>{toFixed(entry.exploration_bonus, 2)}</Table.Cell>
                          <Table.Cell collapsing>{entry.rollout_count}</Table.Cell>
                          <Table.Cell collapsing>
                            <StatusBadge status={entry.result} />
                          </Table.Cell>
                          <Table.Cell collapsing>
                            {formatTimestamp(entry.timestamp)}
                          </Table.Cell>
                          <Table.Cell>{entry.notes || '—'}</Table.Cell>
                        </Table.Row>
                      ))}
                    </Table>
                  )}
                </Section>
              </Stack.Item>

              <Stack.Item>
                <Section title="Planner & Gateway Health">
                  <LabeledList>
                    <LabeledList.Item label="Subsystem">
                      {plannerEnabled ? (
                        <Box color="good" bold>
                          Enabled
                        </Box>
                      ) : (
                        <Box color="bad" bold>
                          Disabled
                        </Box>
                      )}
                    </LabeledList.Item>
                    <LabeledList.Item label="Backpressure">
                      <Box>{backpressureLabel}</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Tick Usage">
                      <ProgressBar
                        value={tickUsage}
                        minValue={0}
                        maxValue={100}
                        ranges={{
                          good: [0, 85],
                          average: [85, 92],
                          bad: [92, 100],
                        }}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Planner Queue">
                      {gatewayStatus?.planner_queue ?? 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Parser Queue">
                      {gatewayStatus?.parser_queue ?? 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Inflight Requests">
                      {gatewayStatus?.inflight ?? 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Deferred Requests">
                      {gatewayStatus?.deferred ?? 0}
                    </LabeledList.Item>
                    <LabeledList.Item label="Planner Endpoint">
                      <Tooltip content={gatewayStatus?.planner_url || 'n/a'}>
                        <Box ellipsis maxWidth="340px">
                          {gatewayStatus?.planner_url || '—'}
                        </Box>
                      </Tooltip>
                    </LabeledList.Item>
                    <LabeledList.Item label="Parser Endpoint">
                      <Tooltip content={gatewayStatus?.parser_url || 'n/a'}>
                        <Box ellipsis maxWidth="340px">
                          {gatewayStatus?.parser_url || '—'}
                        </Box>
                      </Tooltip>
                    </LabeledList.Item>
                    <LabeledList.Item label="Timeouts (ds)">
                      Planner {gatewayStatus?.planner_timeout_ds ?? '—'} · Parser{' '}
                      {gatewayStatus?.parser_timeout_ds ?? '—'} · Retry{' '}
                      {gatewayStatus?.retry_ds ?? '—'}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>

              <Stack.Item>
                <PolicyEditor
                  policy={policy}
                  gatewayStatus={gatewayStatus}
                  lastPatchResponse={lastPatchResponse}
                  onSubmit={patchConfig}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type StatusBadgeProps = {
  status?: string;
};

const StatusBadge = ({ status }: StatusBadgeProps) => {
  if (!status) {
    return <Box color="label">Unknown</Box>;
  }
  const normalized = status.toLowerCase();
  let color: 'good' | 'average' | 'bad' | 'label' = 'label';
  switch (normalized) {
    case 'ai_active':
    case 'success':
      color = 'good';
      break;
    case 'player_override':
    case 'partial':
      color = 'average';
      break;
    case 'emergency_lockdown':
    case 'failure':
    case 'aborted':
      color = 'bad';
      break;
    default:
      color = 'label';
      break;
  }
  return (
    <Box bold color={color} textTransform="uppercase">
      {status.replace('_', ' ')}
    </Box>
  );
};

type RecentActionProps = {
  action: CrewActionEntry;
};

const RecentAction = ({ action }: RecentActionProps) => (
  <Stack gap={1} align="center">
    <Stack.Item>
      <Icon name="clock" />
    </Stack.Item>
    <Stack.Item grow>
      <Box bold>{action.verb || '—'}</Box>
      <Box color="label">
        {formatResult(action.result)} · {formatTimestamp(action.timestamp)}
      </Box>
    </Stack.Item>
  </Stack>
);

type PolicyEditorProps = {
  policy?: PolicySnapshot;
  gatewayStatus: GatewayStatus;
  lastPatchResponse?: Record<string, unknown>;
  onSubmit: (payload: ConfigPatchPayload) => void;
};

export const PolicyEditor = ({
  policy,
  gatewayStatus,
  lastPatchResponse,
  onSubmit,
}: PolicyEditorProps) => {
  const [multipliers, setMultipliers] = useState<Record<string, number>>(
    DEFAULT_MULTIPLIERS,
  );
  const [emergency, setEmergency] = useState<Record<string, number>>(
    DEFAULT_EMERGENCY,
  );
  const [safety, setSafety] = useState(DEFAULT_SAFETY);
  const [rates, setRates] = useState(DEFAULT_RATE_LIMITS);
  const [gateway, setGateway] = useState(DEFAULT_GATEWAY);
  const [telemetryMinutes, setTelemetryMinutes] = useState(
    DEFAULT_TELEMETRY_MINUTES,
  );
  const [dirty, setDirty] = useState(false);

  useEffect(() => {
    if (!policy) {
      return;
    }
    setMultipliers({
      ...DEFAULT_MULTIPLIERS,
      ...(policy.action_category_defaults || {}),
    });
    setEmergency({
      ...DEFAULT_EMERGENCY,
      ...(policy.emergency_modifiers || {}),
    });
    setSafety({
      max_hazard_score:
        policy.safety_thresholds?.max_hazard_score ?? DEFAULT_SAFETY.max_hazard_score,
      max_chain_failures:
        policy.safety_thresholds?.max_chain_failures ?? DEFAULT_SAFETY.max_chain_failures,
    });
    setRates({
      item_toggle_seconds:
        policy.rate_limits?.item_toggle_seconds ?? DEFAULT_RATE_LIMITS.item_toggle_seconds,
      aggressive_action_seconds:
        policy.rate_limits?.aggressive_action_seconds ?? DEFAULT_RATE_LIMITS.aggressive_action_seconds,
    });
    const plannerConfig = (policy.gateway as any)?.planner || {};
    const parserConfig = (policy.gateway as any)?.parser || {};
    setGateway({
      planner_url:
        plannerConfig.url || gatewayStatus.planner_url || DEFAULT_GATEWAY.planner_url,
      parser_url:
        parserConfig.url || gatewayStatus.parser_url || DEFAULT_GATEWAY.parser_url,
      planner_timeout_ds:
        plannerConfig.timeout_ds ||
        gatewayStatus.planner_timeout_ds ||
        DEFAULT_GATEWAY.planner_timeout_ds,
      parser_timeout_ds:
        parserConfig.timeout_ds ||
        gatewayStatus.parser_timeout_ds ||
        DEFAULT_GATEWAY.parser_timeout_ds,
      retry_ds:
        (policy.gateway as any)?.retry_ds ||
        gatewayStatus.retry_ds ||
        DEFAULT_GATEWAY.retry_ds,
    });
    setTelemetryMinutes(
      policy.telemetry_retention_minutes ?? DEFAULT_TELEMETRY_MINUTES,
    );
    setDirty(false);
  }, [gatewayStatus, policy]);

  const applyChanges = () => {
    onSubmit({
      action_category_defaults: multipliers,
      emergency_modifiers: emergency,
      safety_thresholds: safety,
      rate_limits: rates,
      gateway,
      telemetry_retention_minutes: telemetryMinutes,
    });
  };

  const applyPreset = (presetId: string) => {
    const preset = PRESETS.find((entry) => entry.id === presetId);
    if (!preset) {
      return;
    }
    setMultipliers(preset.multipliers);
    setEmergency({
      ...DEFAULT_EMERGENCY,
      ...preset.emergency,
    });
    setDirty(true);
  };

  return (
    <Section title="Policy & Configuration">
      {!policy ? (
        <NoticeBox info>
          Policy snapshot not available; ensure subsystem is initialised.
        </NoticeBox>
      ) : (
        <Stack vertical gap={2}>
          <Stack.Item>
            <Stack align="center" gap={1} wrap>
              <Stack.Item>
                <Box bold>Presets:</Box>
              </Stack.Item>
              {PRESETS.map((preset) => (
                <Stack.Item key={preset.id}>
                  <Button
                    size="small"
                    icon="wand-magic"
                    onClick={() => applyPreset(preset.id)}
                  >
                    {preset.label}
                  </Button>
                </Stack.Item>
              ))}
              <Stack.Item grow>
                <Box color="label" textAlign="right">
                  Telemetry window (minutes)
                </Box>
              </Stack.Item>
              <Stack.Item>
                <NumberInput
                  width="72px"
                  minValue={10}
                  maxValue={120}
                  step={5}
                  value={telemetryMinutes}
                  onChange={(event, value) => {
                    setTelemetryMinutes(value);
                    setDirty(true);
                  }}
                  onDrag={(event, value) => {
                    setTelemetryMinutes(value);
                    setDirty(true);
                  }}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item>
            <EditableTable
              title="Exploration Multipliers"
              data={multipliers}
              min={0.1}
              max={4}
              step={0.05}
              onChange={(key, value) => {
                setMultipliers({
                  ...multipliers,
                  [key]: value,
                });
                setDirty(true);
              }}
            />
          </Stack.Item>

          <Stack.Item>
            <EditableTable
              title="Emergency Modifiers"
              data={emergency}
              min={0}
              max={2}
              step={0.05}
              onChange={(key, value) => {
                setEmergency({
                  ...emergency,
                  [key]: value,
                });
                setDirty(true);
              }}
            />
          </Stack.Item>

          <Stack.Item>
            <Stack gap={2} wrap>
              <Stack.Item grow basis="45%">
                <Section title="Safety Thresholds">
                  <LabeledList>
                    <LabeledList.Item label="Max Hazard Score">
                      <NumberInput
                        minValue={0}
                        maxValue={1}
                        step={0.05}
                        value={safety.max_hazard_score}
                        onChange={(event, value) => {
                          setSafety({
                            ...safety,
                            max_hazard_score: value,
                          });
                          setDirty(true);
                        }}
                        onDrag={(event, value) => {
                          setSafety({
                            ...safety,
                            max_hazard_score: value,
                          });
                          setDirty(true);
                        }}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Max Chain Failures">
                      <NumberInput
                        minValue={0}
                        maxValue={10}
                        step={1}
                        value={safety.max_chain_failures}
                        onChange={(event, value) => {
                          setSafety({
                            ...safety,
                            max_chain_failures: value,
                          });
                          setDirty(true);
                        }}
                        onDrag={(event, value) => {
                          setSafety({
                            ...safety,
                            max_chain_failures: value,
                          });
                          setDirty(true);
                        }}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item grow basis="45%">
                <Section title="Rate Limits">
                  <LabeledList>
                    <LabeledList.Item label="Item Toggle Seconds">
                      <NumberInput
                        minValue={0}
                        maxValue={120}
                        step={1}
                        value={rates.item_toggle_seconds}
                        onChange={(event, value) => {
                          setRates({
                            ...rates,
                            item_toggle_seconds: value,
                          });
                          setDirty(true);
                        }}
                        onDrag={(event, value) => {
                          setRates({
                            ...rates,
                            item_toggle_seconds: value,
                          });
                          setDirty(true);
                        }}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Aggressive Action Seconds">
                      <NumberInput
                        minValue={0}
                        maxValue={300}
                        step={1}
                        value={rates.aggressive_action_seconds}
                        onChange={(event, value) => {
                          setRates({
                            ...rates,
                            aggressive_action_seconds: value,
                          });
                          setDirty(true);
                        }}
                        onDrag={(event, value) => {
                          setRates({
                            ...rates,
                            aggressive_action_seconds: value,
                          });
                          setDirty(true);
                        }}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item>
            <Section title="Gateway">
              <LabeledList>
                <LabeledList.Item label="Planner URL">
                  <Input
                    value={gateway.planner_url}
                    onChange={(value) => {
                      setGateway({
                        ...gateway,
                        planner_url: value,
                      });
                      setDirty(true);
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Parser URL">
                  <Input
                    value={gateway.parser_url}
                    onChange={(value) => {
                      setGateway({
                        ...gateway,
                        parser_url: value,
                      });
                      setDirty(true);
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Planner Timeout (ds)">
                  <NumberInput
                    minValue={5}
                    maxValue={300}
                    step={5}
                    value={gateway.planner_timeout_ds}
                    onChange={(event, value) => {
                      setGateway({
                        ...gateway,
                        planner_timeout_ds: value,
                      });
                      setDirty(true);
                    }}
                    onDrag={(event, value) => {
                      setGateway({
                        ...gateway,
                        planner_timeout_ds: value,
                      });
                      setDirty(true);
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Parser Timeout (ds)">
                  <NumberInput
                    minValue={5}
                    maxValue={300}
                    step={5}
                    value={gateway.parser_timeout_ds}
                    onChange={(event, value) => {
                      setGateway({
                        ...gateway,
                        parser_timeout_ds: value,
                      });
                      setDirty(true);
                    }}
                    onDrag={(event, value) => {
                      setGateway({
                        ...gateway,
                        parser_timeout_ds: value,
                      });
                      setDirty(true);
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Retry Delay (ds)">
                  <NumberInput
                    minValue={1}
                    maxValue={100}
                    step={1}
                    value={gateway.retry_ds}
                    onChange={(event, value) => {
                      setGateway({
                        ...gateway,
                        retry_ds: value,
                      });
                      setDirty(true);
                    }}
                    onDrag={(event, value) => {
                      setGateway({
                        ...gateway,
                        retry_ds: value,
                      });
                      setDirty(true);
                    }}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Stack align="center" justify="space-between">
              <Stack.Item>
                <Box color="label">
                  Pending status:{' '}
                  {dirty ? 'Unsaved changes' : 'In sync with runtime'}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="save"
                  color={dirty ? 'good' : 'default'}
                  disabled={!dirty}
                  onClick={applyChanges}
                >
                  Apply Changes
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {lastPatchResponse?.error && (
            <NoticeBox danger>
              Config update failed: {String(lastPatchResponse.error)}
            </NoticeBox>
          )}
          {lastPatchResponse && !lastPatchResponse.error && (
            <NoticeBox success>
              Policy updated at {lastPatchResponse.updated_at}
            </NoticeBox>
          )}
        </Stack>
      )}
    </Section>
  );
};

type EditableTableProps = {
  title: string;
  data: Record<string, number>;
  min: number;
  max: number;
  step: number;
  onChange: (key: string, value: number) => void;
};

const EditableTable = ({ title, data, min, max, step, onChange }: EditableTableProps) => {
  const entries = Object.entries(data);
  return (
    <Section title={title}>
      <Table>
        <Table.Row header>
          <Table.Cell>Key</Table.Cell>
          <Table.Cell collapsing>Value</Table.Cell>
        </Table.Row>
        {entries.map(([key, value]) => (
          <Table.Row key={key}>
            <Table.Cell>{key}</Table.Cell>
            <Table.Cell collapsing>
              <NumberInput
                width="80px"
                minValue={min}
                maxValue={max}
                step={step}
                value={value}
                onChange={(event, next) => onChange(key, next)}
                onDrag={(event, next) => onChange(key, next)}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
