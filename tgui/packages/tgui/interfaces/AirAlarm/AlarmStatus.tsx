import { LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { AirAlarmData } from './types';

const dangerMap = {
  0: {
    color: 'good',
    localStatusText: 'Optimal',
  },
  1: {
    color: 'average',
    localStatusText: 'Caution',
  },
  2: {
    color: 'bad',
    localStatusText: 'Danger (Internals Required)',
  },
} as const;

const faultMap = {
  0: {
    color: 'good',
    areaFaultText: 'None',
  },
  1: {
    color: 'purple',
    areaFaultText: 'Manual Trigger',
  },
  2: {
    color: 'average',
    areaFaultText: 'Automatic Detection',
  },
} as const;

export function AirAlarmStatus(props) {
  const { data } = useBackend<AirAlarmData>();
  const { envData } = data;

  const localStatus = dangerMap[data.dangerLevel] || dangerMap[0];
  const areaFault = faultMap[data.faultStatus] || faultMap[0];

  return (
    <Section title="Air Status">
      <LabeledList>
        {envData.length <= 0 ? (
          <LabeledList.Item label="Warning" color="bad">
            Cannot obtain air sample for analysis.
          </LabeledList.Item>
        ) : (
          <>
            {envData.map((entry) => {
              const status = dangerMap[entry.danger] || dangerMap[0];
              return (
                <LabeledList.Item
                  key={entry.name}
                  label={entry.name}
                  color={status.color}
                >
                  {entry.value}
                </LabeledList.Item>
              );
            })}
            <LabeledList.Item label="Local Status" color={localStatus.color}>
              {localStatus.localStatusText}
            </LabeledList.Item>
            <LabeledList.Item
              label="Area Status"
              color={data.atmosAlarm || data.fireAlarm ? 'bad' : 'good'}
            >
              {(data.atmosAlarm && 'Atmosphere Alarm') ||
                (data.fireAlarm && 'Fire Alarm') ||
                'Nominal'}
            </LabeledList.Item>
            <LabeledList.Item label="Fault Status" color={areaFault.color}>
              {areaFault.areaFaultText}
            </LabeledList.Item>
            <LabeledList.Item
              label="Fault Location"
              color={data.faultLocation ? 'blue' : 'good'}
            >
              {data.faultLocation || 'None'}
            </LabeledList.Item>
          </>
        )}
        {!!data.emagged && (
          <LabeledList.Item label="Warning" color="bad">
            Safety measures offline. Device may exhibit abnormal behavior.
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}
