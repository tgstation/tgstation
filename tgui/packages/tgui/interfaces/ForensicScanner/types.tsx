export type ForensicScannerData = {
  logs: LogEntry[];
  categories: Record<string, ForensicScannerCategory>;
};

export type LogEntry = {
  scanTarget: string;
  scanTime: string;
  dataEntries: DataEntry[];
};

export type DataEntry = {
  category: string;
  data: Record<string, string>;
};

export type ForensicScannerCategory = {
  name: string;
  uiIcon: string;
  uiIconColor: string;
};
