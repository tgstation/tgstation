import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { LabeledListItem } from '../components/LabeledList';

export const BankMachine = props => {
  const { act, data } = useBackend(props);
  const {
    current_balance,
    siphoning,
    station_name,
  } = data;
  return (
    <Section title={station_name + 'Vault'}>
      <LabeledList>
        <LabeledList.Item label="Current Balance">
          {current_balance}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
