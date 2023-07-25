import { BooleanLike } from 'common/react';

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

type MechElectronics = {
  microphone: boolean;
  speaker: boolean;
  frequency: number;
  minfreq: number;
  maxfreq: number;
};

export type MechWeapon = {
  name: string;
  desc: string;
  ref: string;
  isballisticweapon: boolean;
  integrity: number;
  energy_per_use: number;
  // null when not ballistic weapon
  disabledreload: boolean | null;
  projectiles: number | null;
  max_magazine: number | null;
  projectiles_cache: number | null;
  projectiles_cache_max: number | null;
  ammo_type: string | null;
  // first entry is always "snowflake_id"=snowflake_id if snowflake
  snowflake: any;
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
  airtank_present: BooleanLike;
  air_source: string;
  mechflag_keys: string[];
  cabin_dangerous_highpressure: number;
  airtank_pressure: number | null;
  airtank_temp: number | null;
  port_connected: boolean | null;
  cabin_pressure: number;
  cabin_temp: number;
  dna_lock: string | null;
  mech_electronics: MechElectronics;
  right_arm_weapon: MechWeapon | null;
  left_arm_weapon: MechWeapon | null;
  weapons_safety: boolean;
  mech_equipment: MechEquipment;
  mech_view: string;
  sheet_material_amount: number;
  modules: MechModule[];
};

export type MechaUtility = {
  activated: boolean;
  name: string;
  ref: string;
  snowflake: any;
};

export type MechModule = {
  type: string;
  icon: string;
  name: string;
  detachable: boolean;
  activated: boolean;
  equip_cooldown: number;
  energy_per_use: number;
  snowflake: Snowflake;
  ref: string;
};

export type MechEquipment = {
  utility: MechUtilityModule[];
  power: MechUtilityModule[];
  armor: MechArmorModule[];
};

export type MechUtilityModule = {
  name: string;
  activated: boolean;
  ref: string;
  snowflake: Snowflake;
};

export type MechArmorModule = {
  protect_name: string;
  iconstate_name: string;
  ref: string;
};

export type Snowflake = {
  snowflake_id: string;
  integrity: number;
};

export type SnowflakeWeapon = {
  snowflake_id: string;
};
