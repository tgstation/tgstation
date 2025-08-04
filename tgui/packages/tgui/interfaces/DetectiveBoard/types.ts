import type { Connection } from '../common/Connections';

export type DataCase = {
  ref: string;
  name: string;
  color: string;
  evidences: DataEvidence[];
  connections: Connection[];
};

export type DataEvidence = {
  ref: string;
  name: string;
  description: string;
  type: string;
  x: number;
  y: number;
  photo_url: string;
  text: string;
  connections: string[];
};

export type EvidenceFn = (evidence: DataEvidence) => void;
