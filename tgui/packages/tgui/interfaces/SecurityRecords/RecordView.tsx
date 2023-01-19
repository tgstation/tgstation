import { useBackend, useLocalState } from 'tgui/backend';
import { NoticeBox, Stack, Section, Button, Dropdown, Table, LabeledList, Input } from 'tgui/components';
import { logger } from '../../logging';
import { CharacterPreview } from '../PreferencesMenu/CharacterPreview';
import { CRIMESTATUS2COLOR } from './constants';
import { CrimeWatcher } from './CrimeWatcher';
import { getCurrentRecord } from './helpers';
import { RecordPrint } from './RecordPrint';
import { SecureData } from './types';

/** Views a selected record. */
export const RecordView = (props, context) => {
  const foundRecord = getCurrentRecord(context);
  if (!foundRecord) return <NoticeBox>Nothing selected.</NoticeBox>;

  const { act, data } = useBackend<SecureData>(context);
  const { available_statuses } = data;
  const [open, setOpen] = useLocalState<boolean>(context, 'printOpen', false);
  logger.log(available_statuses);

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

  /** Sets the note */
  const setNote = (event, value) => {
    if (value === note) return;
    act('set_note', { note: value, ref: ref });
  };

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
              <Stack>
                <Stack.Item>
                  <Button
                    height="1.7rem"
                    icon="print"
                    onClick={() => setOpen(true)}>
                    Print
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Dropdown
                    height="1.7rem"
                    onSelected={(value) =>
                      act('set_wanted', { ref: ref, status: value })
                    }
                    options={available_statuses}
                    selected={wanted_status}
                    width="10rem"
                  />
                </Stack.Item>
              </Stack>
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
              <LabeledList.Item label="Job">{rank}</LabeledList.Item>
              <LabeledList.Item label="Age">{age}</LabeledList.Item>
              <LabeledList.Item label="Species">{species}</LabeledList.Item>
              <LabeledList.Item label="Gender">{gender}</LabeledList.Item>
              <LabeledList.Item color="good" label="Fingerprint">
                {fingerprint}
              </LabeledList.Item>
              <LabeledList.Item label="Notes">
                <Input
                  onEnter={setNote}
                  placeholder={note ?? 'No notes. Click to add.'}
                  value={note}
                  width="85%"
                />
                <Button
                  disabled={!note}
                  icon="trash"
                  ml={1}
                  onClick={(event) => setNote(event, '')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
};
