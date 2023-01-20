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
  const { records } = data;
  const foundRecord = records.find(
    (record) => record.ref === selectedRecord.ref
  );
  if (!foundRecord) return;

  return foundRecord;
};

type GenericRecord = {
  name: string;
  rank: string;
};

/** Matches search by fingerprint, dna, job, or name */
export const isRecordMatch = <TRecord extends GenericRecord>(
  record: TRecord,
  search: string
) => {
  // There is no reason to do it like this I just wanted to try it
  switch (true) {
    case record.rank?.toLowerCase().includes(search?.toLowerCase()):
    case record.name?.toLowerCase().includes(search?.toLowerCase()):
    case 'fingerprint' in record &&
      typeof record.fingerprint === 'string' &&
      record.fingerprint?.toLowerCase().includes(search?.toLowerCase()):
    case 'dna' in record &&
      typeof record.dna === 'string' &&
      record.dna?.toLowerCase().includes(search?.toLowerCase()):
      return true;
    default:
      return false;
  }
};
