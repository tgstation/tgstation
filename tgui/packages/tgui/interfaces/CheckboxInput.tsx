import { createSearch, decodeHtmlEntities } from 'common/string';

import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type Data = {
  items: string[];
  message: string;
  title: string;
  timeout: number;
  min_checked: number;
  max_checked: number;
};

/** Renders a list of checkboxes per items for input. */
export const CheckboxInput = (props) => {
  const { data } = useBackend<Data>();
  const {
    items = [],
    min_checked,
    max_checked,
    message,
    timeout,
    title,
  } = data;

  const [selections, setSelections] = useLocalState<string[]>('selections', []);

  const [searchQuery, setSearchQuery] = useLocalState<string>(
    'searchQuery',
    '',
  );
  const search = createSearch(searchQuery, (item: string) => item);
  const toDisplay = items.filter(search);

  const selectItem = (name: string) => {
    const newSelections = selections.includes(name)
      ? selections.filter((item) => item !== name)
      : [...selections, name];

    setSelections(newSelections);
  };

  return (
    <Window title={title} width={425} height={300}>
      {!!timeout && <Loader value={timeout} />}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox info textAlign="center">
              {decodeHtmlEntities(message)}{' '}
              {min_checked > 0 && ` (Min: ${min_checked})`}
              {max_checked < 50 && ` (Max: ${max_checked})`}
            </NoticeBox>
          </Stack.Item>
          <Stack.Item grow mt={0}>
            <Section fill scrollable>
              <Table>
                {toDisplay.map((item, index) => (
                  <TableRow className="candystripe" key={index}>
                    <TableCell>
                      <Button.Checkbox
                        checked={selections.includes(item)}
                        disabled={
                          selections.length >= max_checked &&
                          !selections.includes(item)
                        }
                        fluid
                        onClick={() => selectItem(item)}
                      >
                        {item}
                      </Button.Checkbox>
                    </TableCell>
                  </TableRow>
                ))}
              </Table>
            </Section>
          </Stack.Item>
          <Stack m={1} mb={0}>
            <Stack.Item>
              <Tooltip content="Search" position="bottom">
                <Icon name="search" mt={0.5} />
              </Tooltip>
            </Stack.Item>
            <Stack.Item grow>
              <Input
                fluid
                value={searchQuery}
                onInput={(_, value) => setSearchQuery(value)}
              />
            </Stack.Item>
          </Stack>
          <Stack.Item mt={0.7}>
            <Section>
              <InputButtons input={selections} />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
