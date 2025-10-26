import { Box, Button, Icon, LabeledList, Section } from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';
import { useBackend } from '../../backend';
import type { DataEntry, ForensicScannerData } from './types';

type ForensicLogsProps = {
  dataEntries: DataEntry[];
  scanTarget: string;
  scanTime: string;
  index: number;
};

export function ForensicLogs(props: ForensicLogsProps) {
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
  log: Record<string, string>;
  iconName: string;
  iconColor: string;
};

function ForensicLog(props: ForensicLogProps) {
  const { logCategoryId, log, iconName, iconColor } = props;
  if (logCategoryId === 'Fingerprints')
    return (
      <PrintsLogFormatter log={log} iconName={iconName} iconColor={iconColor} />
    );

  if (logCategoryId === 'Reagents')
    return (
      <ReagentsLogFormatter
        log={log}
        iconName={iconName}
        iconColor={iconColor}
      />
    );

  if (logCategoryId === 'Blood')
    return (
      <BloodLogFormatter log={log} iconName={iconName} iconColor={iconColor} />
    );

  if (logCategoryId === 'ID_Access')
    return (
      <IdAccessLogFormatter
        log={log}
        iconName={iconName}
        iconColor={iconColor}
      />
    );

  return (
    <DefaultLogFormatter log={log} iconName={iconName} iconColor={iconColor} />
  );
}

type LogFormatterProprs = {
  log: Record<string, string>;
  iconName: string;
  iconColor: string;
};

function DefaultLogFormatter(props: LogFormatterProprs) {
  const { log, iconName, iconColor } = props;
  return (
    <>
      {Object.entries(log).map(([key, value]) => (
        <Box key={key} py={0.5}>
          <Icon name={iconName} mr={1} color={iconColor} />
          {value}
        </Box>
      ))}
    </>
  );
}

function BloodLogFormatter(props: LogFormatterProprs) {
  const { log, iconName, iconColor } = props;
  return (
    <>
      {Object.entries(log).map(([key, value]) => (
        <Box key={key} py={0.5} style={{ textTransform: 'uppercase' }}>
          <Icon name={iconName} mr={1} color={iconColor} />
          {`${key}, ${value}`}
        </Box>
      ))}
    </>
  );
}

function PrintsLogFormatter(props: LogFormatterProprs) {
  const { log, iconName, iconColor } = props;
  return (
    <>
      {Object.entries(log).map(([key, value]) => (
        <Box key={key} py={0.5} style={{ textTransform: 'uppercase' }}>
          <Icon name={iconName} mr={1} color={iconColor} />
          {value}
        </Box>
      ))}
    </>
  );
}

function ReagentsLogFormatter(props: LogFormatterProprs) {
  const { log, iconName, iconColor } = props;
  return (
    <LabeledList>
      {Object.keys(log).map((reagent) => (
        <LabeledList.Item
          key={reagent}
          label={
            <>
              <Icon name={iconName} mr={1} color={iconColor} />
              {reagent}
            </>
          }
        >
          {`${log[reagent]} u.`}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
}

function IdAccessLogFormatter(props: LogFormatterProprs) {
  const { log, iconName, iconColor } = props;
  return (
    <LabeledList>
      {Object.keys(log).map((region) => (
        <LabeledList.Item
          key={region}
          label={
            <>
              <Icon name={iconName} mr={1} color={iconColor} />
              {region}
            </>
          }
        >
          {log[region]}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
}
