import type { BooleanLike } from 'tgui-core/react';

export type Data = {
  accounts: PlayerAccount[];
  audit_log: AuditLog[];
  crashing: BooleanLike;
  pic_file_format: string;
  max_pay_mod: number;
  min_pay_mod: number;
  max_advances: number;
  station_time: string;
  young_ian: BooleanLike;
};

type PlayerAccount = {
  id: number;
  name: string;
  balance: number;
  job: string;
  modifier: number;
  num_advances: number;
};

type AuditLog = {
  account: number;
  cost: number;
  vendor: string;
  stationtime: string;
};

export enum SCREENS {
  none,
  users,
  audit,
  ian,
}

export enum SORTING {
  ascending,
  descending,
  none,
}
