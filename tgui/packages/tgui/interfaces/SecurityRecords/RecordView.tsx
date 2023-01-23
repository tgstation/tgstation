import { useBackend, useLocalState } from 'tgui/backend';
import { NoticeBox, Stack, Section, Button, Table, LabeledList, Box, RestrictedInput } from 'tgui/components';
import { CharacterPreview } from '../common/CharacterPreview';
import { EditableText } from '../common/EditableText';
import { CRIMESTATUS2COLOR, CRIMESTATUS2DESC } from './constants';
import { CrimeWatcher } from './CrimeWatcher';
import { getSecurityRecord } from './helpers';
import { RecordPrint } from './RecordPrint';
import { SecureData } from './types';

/** Views a selected record. */
export const SecurityRecordView = (props, context) => {
  const foundRecord = getSecurityRecord(context);
  if (!foundRecord) return <NoticeBox>Nothing selected.</NoticeBox>;

  const { act, data } = useBackend<SecureData>(context);
  const { available_statuses } = data;
  const [open, setOpen] = useLocalState<boolean>(context, 'printOpen', false);

  const {
    age,
    appearance,
    fingerprint,
    gender,
    name,
    note,
    rank,
    ref,
    species,
    wanted_status,
  } = foundRecord;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <CharacterPreview height="100%" id={appearance} />
          </Stack.Item>
          <Stack.Item grow>
            <CrimeWatcher />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        {open ? (
          <RecordPrint />
        ) : (
          <Section
            buttons={
              <>
                <Button
                  height="1.7rem"
                  icon="print"
                  onClick={() => setOpen(true)}
                  tooltip="Print a rapsheet or poster.">
                  Print
                </Button>
                <Button.Confirm
                  content="Delete"
                  icon="trash"
                  onClick={() => act('expunge_record', { crew_ref: ref })}
                  tooltip="Expunge record data."
                />
              </>
            }
            fill
            scrollable
            title={
              <Table.Cell color={CRIMESTATUS2COLOR[wanted_status]}>
                {name}
              </Table.Cell>
            }
            wrap>
            <LabeledList>
              <LabeledList.Item label="Job">
                <EditableText field="rank" target_ref={ref} text={rank} />
              </LabeledList.Item>
              <LabeledList.Item label="Age">
                <RestrictedInput
                  minValue={18}
                  maxValue={100}
                  onEnter={(event, value) =>
                    act('edit_field', {
                      field: 'age',
                      ref: ref,
                      value: value,
                    })
                  }
                  value={age}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Species">
                <EditableText field="species" target_ref={ref} text={species} />
              </LabeledList.Item>
              <LabeledList.Item label="Gender">
                <EditableText field="gender" target_ref={ref} text={gender} />
              </LabeledList.Item>
              <LabeledList.Item color="good" label="Fingerprint">
                <EditableText
                  field="fingerprint"
                  target_ref={ref}
                  text={fingerprint}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Notes">
                <EditableText field="note" target_ref={ref} text={note} />
              </LabeledList.Item>
              <LabeledList.Item
                buttons={available_statuses.map((button, index) => {
                  const isSelected = button === wanted_status;
                  return (
                    <Button
                      key={index}
                      icon={isSelected ? 'check' : ''}
                      color={isSelected ? CRIMESTATUS2COLOR[button] : 'grey'}
                      onClick={() =>
                        act('set_wanted', { ref: ref, status: button })
                      }
                      pl={!isSelected ? '1.8rem' : 1}
                      tooltip={CRIMESTATUS2DESC[button] || ''}
                      tooltipPosition="bottom-start">
                      {button[0]}
                    </Button>
                  );
                })}
                label="Status">
                <Box color={CRIMESTATUS2COLOR[wanted_status]}>
                  {wanted_status}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
};
