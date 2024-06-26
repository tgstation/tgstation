import {
  Input,
  Box,
  Stack,
  Section,
  NoticeBox,
  LabeledList,
  Button,
} from 'tgui/components';
import { getMedicalRecord } from './helpers';
import { useBackend, useLocalState } from '../../backend';
import { MedicalRecordData } from './types';

/** Views a selected record. */
export const MedicalRecordView = (props) => {
  const foundRecord = getMedicalRecord();
  if (!foundRecord) return <NoticeBox>No record selected.</NoticeBox>;

  const { act, data } = useBackend<MedicalRecordData>();
  const { assigned_view, station_z } = data;

  const {
    crew_ref,
    id,
    sub,
    child,
    form,
    name,
    nickname,
    description,
    antigen,
    spread_flags,
    danger,
  } = foundRecord;
  const textHtml = {
    __html: description,
  };
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          buttons={
            <Button.Confirm
              content="Delete"
              icon="trash"
              disabled={!station_z}
              onClick={() => act('expunge_record', { crew_ref: crew_ref })}
              tooltip="Expunge record data."
            />
          }
          fill
          scrollable
          title={name}
          wrap
        >
          <LabeledList>
            <LabeledList.Item label="Name">
              <EditableText
                field="nickname"
                target_ref={crew_ref}
                text={nickname}
              />
            </LabeledList.Item>
            <LabeledList.Item label="ID">
              {id}-{sub}-{child}
            </LabeledList.Item>
            <LabeledList.Item label="Form">{form}</LabeledList.Item>
            <LabeledList.Item label="Spread Forms">
              {spread_flags}
            </LabeledList.Item>
            <LabeledList.Item label="Antigens">{antigen}</LabeledList.Item>
            <LabeledList.Item label="Danger Level">
              <EditableText
                field="danger"
                target_ref={crew_ref}
                text={danger}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Description">
              <Box dangerouslySetInnerHTML={textHtml} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type Props = {
  color?: string;
  field: string;
  target_ref: string;
  text: string;
};

const EditableText = (props: Props) => {
  const { color, field, target_ref, text } = props;
  if (!field) return <> </>;

  const { act } = useBackend();
  const [editing, setEditing] = useLocalState<boolean>(
    `editing_${field}`,
    false,
  );

  return editing ? (
    <Input
      autoFocus
      autoSelect
      width="50%"
      maxLength={512}
      onEscape={() => setEditing(false)}
      onEnter={(event, value) => {
        setEditing(false);
        act('edit_field', { field: field, crew_ref: target_ref, value: value });
      }}
      value={text}
    />
  ) : (
    <Stack>
      <Stack.Item>
        <Box
          as="span"
          color={!text ? 'grey' : color || 'white'}
          style={{
            'text-decoration': 'underline',
            'text-decoration-color': 'white',
            'text-decoration-thickness': '1px',
            'text-underline-offset': '1px',
          }}
          onClick={() => setEditing(true)}
        >
          {!text ? '(none)' : text}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          color="transparent"
          icon="backspace"
          ml={1}
          onClick={() =>
            act('edit_field', { field: field, ref: target_ref, value: '' })
          }
          tooltip="Clear"
          tooltipPosition="bottom"
        />
      </Stack.Item>
    </Stack>
  );
};
