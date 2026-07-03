import { useState } from 'react';
import { useBackend, useLocalState } from 'tgui/backend';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Tabs,
  TextArea,
  Tooltip,
} from 'tgui-core/components';

import { getSecurityRecord } from './helpers';
import { type Crime, SECURETAB, type SecurityRecordsData } from './types';

/** Displays a list of crimes and allows to add new ones. */
export const CrimeWatcher = (props) => {
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;
  const { crimes, citations } = foundRecord;
  const [selectedTab, setSelectedTab] = useLocalState<SECURETAB>(
    'selectedTab',
    SECURETAB.Crimes,
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid>
          <Tabs.Tab
            onClick={() => setSelectedTab(SECURETAB.Crimes)}
            selected={selectedTab === SECURETAB.Crimes}
          >
            Преступления: {crimes.length}
          </Tabs.Tab>
          <Tabs.Tab
            onClick={() => setSelectedTab(SECURETAB.Citations)}
            selected={selectedTab === SECURETAB.Citations}
          >
            Штрафы: {citations.length}
          </Tabs.Tab>
          <Tooltip content="Новое преступление или штраф" position="bottom">
            <Tabs.Tab
              onClick={() => setSelectedTab(SECURETAB.Add)}
              selected={selectedTab === SECURETAB.Add}
            >
              <Icon name="plus" />
            </Tabs.Tab>
          </Tooltip>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {selectedTab < SECURETAB.Add ? (
            <CrimeList tab={selectedTab} />
          ) : (
            <CrimeAuthor />
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Displays the crimes and citations of a record. */
const CrimeList = (props) => {
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;

  const { citations, crimes } = foundRecord;
  const { tab } = props;
  const toDisplay = tab === SECURETAB.Crimes ? crimes : citations;

  return (
    <Stack fill vertical>
      {!toDisplay.length ? (
        <Stack.Item>
          <NoticeBox>
            Не найдены {tab === SECURETAB.Crimes ? 'преступления' : 'штрафы'}.
          </NoticeBox>
        </Stack.Item>
      ) : (
        toDisplay.map((item, index) => <CrimeDisplay key={index} item={item} />)
      )}
    </Stack>
  );
};

/** Displays an individual crime */
const CrimeDisplay = ({ item }: { item: Crime }) => {
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;

  const { crew_ref } = foundRecord;
  const { act, data } = useBackend<SecurityRecordsData>();
  const { current_user, higher_access } = data;
  const { author, crime_ref, details, fine, name, paid, time, valid, voider } =
    item;
  const showFine = !!fine && fine > 0 ? `: ${fine} кр` : ': ШТРАФ ОПЛАЧЕН';

  let collapsibleColor = '';
  if (!valid) {
    collapsibleColor = 'grey';
  } else if (fine && fine > 0) {
    collapsibleColor = 'average';
  }

  let displayTitle = name;
  if (fine !== undefined) {
    displayTitle = name.slice(0, 18) + showFine;
  }

  const [editing, setEditing] = useLocalState(`editing_${crime_ref}`, false);

  return (
    <Stack.Item>
      <Collapsible color={collapsibleColor} open={editing} title={displayTitle}>
        <LabeledList>
          <LabeledList.Item label="Время">{time}</LabeledList.Item>
          <LabeledList.Item label="Автор">{author}</LabeledList.Item>
          <LabeledList.Item color={!valid ? 'bad' : 'good'} label="Статус">
            {!valid ? 'Аннулировано' : 'Активно'}
          </LabeledList.Item>
          {!valid && (
            <LabeledList.Item
              color={voider ? 'gold' : 'good'}
              label="Аннулировано"
            >
              {!voider ? 'Автоматически' : voider}
            </LabeledList.Item>
          )}
          {!!fine && fine > 0 && (
            <>
              <LabeledList.Item color="bad" label="Fine">
                {fine}кр <Icon color="gold" name="coins" />
              </LabeledList.Item>
              <LabeledList.Item color="good" label="Paid">
                {paid}кр <Icon color="gold" name="coins" />
              </LabeledList.Item>
            </>
          )}
        </LabeledList>
        <Box color="label" mt={1} mb={1}>
          Детали:
        </Box>
        <BlockQuote>{details}</BlockQuote>

        {!editing ? (
          <Box mt={2}>
            <Button
              disabled={!valid || (!higher_access && author !== current_user)}
              icon="pen"
              onClick={() => setEditing(true)}
            >
              Изменить
            </Button>
            <Button.Confirm
              content="Аннулировать"
              disabled={!valid || (!higher_access && author !== current_user)}
              icon="ban"
              onClick={() =>
                act('invalidate_crime', {
                  crew_ref: crew_ref,
                  crime_ref: crime_ref,
                })
              }
            />
          </Box>
        ) : (
          <>
            <Input
              fluid
              maxLength={25}
              onEscape={() => setEditing(false)}
              onEnter={(value) => {
                setEditing(false);
                act('edit_crime', {
                  crew_ref: crew_ref,
                  crime_ref: crime_ref,
                  name: value,
                });
              }}
              placeholder="Введите новое имя"
            />
            <Input
              fluid
              maxLength={1025}
              mt={1}
              onEscape={() => setEditing(false)}
              onEnter={(value) => {
                setEditing(false);
                act('edit_crime', {
                  crew_ref: crew_ref,
                  crime_ref: crime_ref,
                  description: value,
                });
              }}
              placeholder="Введите новое описание"
            />
          </>
        )}
      </Collapsible>
    </Stack.Item>
  );
};

/** Writes a new crime. Reducers don't seem to work here, so... */
const CrimeAuthor = (props) => {
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return;

  const { crew_ref } = foundRecord;
  const { act } = useBackend<SecurityRecordsData>();

  const [crimeName, setCrimeName] = useState('');
  const [crimeDetails, setCrimeDetails] = useState('');
  const [crimeFine, setCrimeFine] = useState(0);
  const [selectedTab, setSelectedTab] = useLocalState<SECURETAB>(
    'selectedTab',
    SECURETAB.Crimes,
  );
  const [crimeFineIsValid, setCrimeFineIsValid] = useState(true);

  const nameMeetsReqs = crimeName?.length > 2;

  /** Sends form to backend */
  const createCrime = () => {
    if (!crimeName || !crimeFineIsValid) return;
    act('add_crime', {
      crew_ref: crew_ref,
      details: crimeDetails,
      fine: crimeFine,
      name: crimeName,
    });
    reset();
  };

  /** Resets form data since it persists.. */
  const reset = () => {
    setCrimeDetails('');
    setCrimeFine(0);
    setCrimeName('');
    setSelectedTab(crimeFine ? SECURETAB.Citations : SECURETAB.Crimes);
  };

  return (
    <Stack fill vertical>
      <Stack.Item color="label">
        Имя
        <Input
          fluid
          maxLength={25}
          onChange={setCrimeName}
          placeholder="Краткое описание"
        />
      </Stack.Item>
      <Stack.Item color="label">
        Детали
        <TextArea
          fluid
          height={4}
          maxLength={1025}
          onChange={setCrimeDetails}
          placeholder="Напишите детали..."
        />
      </Stack.Item>
      <Stack.Item color="label">
        Штраф (оставьте пустым для ареста)
        <RestrictedInput
          fluid
          value={crimeFine}
          maxValue={1000}
          onChange={setCrimeFine}
          onValidationChange={setCrimeFineIsValid}
        />
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          disabled={!nameMeetsReqs || !crimeFineIsValid}
          icon="plus"
          onClick={createCrime}
          tooltip={!nameMeetsReqs ? 'Имя состоит из менее 3-х символов.' : ''}
        >
          Создать
        </Button.Confirm>
      </Stack.Item>
    </Stack>
  );
};
