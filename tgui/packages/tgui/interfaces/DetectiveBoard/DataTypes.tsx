export type DataCase = {
  ref: string;
  name: string;
  color: string;
  evidences: DataEvidence[];
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
