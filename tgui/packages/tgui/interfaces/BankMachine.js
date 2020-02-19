import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';

export const BankMachine = props => {
  const { act, data } = useBackend(props);
  const {
    current_balance,
    siphoning,
    station_name,
  } = data;
  return (
    <Fragment>
      <Section title={station_name + ' Vault'}>
        <LabeledList>
          <LabeledList.Item label="Current Balance"
            buttons={(
              <Button
                icon={siphoning ? 'times' : 'sync'}
                content={siphoning ? 'Stop Siphoning' : 'Siphon Credits'}
                selected={siphoning}
                onClick={() => act(siphoning ? 'halt' : 'siphon')} />
            )}>
            {current_balance + ' cr'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <NoticeBox textAlign="center">
        Authorized personnel only
      </NoticeBox>
    </Fragment>
  );
};
