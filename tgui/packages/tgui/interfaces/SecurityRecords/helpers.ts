import { useBackend, useLocalState } from 'tgui/backend';
import { SecureData, SecurityRecord } from './types';

/** We need an active reference and this a pain to rewrite */
export const getCurrentRecord = (context) => {
  const [selectedRecord] = useLocalState<SecurityRecord | undefined>(
    context,
    'securityRecord',
    undefined
  );
  if (!selectedRecord) return;
  const { data } = useBackend<SecureData>(context);
  const { records = [] } = data;
  const foundRecord = records.find(
    (record) => record.ref === selectedRecord.ref
  );
  if (!foundRecord) return;

  return foundRecord;
};

// Lazy type union
type GenericRecord = {
  name: string;
  rank: string;
  fingerprint?: string;
  dna?: string;
};

/** Matches search by fingerprint, dna, job, or name */
export const isRecordMatch = (record: GenericRecord, search: string) => {
  if (!search) return true;
  const { name, rank, fingerprint, dna } = record;

  switch (true) {
    case name?.toLowerCase().includes(search?.toLowerCase()):
    case rank?.toLowerCase().includes(search?.toLowerCase()):
    case fingerprint?.toLowerCase().includes(search?.toLowerCase()):
    case dna?.toLowerCase().includes(search?.toLowerCase()):
      return true;

    default:
      return false;
  }
};
