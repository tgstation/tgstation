import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ForensicScannerData = {
  log_data: LogData[];
};

type LogData = {
  scan_target: string;
  scan_time: string;
  Prints: Record<string, string>;
  Fibers: Record<string, string>;
  Blood: Record<string, string>;
  Reagents: Record<string, number>;
  'ID Access': Record<string, string[]>;
};

export const ForensicScanner = (props) => {
  const { act, data } = useBackend<ForensicScannerData>();
  const { log_data = [] } = data;
  return (
    <Window width={512} height={512}>
      <Window.Content>
        {log_data.length === 0 ? (
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
            {log_data
              .map((log, index) => (
                <ForensicLog key={index} log={log} index={index} />
              ))
              .reverse()}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const ForensicLog = ({ log, index }: { log: LogData; index: number }) => {
  const { act } = useBackend<ForensicScannerData>();
  return (
    <Section
      title={`${capitalizeFirst(log.scan_target)} scan at ${log.scan_time}`}
      buttons={
        <Button
          icon="trash"
          color="transparent"
          onClick={() => act('delete', { index })}
        />
      }
    >
      {!log.Prints && !log.Fibers && !log.Blood && !log.Reagents ? (
        <Box opacity={0.5}>No forensic traces found.</Box>
      ) : (
        <LabeledList>
          {log.Fibers && Object.keys(log.Fibers).length > 0 && (
            <LabeledList.Item label="Fibers">
              {Object.keys(log.Fibers).map((fibers) => (
                <Box key={fibers} py={0.5}>
                  <Icon name="shirt" mr={1} color="green" />
                  {fibers}
                </Box>
              ))}
            </LabeledList.Item>
          )}
          {log.Prints && Object.values(log.Prints).length > 0 && (
            <LabeledList.Item label="Fingerprints">
              {Object.values(log.Prints).map((print) => (
                <Box
                  key={print}
                  py={0.5}
                  style={{ textTransform: 'uppercase' }}
                >
                  <Icon name="fingerprint" mr={1} color="yellow" />
                  {print}
                </Box>
              ))}
            </LabeledList.Item>
          )}
          {log.Blood && Object.keys(log.Blood).length > 0 && (
            <LabeledList.Item label="Blood DNA, Type">
              {Object.keys(log.Blood).map((dna) => (
                <Box key={dna} py={0.5} style={{ textTransform: 'uppercase' }}>
                  <Icon name="droplet" mr={1} color="red" />
                  {`${dna}, ${log.Blood[dna]}`}
                </Box>
              ))}
            </LabeledList.Item>
          )}
          {log.Reagents && Object.keys(log.Reagents)?.length > 0 && (
            <LabeledList.Item label="Reagents">
              <LabeledList>
                {Object.keys(log.Reagents).map((reagent) => (
                  <LabeledList.Item key={reagent} label={reagent}>
                    {`${log.Reagents[reagent]} u.`}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </LabeledList.Item>
          )}
          {log['ID Access'] && Object.keys(log['ID Access'])?.length > 0 && (
            <LabeledList.Item label="ID Access">
              <LabeledList>
                {Object.keys(log['ID Access']).map((region) => (
                  <LabeledList.Item key={region} label={region}>
                    {log['ID Access'][region]}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </LabeledList.Item>
          )}
        </LabeledList>
      )}
    </Section>
  ) as any;
};
