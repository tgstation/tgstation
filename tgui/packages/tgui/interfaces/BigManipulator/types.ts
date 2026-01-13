import type { BooleanLike } from 'tgui-core/react';

export interface PrioritySettings {
  name: string;
  priority_width: number;
  active: BooleanLike;
}

export type InteractionPoint = {
  name: string;
  id: string;
  turf: string;
  mode: string;
  filters: string[];
  item_filters: string[];
  filters_status: BooleanLike;
  filtering_mode: number;
  overflow_status: string;
  worker_use_rmb: BooleanLike;
  worker_combat_mode: BooleanLike;
  settings_list: PrioritySettings[];
  throw_range: number;
  worker_interaction: string;
  use_post_interaction: string;
};

export interface ManipulatorData {
  active: BooleanLike;
  current_task: string;
  current_task_duration: number;

  speed_multiplier: number;
  min_speed_multiplier: number;
  max_speed_multiplier: number;
  highest_priority: BooleanLike;
  interaction_mode: string;
  settings_list: PrioritySettings[];
  throw_range: number;
  item_as_filter: string;
  selected_type: string;
  delay_step: number;

  pickup_points: InteractionPoint[];
  dropoff_points: InteractionPoint[];
  manipulator_position: string;
  pickup_tasking: string;
  dropoff_tasking: string;
}
