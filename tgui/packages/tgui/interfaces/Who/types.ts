import type { BooleanLike } from 'tgui-core/react';

export type WhoData = {
  user: User;
  subject: Subject | null;
  clients: Record<string, Client[]>;
  modalOpen: BooleanLike;
};

type User = {
  key: string;
  admin: BooleanLike;
  ping: Ping;
};

type Client = {
  key: string;
  ping: Ping;
  status: Status | null;
  mobRef: string | null;
  accountAge: number | null;
  byondVerstion: string | null;
};

type Ping = {
  lastPing: number;
  avgPing: number;
};

type Status = {
  where: string;
  state: string;
  antag: BooleanLike;
};

type Subject = {
  key: string;
  ckey: string;
  type: string;
  gender: string;
  state: string;
  ping: Ping;
  name: SubjectName | null;
  role: SubjectRole;
  health: SubjectHealth | null;
  location: SubjectLocation | null;
  accountAge: number;
  accountIp: string;
  byondVersion: string;
};

type SubjectName = {
  real: string | null;
  mind: string | null;
};

type SubjectRole = {
  assigned: string;
  antagonist: string[] | null;
};

type SubjectHealth = {
  brute: number;
  burn: number;
  toxin: number;
  oxygen: number;
  brain: number;
  stamina: number;
};

type SubjectLocation = {
  area: string;
  x: number;
  y: number;
  z: number;
};
