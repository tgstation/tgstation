export const KelvinZeroCelcius = 273.15;

export const InternalDamageToDamagedDesc = {
  'MECHA_INT_FIRE': 'Internal fire detected',
  'MECHA_INT_TEMP_CONTROL': 'Temperature control inactive',
  'MECHA_INT_TANK_BREACH': 'Air tank breach detected',
  'MECHA_INT_CONTROL_LOST': 'Control module damaged',
};

export const InternalDamageToNormalDesc = {
  'MECHA_INT_FIRE': 'No internal fires detected',
  'MECHA_INT_TEMP_CONTROL': 'Temperature control active',
  'MECHA_INT_TANK_BREACH': 'Air tank intact',
  'MECHA_INT_CONTROL_LOST': 'Control module active',
  'MECHA_INT_SHORT_CIRCUIT': 'Internal capacitor operational',
};

export type AccessData = {
  name: string;
  number: number;
};

export type MainData = {
  isoperator: boolean;
  ui_theme: string;
};

export type MaintData = {
  name: string;
  mecha_flags: number;
  mechflag_keys: string[];
  internal_tank_valve: number;
  cell: string;
  scanning: string;
  capacitor: string;
  operation_req_access: AccessData[];
  idcard_access: AccessData[];
};

export type OperatorData = {
  name: string;
  integrity: number;
  power_level: number | null;
  power_max: number | null;
  mecha_flags: number;
  internal_damage: number;
  internal_damage_keys: string[];
  mechflag_keys: string[];
  cabin_dangerous_highpressure: number;
  cabin_pressure: number;
  cabin_temp: number;
  enclosed: boolean;
  cabin_sealed: boolean;
  dna_lock: string | null;
  weapons_safety: boolean;
  mech_view: string;
  modules: MechModule[];
  selected_module_index: number;
  sheet_material_amount: number;
};

export type MechModule = {
  selected: boolean;
  slot: string;
  icon: string;
  name: string;
  detachable: boolean;
  can_be_toggled: boolean;
  can_be_triggered: boolean;
  active: boolean;
  active_label: string;
  equip_cooldown: string;
  energy_per_use: number;
  snowflake: Snowflake;
  ref: string;
};

export type Snowflake = {
  snowflake_id: string;
  integrity: number;
};

export type SnowflakeWeapon = {
  snowflake_id: string;
};
