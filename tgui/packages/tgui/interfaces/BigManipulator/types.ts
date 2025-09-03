import type { BooleanLike } from 'tgui-core/react';

export interface PrioritySettings {
  name: string;
  priority_width: number;
}

export type InteractionPoint = {
  name: string;
  id: string;
  turf: string;
  mode: string;
  filters: string[];
  item_filters: string[];
  filters_status: boolean;
  filtering_mode: number;
  overflow_status: string;
};

export interface ManipulatorData {
  active: BooleanLike;
  interaction_delay: number;
  worker_interaction: string;
  highest_priority: BooleanLike;
  interaction_mode: string;
  settings_list: PrioritySettings[];
  throw_range: number;
  item_as_filter: string;
  selected_type: string;
  delay_step: number;
  min_delay: number;
  max_delay: number;
  current_task_type: string;
  current_task_duration: number;
  pickup_points: InteractionPoint[];
  dropoff_points: InteractionPoint[];
  manipulator_position: string;
  pickup_tasking: string;
  dropoff_tasking: string;
}
