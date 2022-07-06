export type Data = {
  available: Available;
  directives: string;
  door_jack?: string;
  emagged: number;
  image: string;
  installed: ReadonlyArray<string>;
  languages: number;
  master: Master;
  pda: PDA;
  ram: number;
  records: Records;
  refresh_spam: number;
};

export type Available = {
  name: string;
  value: string | number;
};

export type Master = {
  name: string;
  dna: string;
};

export type PDA = {
  power: number;
  silent: number;
};

export type Records = Partial<{
  medical: CrewRecord;
  security: CrewRecord;
}>;

export type CrewRecord = ReadonlyArray<Record<string, string>>;
