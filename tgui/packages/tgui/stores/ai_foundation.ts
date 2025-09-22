import { useCallback, useEffect, useMemo } from 'react';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';

const DEFAULT_REFRESH_COOLDOWN_DS = 50;

export type CrewActionEntry = {
  verb: string;
  result: string;
  timestamp: string;
};

export type CrewSummary = {
  profile_id: string;
  job_id?: string;
  status?: string;
  current_objective?: string;
  action_category_weights?: Record<string, number>;
  recent_actions?: CrewActionEntry[];
};

export type TimelineEntry = {
  sequence_id: number;
  selected_action: string;
  exploration_bonus: number;
  rollout_count: number;
  result: string;
  notes?: string | null;
  timestamp?: string;
};

export type TimelinePayload = {
  profile_id: string;
  entries?: TimelineEntry[];
  job_id?: string;
  status?: string;
  current_objective?: string;
  generated_at?: string;
  error?: string;
};

export type GatewayStatus = {
  feature_enabled?: BooleanLike;
  backpressure_state?: number;
  tick_usage?: number;
  planner_queue?: number;
  parser_queue?: number;
  inflight?: number;
  deferred?: number;
  last_policy_refresh?: number;
  planner_url?: string;
  parser_url?: string;
  planner_timeout_ds?: number;
  parser_timeout_ds?: number;
  retry_ds?: number;
};

export type PolicySnapshot = {
  enabled?: BooleanLike;
  cadence_seconds?: number;
  max_rollouts_per_cycle?: number;
  task_queue_limit?: number;
  telemetry_retention_minutes?: number;
  action_category_defaults?: Record<string, number>;
  emergency_modifiers?: Record<string, number>;
  safety_thresholds?: Record<string, number>;
  rate_limits?: Record<string, number>;
  telemetry?: Record<string, number>;
  reservation?: Record<string, number>;
  gateway?: Record<string, unknown>;
};

export type ConfigPatchPayload = {
  action_category_defaults?: Record<string, number>;
  emergency_modifiers?: Record<string, number>;
  safety_thresholds?: Record<string, number>;
  rate_limits?: Record<string, number>;
  gateway?: Record<string, string | number>;
  telemetry_retention_minutes?: number;
};

export type AIFoundationData = {
  refresh_cooldown_ds?: number;
  blackboard?: {
    generated_at?: string;
    crew?: CrewSummary[];
    error?: string;
  };
  last_refresh_ds?: number;
  now_ds?: number;
  timelines?: Record<string, TimelinePayload>;
  gateway_status?: GatewayStatus;
  policy?: PolicySnapshot;
  last_patch_response?: Record<string, unknown>;
};

export const useAIFoundationStore = () => {
  const backend = useBackend<AIFoundationData>();
  const { act, data } = backend;

  const refreshCooldownDs = data.refresh_cooldown_ds ?? DEFAULT_REFRESH_COOLDOWN_DS;
  const refreshCooldownMs = Math.max(refreshCooldownDs, 5) * 100;

  const [selectedProfile, setSelectedProfile] = useLocalState<string>(
    'ai-foundation-profile',
    '',
  );
  const [autoRefresh, setAutoRefresh] = useLocalState<boolean>(
    'ai-foundation-auto-refresh',
    true,
  );
  const [search, setSearch] = useLocalState<string>('ai-foundation-search', '');
  const [pendingTimeline, setPendingTimeline] = useLocalState<string>(
    'ai-foundation-pending-timeline',
    '',
  );

  const crew = data.blackboard?.crew ?? [];

  useEffect(() => {
    if (!crew.length) {
      if (selectedProfile) {
        setSelectedProfile('');
      }
      return;
    }
    if (selectedProfile && crew.some((entry) => entry.profile_id === selectedProfile)) {
      return;
    }
    const first = crew[0]?.profile_id || '';
    if (first && first !== selectedProfile) {
      setSelectedProfile(first);
    }
  }, [crew, selectedProfile, setSelectedProfile]);

  useEffect(() => {
    if (!autoRefresh) {
      return;
    }
    const id = window.setInterval(() => {
      act('refresh');
    }, refreshCooldownMs);
    return () => window.clearInterval(id);
  }, [act, autoRefresh, refreshCooldownMs]);

  useEffect(() => {
    if (!selectedProfile) {
      return;
    }
    const hasTimeline = !!data.timelines?.[selectedProfile];
    if (hasTimeline) {
      if (pendingTimeline === selectedProfile) {
        setPendingTimeline('');
      }
      return;
    }
    if (pendingTimeline === selectedProfile) {
      return;
    }
    setPendingTimeline(selectedProfile);
    act('loadTimeline', {
      profile_id: selectedProfile,
    });
  }, [act, data.timelines, pendingTimeline, selectedProfile, setPendingTimeline]);

  const refresh = useCallback(() => {
    act('refresh');
  }, [act]);

  const loadTimeline = useCallback(
    (profileId: string, force = false) => {
      if (!profileId) {
        return;
      }
      setPendingTimeline(profileId);
      act('loadTimeline', {
        profile_id: profileId,
        force,
      });
    },
    [act, setPendingTimeline],
  );

  const clearTimeline = useCallback(
    (profileId: string) => {
      if (!profileId) {
        return;
      }
      act('clearTimeline', {
        profile_id: profileId,
      });
    },
    [act],
  );

  const patchConfig = useCallback(
    (payload: ConfigPatchPayload) => {
      act('patchConfig', payload);
    },
    [act],
  );

  const filteredCrew = useMemo(() => {
    const token = search.trim().toLowerCase();
    if (!token) {
      return crew;
    }
    return crew.filter((entry) => {
      const haystack = [
        entry.profile_id,
        entry.job_id,
        entry.status,
        entry.current_objective,
      ]
        .filter(Boolean)
        .join(' ')
        .toLowerCase();
      return haystack.includes(token);
    });
  }, [crew, search]);

  const selectedSummary = useMemo(
    () => crew.find((entry) => entry.profile_id === selectedProfile),
    [crew, selectedProfile],
  );

  const selectedTimeline = selectedProfile
    ? data.timelines?.[selectedProfile]
    : undefined;

  const timelineLoading =
    !!selectedProfile &&
    pendingTimeline === selectedProfile &&
    !selectedTimeline;

  return {
    backend,
    crew: filteredCrew,
    rawCrew: crew,
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
    gatewayStatus: data.gateway_status ?? {},
    policy: data.policy,
    lastPatchResponse: data.last_patch_response,
    blackboard: data.blackboard,
    lastRefreshDs: data.last_refresh_ds,
    nowDs: data.now_ds,
    refreshCooldownDs,
  } as const;
};
