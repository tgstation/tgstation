import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

export const NtosCitation = (props) => {
  const { act, data } = useBackend();
  const {
    crew = [],
    max_fine,
    money_symbol,
    max_crime_name_len,
    max_details_len,
    default_deadline_minutes,
    max_deadline_minutes,
    paper_left,
  } = data;

  const [targetName, setTargetName] = useState('');
  const [crimeName, setCrimeName] = useState('');
  const [details, setDetails] = useState('');
  const [fine, setFine] = useState(50);
  const [deadlineMinutes, setDeadlineMinutes] = useState(
    default_deadline_minutes || 15,
  );

  const crewOptions = crew.map(
    (entry) => `${entry.name} (${entry.rank})`,
  );
  const crewLookup = Object.fromEntries(
    crew.map((entry) => [`${entry.name} (${entry.rank})`, entry.name]),
  );

  const outOfPaper = paper_left <= 0;
  const canSubmit =
    !outOfPaper &&
    !!targetName &&
    crimeName.trim().length > 0 &&
    fine > 0 &&
    fine <= max_fine &&
    deadlineMinutes > 0;

  const submit = () => {
    if (!canSubmit) {
      return;
    }
    act('issue_citation', {
      target_name: targetName,
      crime_name: crimeName.trim(),
      details: details.trim(),
      fine: fine,
      deadline_minutes: deadlineMinutes,
    });
    setCrimeName('');
    setDetails('');
  };

  return (
    <NtosWindow width={460} height={540}>
      <NtosWindow.Content scrollable>
        <Section title="Issue Security Citation">
          {outOfPaper && (
            <NoticeBox danger>
              The printer is out of paper. Refill before issuing further
              citations.
            </NoticeBox>
          )}
          <LabeledList>
            <LabeledList.Item label="Target">
              <Dropdown
                width="100%"
                options={crewOptions}
                selected={
                  crewOptions.find((opt) => crewLookup[opt] === targetName) ||
                  ''
                }
                placeholder="Select crewmember…"
                onSelected={(value) => setTargetName(crewLookup[value] || '')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Offense">
              <Input
                fluid
                value={crimeName}
                maxLength={max_crime_name_len}
                placeholder="e.g. Trespassing, Assault, Vandalism…"
                onChange={(value) => setCrimeName(value)}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Details">
              <TextArea
                height="6em"
                value={details}
                maxLength={max_details_len}
                placeholder="Optional. Note circumstances, witnesses, recovered items…"
                onChange={(value) => setDetails(value)}
              />
            </LabeledList.Item>
            <LabeledList.Item label={`Fine (${money_symbol})`}>
              <NumberInput
                value={fine}
                minValue={1}
                maxValue={max_fine}
                step={10}
                stepPixelSize={5}
                width="6em"
                onChange={(value) => setFine(value)}
              />
              <Box inline ml={1} color="label">
                max {max_fine}
                {money_symbol}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Pay window">
              <NumberInput
                value={deadlineMinutes}
                minValue={1}
                maxValue={max_deadline_minutes}
                step={1}
                stepPixelSize={5}
                width="6em"
                unit="min"
                onChange={(value) => setDeadlineMinutes(value)}
              />
              <Box inline ml={1} color="label">
                default {default_deadline_minutes} min
              </Box>
            </LabeledList.Item>
          </LabeledList>
          <Box mt={2}>
            <Button
              icon="gavel"
              fluid
              lineHeight={2.5}
              textAlign="center"
              disabled={!canSubmit}
              tooltip={
                outOfPaper
                  ? 'Out of paper.'
                  : !targetName
                    ? 'Select a target from the manifest.'
                    : crimeName.trim().length === 0
                      ? 'Enter the offense name.'
                      : `Issue and print a ${fine}${money_symbol} citation.`
              }
              onClick={submit}
            >
              Issue & Print Ticket
            </Button>
          </Box>
          <Box mt={1} color="label" textAlign="right">
            Paper remaining: {paper_left}
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
