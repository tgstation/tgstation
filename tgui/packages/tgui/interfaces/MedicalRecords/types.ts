import { BooleanLike } from 'common/react';

export type MedicalRecordData = {
  authenticated: BooleanLike;
  records: MedicalRecord[];
};

export type MedicalRecord = {
  age: number;
  appearance: string;
  blood_type: string;
  crew_ref: string;
  dna: string;
  gender: string;
  major_disabilities: string;
  minor_disabilities: string;
  name: string;
  notes: MedicalNote[];
  quirk_notes: string;
  rank: string;
  species: string;
};

export type MedicalNote = {
  author: string;
  content: string;
  note_ref: string;
  time: string;
};
