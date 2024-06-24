import { LabeledList, NoticeBox } from '../../components';
import { Antagonist, Observable } from './types';

type Props = {
  item: Observable | Antagonist;
};

/** Displays some info on the mob as a tooltip. */
export function OrbitTooltip(props: Props) {
  const { item } = props;
  const { extra, full_name, health, job } = item;

  let antag;
  if ('antag' in item) {
    antag = item.antag;
  }

  const extraInfo = extra?.split(':');
  const displayHealth = !!health && health >= 0 ? `${health}%` : 'Critical';
  const showAFK = 'client' in item && !item.client;

  return (
    <>
      <NoticeBox textAlign="center" nowrap info={showAFK}>
        Last Known Data
      </NoticeBox>
      <LabeledList>
        {extraInfo ? (
          <LabeledList.Item label={extraInfo[0]}>
            {extraInfo[1]}
          </LabeledList.Item>
        ) : (
          <>
            {!!full_name && (
              <LabeledList.Item label="Real ID">{full_name}</LabeledList.Item>
            )}
            {!!job && !antag && (
              <LabeledList.Item label="Job">{job}</LabeledList.Item>
            )}
            {!!antag && (
              <LabeledList.Item label="Threat">{antag}</LabeledList.Item>
            )}
            {!!health && (
              <LabeledList.Item label="Health">
                {displayHealth}
              </LabeledList.Item>
            )}
          </>
        )}
        {showAFK && <LabeledList.Item label="Status">Away</LabeledList.Item>}
      </LabeledList>
    </>
  );
}
