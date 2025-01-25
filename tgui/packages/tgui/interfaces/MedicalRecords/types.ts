import { BooleanLike } from 'tgui-core/react';

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
  age: number;
  // DOPPLER EDIT: chronological age
  age_chronological: number;
  blood_type: string;
  crew_ref: string;
  dna: string;
  gender: string;
  major_disabilities: string;
  minor_disabilities: string;
  physical_status: string;
  mental_status: string;
  name: string;
  notes: MedicalNote[];
  quirk_notes: string;
  rank: string;
  species: string;
  trim: string;
  // DOPPLER EDIT BEGIN - records & flavor text
  past_general_records: string;
  past_medical_records: string;
  // DOPPLER EDIT END
};

export type MedicalNote = {
  author: string;
  content: string;
  note_ref: string;
  time: string;
};
