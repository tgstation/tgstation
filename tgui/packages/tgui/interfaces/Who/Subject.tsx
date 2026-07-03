import { useCopyToClipboard } from '@uidotdev/usehooks';
import { useState } from 'react';
import {
  Button,
  LabeledList,
  Modal,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { getConditionColor, numberToDays } from './helpers';
import { ShowPing } from './Ping';
import type { WhoData } from './types';

export function Subject(props) {
  const { act, data } = useBackend<WhoData>();
  const { subject } = data;
  const { subjectRef, setSubjectRef } = props;
  const [showCkey, setShowCkey] = useState(false);

  return (
    <Modal p={1} style={{ width: '80vw' }}>
      <Section
        title={showCkey ? subject?.ckey : subject?.key}
        buttons={
          <Stack align="center">
            <Stack.Item mr={1}>
              <ShowPing user={subject} />
            </Stack.Item>
            <Stack.Item>
              <Button
                tooltip={showCkey ? 'Показать CKEY' : 'Показать KEY'}
                icon={'eye'}
                selected={showCkey}
                onClick={() => setShowCkey(!showCkey)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="red"
                icon="times"
                onClick={() => {
                  act('hide_more_info');
                  setSubjectRef(null);
                }}
              />
            </Stack.Item>
          </Stack>
        }
      >
        <SubjectInfoList subject={subject} />
      </Section>
      <Section>
        <SubjectInfoActions subjectRef={subjectRef} />
      </Section>
    </Modal>
  );
}

function SubjectInfoList(props) {
  const { subject } = props;
  const [showSpoiler, setShowSpoiler] = useState(false);
  const [copiedText, copyToClipboard] = useCopyToClipboard();
  const localHost = '127.0.0.1';

  return (
    <Stack vertical>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Имя (Настоящее)">
            {subject.name?.real || 'N/A'}
          </LabeledList.Item>
          <LabeledList.Item label="Имя (Разум)">
            {subject.name?.mind || 'N/A'}
          </LabeledList.Item>
          <LabeledList.Item label="Роль">
            {subject.role?.assigned || 'N/A'}
          </LabeledList.Item>
          <LabeledList.Item label="Антагонист">
            {subject.role?.antagonist?.join(', ') || 'Нет'}
          </LabeledList.Item>
          <LabeledList.Item label="Тип моба">{subject.type}</LabeledList.Item>
          <LabeledList.Item label="Пол">
            {toTitleCase(subject.gender)}
          </LabeledList.Item>
          <LabeledList.Item
            label="Состояние"
            color={getConditionColor(subject.state)}
          >
            {subject.state}
          </LabeledList.Item>
          <LabeledList.Item label="Повреждения">
            <Stack>
              <Tooltip content="Механические">
                <Stack.Item color="red">
                  {Math.round(subject.health?.brute) || 'N/A'}
                </Stack.Item>
              </Tooltip>
              <Stack.Divider />
              <Tooltip content="Ожоги">
                <Stack.Item color="orange">
                  {Math.round(subject.health?.burn) || 'N/A'}
                </Stack.Item>
              </Tooltip>
              <Stack.Divider />
              <Tooltip content="Отравление">
                <Stack.Item color="green">
                  {Math.round(subject.health?.toxin) || 'N/A'}
                </Stack.Item>
              </Tooltip>
              <Stack.Divider />
              <Tooltip content="Кислород">
                <Stack.Item color="blue">
                  {Math.round(subject.health?.oxygen) || 'N/A'}
                </Stack.Item>
              </Tooltip>
              <Stack.Divider />
              <Tooltip content="Мозг">
                <Stack.Item color="pink">
                  {Math.round(subject.health?.brain) || 'N/A'}
                </Stack.Item>
              </Tooltip>
              <Stack.Divider />
              <Tooltip content="Стамина">
                <Stack.Item color="yellow">
                  {Math.round(subject.health?.stamina) || 'N/A'}
                </Stack.Item>
              </Tooltip>
            </Stack>
          </LabeledList.Item>
          <LabeledList.Item label="Локация">
            {toTitleCase(subject.location?.area) || 'Неизвестно'}
          </LabeledList.Item>
          <LabeledList.Item label="Местоположение">
            <Stack>
              <Stack.Item>X: {subject.location?.x || 'N/A'}</Stack.Item>
              <Stack.Divider />
              <Stack.Item>Y: {subject.location?.y || 'N/A'}</Stack.Item>
              <Stack.Divider />
              <Stack.Item>Z: {subject.location?.z || 'N/A'}</Stack.Item>
            </Stack>
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item
            label="IP пользователя"
            buttons={
              <Button
                icon="copy"
                tooltip="Скопировать IP"
                tooltipPosition="top-end"
                onClick={() => copyToClipboard(subject.accountIp || localHost)}
              />
            }
          >
            <span
              className={classes([
                'Who_Spoiler',
                showSpoiler && 'Who_Spoiler--visible',
              ])}
              onClick={() => setShowSpoiler(!showSpoiler)}
            >
              {subject.accountIp || localHost}
            </span>
          </LabeledList.Item>
          <LabeledList.Item label="Возраст аккаунта">
            {numberToDays(subject.accountAge)}
          </LabeledList.Item>
          <LabeledList.Item label="Версия Byond">
            {subject.byondVersion}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
}

function SubjectInfoActions(props) {
  const { act } = useBackend();
  const { subjectRef } = props;

  return (
    <Stack fill textAlign="center">
      <Stack.Item grow>
        <Button fluid onClick={() => act('player_panel', { ref: subjectRef })}>
          Player Panel
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button fluid onClick={() => act('traitor_panel', { ref: subjectRef })}>
          Traitor Panel
        </Button>
      </Stack.Item>
      <Stack.Item
        grow
        onClick={() => act('view_variables', { ref: subjectRef })}
      >
        <Button fluid>Variables</Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          color="purple"
          icon="phone"
          tooltip="Голос в голове"
          onClick={() => act('subtlepm', { ref: subjectRef })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="red"
          icon="hand-fist"
          tooltip="Наказать"
          onClick={() => act('smite', { ref: subjectRef })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="blue"
          icon="scroll"
          tooltip="Логи"
          onClick={() => act('logs', { ref: subjectRef })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="grey"
          icon="ghost"
          tooltip="Наблюдать"
          onClick={() => act('follow', { ref: subjectRef })}
        />
      </Stack.Item>
    </Stack>
  );
}
