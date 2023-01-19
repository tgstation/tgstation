import { useBackend, useLocalState } from 'tgui/backend';
import { SecureData, SecurityRecord } from './types';

/** We need an active reference and this a pain to rewrite */
export const getCurrentRecord = (context) => {
  const [selectedRecord] = useLocalState<SecurityRecord | undefined>(
    context,
    'selectedRecord',
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
