import { useBackend } from 'tgui/backend';
import { Button, Icon, Section, Stack, Table } from 'tgui/components';
import { CrewRecord, Data } from '../types';

/** Todo: Remove this entirely when records get a TGUI interface themselves */
export const RecordsDisplay = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { record_type } = props;
  const { records = [], refresh_spam } = data;
  const convertedRecords: CrewRecord = records[record_type];

  return (
    <Section
      title="Name"
      buttons={
        <Stack>
          <Stack.Item>
            <Button
              disabled={refresh_spam}
              onClick={() => act('refresh', { list: record_type })}
              tooltip="Refresh">
              <Icon mr={-0.7} name="sync" spin={refresh_spam} />
            </Button>
          </Stack.Item>
          <Stack.Item>
            <RecordLabels record_type={record_type} />
          </Stack.Item>
        </Stack>
      }
      fill
      scrollable>
      <Table>
        {convertedRecords?.map((record, index) => {
          return <RecordRow key={index} record={record} />;
        })}
      </Table>
    </Section>
  );
};

/** Renders the labels for the record viewer */
const RecordLabels = (props) => {
  const { record_type } = props;

  return (
    <Table>
      <Table.Row>
        <Table.Cell>
          {record_type === 'medical' ? 'Physical Health' : 'Arrest Status'}
        </Table.Cell>
        <Table.Cell>
          {record_type === 'medical' ? 'Mental Health' : 'Total Crimes'}
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};

const RecordRow = (props) => {
  const { record = [] } = props;
  const convertedRecord = Object.values(record);
  /** I do not want to show the ref here */
  const filteredRecord = convertedRecord.splice(1);

  return (
    <Table.Row className="candystripe">
      {filteredRecord?.map((value, index) => {
        return <Table.Cell key={index}>{value}</Table.Cell>;
      })}
    </Table.Row>
  );
};
