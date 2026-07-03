import { useBackend, useLocalState } from 'tgui/backend';

import {
  PRINTOUT,
  type SecurityRecord,
  type SecurityRecordsData,
} from './types';

/** We need an active reference and this a pain to rewrite */
export const getSecurityRecord = () => {
  const [selectedRecord] = useLocalState<SecurityRecord | undefined>(
    'securityRecord',
    undefined,
  );
  if (!selectedRecord) return;
  const { data } = useBackend<SecurityRecordsData>();
  const { records = [] } = data;
  const foundRecord = records.find(
    (record) => record.crew_ref === selectedRecord.crew_ref,
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

/** Returns a string header based on print type */
export const getDefaultPrintHeader = (printType: PRINTOUT) => {
  switch (printType) {
    case PRINTOUT.Rapsheet:
      return 'Запись';
    case PRINTOUT.Wanted:
      return 'РАЗЫСКИВАЕТСЯ';
    case PRINTOUT.Missing:
      return 'ПРОПАЛ';
  }
};

/** Returns a string description based on print type */
export const getDefaultPrintDescription = (
  name: string,
  printType: PRINTOUT,
) => {
  switch (printType) {
    case PRINTOUT.Rapsheet:
      return `Стандартная запись охраны по: ${name}.`;
    case PRINTOUT.Wanted:
      return `Постер, указывающий ${name} как разыскиваемого преступника, разыскивается Нанотрейзен. Немедленно сообщайте о местоположении охране.`;
    case PRINTOUT.Missing:
      return `Постер, указывающий ${name} как пропавшего индивида, ищется Нанонтрейзен. Немедленно сообщайте о местоположении охране.`;
  }
};
