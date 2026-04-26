import {
  Box,
  Button,
  Collapsible,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeAll, capitalizeFirst } from 'tgui-core/string';
import { useBackend, useSharedState } from '../../backend';
import { extractRequirementMap, extractSurgeryName } from './helpers';
import type { OperatingComputerData, OperationData } from './types';

type SurgeryRequirementsInnerProps = {
  cat_text: string;
  cat_contents: string[];
};

export const SurgeryRequirementsInner = (
  props: SurgeryRequirementsInnerProps,
) => {
  const { cat_text, cat_contents } = props;

  return (
    <Stack.Item>
      <Stack.Item italic pb={1}>
        {cat_text}
      </Stack.Item>
      <Stack.Item>
        <Stack vertical>
          {cat_contents.map((req, i) => (
            <Stack.Item key={i}>- {capitalizeFirst(req)}</Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
    </Stack.Item>
  );
};

type SurgeryProceduresViewProps = {
  searchedSurgeries: OperationData[];
  searchText: string;
  setSearchText: (text: string) => void;
  pinnedOperations: string[];
  setPinnedOperations: (text: string[]) => void;
};

export const SurgeryProceduresView = (props: SurgeryProceduresViewProps) => {
  const { data } = useBackend<OperatingComputerData>();
  const { surgeries } = data;
  const {
    searchedSurgeries,
    searchText,
    setSearchText,
    pinnedOperations,
    setPinnedOperations,
  } = props;
  const [sortType, setSortType] = useSharedState<'default' | 'name' | 'tool'>(
    'catalog_sort_type',
    'default',
  );
  const [filterRobotic, setFilterRobotic] = useSharedState(
    'catalog_filter',
    false,
  );
  const rawSurgeryList =
    searchedSurgeries.length > 0 ? searchedSurgeries : surgeries;

  const surgeryList = rawSurgeryList
    .filter((surgery) => surgery.show_in_list)
    .filter((surgery) => !filterRobotic || !surgery.mechanic)
    .filter(
      (surgery, index, self) =>
        index === self.findIndex((s) => s.name === surgery.name),
    );

  if (sortType === 'name') {
    surgeryList.sort((a, b) => (a.name > b.name ? 1 : -1));
  } else if (sortType === 'tool') {
    surgeryList.sort((a, b) => (a.tool_rec > b.tool_rec ? 1 : -1));
  }

  if (pinnedOperations.length > 0) {
    surgeryList.sort((a, b) => {
      if (
        pinnedOperations.includes(a.name) &&
        !pinnedOperations.includes(b.name)
      ) {
        return -1;
      }
      if (
        !pinnedOperations.includes(a.name) &&
        pinnedOperations.includes(b.name)
      ) {
        return 1;
      }
      return 0;
    });
  }

  return (
    <Section
      title="&nbsp;"
      scrollable
      fill
      buttons={
        <>
          <Input
            width="215px"
            placeholder="Search..."
            value={searchText}
            onChange={setSearchText}
          />
          <Button
            icon="filter"
            tooltip="Filter out robotic surgeries."
            onClick={() => setFilterRobotic(!filterRobotic)}
            selected={filterRobotic}
          >
            Hide Mechanic
          </Button>
          <Button
            width="75px"
            icon="sort"
            tooltip="Cycle between sorting methods."
            onClick={() =>
              setSortType(
                sortType === 'default'
                  ? 'name'
                  : sortType === 'name'
                    ? 'tool'
                    : 'default',
              )
            }
          >
            {capitalizeFirst(sortType)}
          </Button>
        </>
      }
    >
      {surgeryList.map((surgery) => {
        const { name, tool, true_name } = extractSurgeryName(surgery, true);

        return (
          <Stack vertical key={surgery.name} pb={2}>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <Button
                        icon="thumbtack"
                        tooltipPosition="top"
                        color={
                          pinnedOperations.includes(surgery.name)
                            ? 'danger'
                            : undefined
                        }
                        onClick={() =>
                          setPinnedOperations(
                            pinnedOperations.includes(surgery.name)
                              ? pinnedOperations.filter(
                                  (op) => op !== surgery.name,
                                )
                              : pinnedOperations.concat(surgery.name),
                          )
                        }
                      />
                    </Stack.Item>
                    <Stack.Item bold fontSize="1.2rem">
                      {name}
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                {!!true_name && (
                  <Stack.Item italic fontSize="0.9rem">
                    {`(${true_name})`}
                  </Stack.Item>
                )}
                <Stack.Item grow />
                <Stack.Item italic textAlign="right" fontSize="0.9rem">
                  {capitalizeAll(tool)}
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Box
                style={{
                  borderStyle: 'solid',
                  borderBottom: '0',
                  borderRight: '0',
                  borderWidth: '2px',
                  paddingTop: '2px',
                  paddingLeft: '4px',
                }}
                color="label"
              >
                <Stack vertical>
                  <Stack.Item bold>{surgery.desc}</Stack.Item>
                  <Stack.Item>
                    <Collapsible
                      title="Requirements"
                      open={pinnedOperations.includes(surgery.name)}
                    >
                      <Stack
                        pl={1}
                        ml={0.5}
                        style={{
                          borderStyle: 'dashed',
                          borderBottom: '0',
                          borderRight: '0',
                          borderTop: '0',
                          borderWidth: '2px',
                          flexDirection: 'column',
                        }}
                      >
                        {Object.entries(extractRequirementMap(surgery)).map(
                          ([cat_text, cat_contents], i) =>
                            cat_contents.length > 0 ? (
                              <SurgeryRequirementsInner
                                key={i}
                                cat_text={cat_text}
                                cat_contents={cat_contents}
                              />
                            ) : null,
                        )}
                      </Stack>
                    </Collapsible>
                  </Stack.Item>
                </Stack>
              </Box>
            </Stack.Item>
          </Stack>
        );
      })}
    </Section>
  );
};
