import type { BooleanLike } from 'tgui-core/react';

export interface PrioritySettings {
  name: string;
  active: BooleanLike;
}

export type TaskType =
  | 'Pick up...'
  | 'Drop...'
  | 'Throw...'
  | 'Use...'
  | 'Interact with...'
  | 'Wait for...';

export interface ManipulatorTask {
  name: string;
  id: string;
  task_type: string;
  // cargo fields
  turf?: string;
  item_filters?: string[];
  filters_status?: BooleanLike;
  filtering_mode?: number;
  settings_list?: PrioritySettings[];
  // pickup only
  pickup_eagerness?: string;
  // dropoff only
  interaction_mode?: string;
  overflow_status?: string;
  throw_range?: number;
  worker_interaction?: string;
  use_post_interaction?: string;
  worker_use_rmb?: BooleanLike;
  worker_combat_mode?: BooleanLike;
  // interact only
  // (worker_interaction, use_post_interaction, worker_use_rmb, worker_combat_mode shared with dropoff)
  time?: number;
}

export interface ManipulatorData {
  active: BooleanLike;
  stopping: BooleanLike;
  current_task: string | null;
  speed_multiplier: number;
  min_speed_multiplier: number;
  max_speed_multiplier: number;
  tasks_data: ManipulatorTask[];
  manipulator_position: string;
  tasking_strategy: string;
  has_monkey: BooleanLike;
}
