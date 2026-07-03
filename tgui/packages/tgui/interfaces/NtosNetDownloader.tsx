import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { scale, toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  disk_size: number;
  disk_used: number;
  downloadcompletion: number;
  downloading: BooleanLike;
  downloadname: string;
  downloadsize: number;
  error: string;
  emagged: BooleanLike;
  categories: string[];
  programs: ProgramData[];
};

type ProgramData = {
  icon: string;
  filename: string;
  filedesc: string;
  fileinfo: string;
  category: string;
  installed: BooleanLike;
  compatible: BooleanLike;
  size: number;
  access: BooleanLike;
  verifiedsource: BooleanLike;
};

export const NtosNetDownloader = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    disk_size,
    disk_used,
    downloadcompletion,
    downloading,
    downloadname,
    downloadsize,
    error,
    emagged,
    categories = [],
    programs = [],
  } = data;
  const all_categories = categories;
  const downloadpercentage = toFixed(
    scale(downloadcompletion, 0, downloadsize) * 100,
  );
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);
  const [searchItem, setSearchItem] = useState('');
  const search = createSearch<ProgramData>(
    searchItem,
    (program) => program.filedesc,
  );
  let items =
    searchItem.length > 0
      ? // If we have a query, search everything for it.
        filter(programs, search)
      : // Otherwise, show respective programs for the category.
        filter(programs, (program) => program.category === selectedCategory);
  // This sorts all programs in the lists by name and compatibility
  items = sortBy(items, [
    (program: ProgramData) => !program.compatible,
    (program: ProgramData) => program.filedesc,
  ]);
  if (!emagged) {
    // This filters the list to only contain verified programs
    items = filter(items, (program) => program.verifiedsource === 1);
  }
  const disk_free_space = downloading
    ? disk_size - Number(toFixed(disk_used + downloadcompletion))
    : disk_size - disk_used;

  return (
    <NtosWindow width={600} height={600}>
      <NtosWindow.Content scrollable>
        {!!error && (
          <NoticeBox>
            <Box mb={1}>{error}</Box>
            <Button content="Reset" onClick={() => act('PRG_reseterror')} />
          </NoticeBox>
        )}
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Жесткий диск"
              buttons={
                (!!downloading && (
                  <Button
                    icon="spinner"
                    iconSpin={1}
                    tooltipPosition="left"
                    tooltip={
                      !!downloading &&
                      `Download: ${downloadname}.prg (${downloadpercentage}%)`
                    }
                  />
                )) ||
                (!!downloadname && (
                  <Button
                    color="good"
                    icon="download"
                    tooltipPosition="left"
                    tooltip={`${downloadname}.prg загружен`}
                  />
                ))
              }
            >
              <ProgressBar
                value={downloading ? disk_used + downloadcompletion : disk_used}
                minValue={0}
                maxValue={disk_size}
              >
                <Box textAlign="left">
                  {`${disk_free_space} GQ free of ${disk_size} GQ`}
                </Box>
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <Input
            autoFocus
            height="23px"
            placeholder="Найти программу..."
            fluid
            value={searchItem}
            onChange={setSearchItem}
          />
        </Section>
        <Stack>
          <Stack.Item minWidth="105px" shrink={0} basis={0}>
            <Tabs vertical>
              {categories.map((category) => (
                <Tabs.Tab
                  key={category}
                  selected={category === selectedCategory}
                  onClick={() => setSelectedCategory(category)}
                >
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow={1} basis={0}>
            {items?.map((program) => (
              <Program key={program.filename} program={program} />
            ))}
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const Program = (props) => {
  const { program } = props;
  const { act, data } = useBackend<Data>();
  const {
    disk_size,
    disk_used,
    downloading,
    downloadname,
    downloadcompletion,
    emagged,
  } = data;
  const disk_free = disk_size - disk_used;
  return (
    <Section>
      <Stack align="baseline">
        <Stack.Item grow bold>
          <Icon name={program.icon} mr={1} />
          {program.filedesc}
        </Stack.Item>
        <Stack.Item
          shrink={0}
          width="48px"
          textAlign="right"
          color="label"
          nowrap
        >
          {program.size} GQ
        </Stack.Item>
        <Stack.Item shrink={0} width="134px" textAlign="right">
          {(downloading && program.filename === downloadname && (
            <ProgressBar
              width="101px"
              height="23px"
              color="good"
              minValue={0}
              maxValue={program.size}
              value={downloadcompletion}
            />
          )) ||
            (!program.installed &&
              program.compatible &&
              program.access &&
              program.size < disk_free && (
                <Button
                  bold
                  icon="download"
                  content="Загрузить"
                  disabled={downloading}
                  tooltipPosition="left"
                  tooltip={!!downloading && 'Awaiting download completion...'}
                  onClick={() =>
                    act('PRG_downloadfile', {
                      filename: program.filename,
                    })
                  }
                />
              )) || (
              <Button
                bold
                icon={program.installed ? 'check' : 'times'}
                color={
                  program.installed
                    ? 'good'
                    : !program.compatible
                      ? 'bad'
                      : 'grey'
                }
                content={
                  program.installed
                    ? 'Установлено'
                    : !program.compatible
                      ? 'Несовместимо'
                      : !program.access
                        ? 'Нет доступа'
                        : 'Нет места'
                }
              />
            )}
        </Stack.Item>
      </Stack>
      <Box mt={1} italic color="label">
        {program.fileinfo}
      </Box>
      {!program.verifiedsource && (
        <NoticeBox mt={1} mb={0} danger fontSize="12px">
          Непроверенный источник. Обратите внимание, что Nanotrasen не
          рекомендует скачивать и использовать ПО с неофициальных серверов.
        </NoticeBox>
      )}
    </Section>
  );
};
