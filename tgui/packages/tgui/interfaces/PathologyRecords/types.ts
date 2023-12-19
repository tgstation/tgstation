import { BooleanLike } from 'common/react';

export type MedicalRecordData = {
  assigned_view: string;
  authenticated: BooleanLike;
  station_z: BooleanLike;
  physical_statuses: string[];
  mental_statuses: string[];
  records: MedicalRecord[];
  min_age: number;
  max_age: number;
};

export type MedicalRecord = {
  crew_ref: string;
  name: string;
  nickname: string;
  sub: string;
  id: string;
  child: string;
  description: string;
  spread_flags: string;
  danger: string;
  antigen: string;
  form: string;
};

export type MedicalNote = {
  author: string;
  content: string;
  note_ref: string;
  time: string;
};
