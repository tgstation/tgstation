import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { logFormatters } from './constants';
import type { DataEntry, ForensicScannerData } from './types';

export function ForensicScanner() {
  const { act, data } = useBackend<ForensicScannerData>();
  const { logs = [] } = data;
  return (
    <Window width={512} height={512}>
      <Window.Content>
        {logs.length === 0 ? (
          <NoticeBox>Log empty.</NoticeBox>
        ) : (
          <Section
            title="Scan history"
            fill
            scrollable
            buttons={
              <>
                <Button.Confirm
                  icon="trash"
                  color="danger"
                  onClick={() => act('clear')}
                >
                  Clear logs
                </Button.Confirm>
                <Button icon="print" onClick={() => act('print')}>
                  Print report
                </Button>
              </>
            }
          >
            {logs
              .map((log, index) => (
                <ForensicLogs
                  key={index}
                  dataEntries={log.dataEntries}
                  scanTarget={log.scanTarget}
                  scanTime={log.scanTime}
                  index={index}
                />
              ))
              .reverse()}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
}

type ForensicLogsProps = {
  dataEntries: DataEntry[];
  scanTarget: string;
  scanTime: string;
  index: number;
};

function ForensicLogs(props: ForensicLogsProps) {
  const { act, data } = useBackend<ForensicScannerData>();
  const { categories } = data;
  const { dataEntries, scanTarget, scanTime, index } = props;
  return (
    <Section
      title={`${capitalizeFirst(scanTarget)} scan at ${scanTime} `}
      buttons={
        <Button
          icon="trash"
          color="transparent"
          onClick={() => act('delete', { index })}
        />
      }
    >
      {dataEntries.length === 0 ? (
        <Box opacity={0.5}>No forensic traces found.</Box>
      ) : (
        <LabeledList>
          {dataEntries.map((dataEntry) => {
            const category = categories[dataEntry.category];
            return (
              <LabeledList.Item key={category.name} label={category.name}>
                <ForensicLog
                  logCategoryId={dataEntry.category}
                  log={dataEntry.data}
                  iconName={category.uiIcon}
                  iconColor={category.uiIconColor}
                />
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      )}
    </Section>
  );
}

type ForensicLogProps = {
  logCategoryId: string;
  log: Record<string, string | string[]>;
  iconName: string;
  iconColor: string;
};

function ForensicLog(props: ForensicLogProps) {
  const { logCategoryId, log, iconName, iconColor } = props;
  return (
    <>
      {logFormatters[logCategoryId]
        ? logFormatters[logCategoryId]({ log, iconName, iconColor })
        : Object.entries(log).map(([key, value]) => (
            <Box key={key} py={0.5}>
              <Icon name={iconName} mr={1} color={iconColor} />
              {value}
            </Box>
          ))}
    </>
  );
}
