export const KelvinZeroCelcius = 273.15;

export const InternalDamageToDamagedDesc = {
  'MECHA_INT_FIRE': 'Internal fire detected',
  'MECHA_INT_TEMP_CONTROL': 'Cabin heater offline',
  'MECHA_CABIN_AIR_BREACH': 'Cabin breach detected',
  'MECHA_INT_CONTROL_LOST': 'Servo motors damaged',
  'MECHA_INT_SHORT_CIRCUIT': 'Capacitors shorted',
};

export const InternalDamageToNormalDesc = {
  'MECHA_INT_FIRE': 'No internal fires detected',
  'MECHA_INT_TEMP_CONTROL': 'Cabin heater active',
  'MECHA_CABIN_AIR_BREACH': 'Cabin sealing intact',
  'MECHA_INT_CONTROL_LOST': 'Servo motors active',
  'MECHA_INT_SHORT_CIRCUIT': 'Capacitors operational',
};

export type AccessData = {
  name: string;
  number: number;
};

export type MainData = {
  isoperator: boolean;
  ui_theme: string;
  name: string;
  integrity: number;
  power_level: number | null;
  power_max: number | null;
  mecha_flags: number;
  internal_damage: number;
  internal_damage_keys: string[];
  mechflag_keys: string[];

  one_access: boolean;
  regions: string[];
  accesses: string[];

  servo_rating: number;
  scanmod_rating: number;
  capacitor_rating: number;

  cabin_pressure_warning_min: number;
  cabin_pressure_hazard_min: number;
  cabin_pressure_warning_max: number;
  cabin_pressure_hazard_max: number;
  cabin_temp_warning_min: number;
  cabin_temp_hazard_min: number;
  cabin_temp_warning_max: number;
  cabin_temp_hazard_max: number;

  one_atmosphere: number;
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
