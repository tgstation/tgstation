import {
  Blink,
  Button,
  Modal,
  NumberInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { useBackend, useSharedState } from '../../backend';
import { getRandomDoomMessage } from './helpers';
import { SortButton } from './Sort';
import { type Data, SORTING } from './types';

export const UsersScreen = () => {
  const { act, data } = useBackend<Data>();
  const { crashing, accounts, max_pay_mod, min_pay_mod, max_advances } = data;

  const [accountNameSorting, setAccountNameSorting] = useSharedState(
    'sorting_account_name',
    SORTING.ascending,
  );
  const [balanceSorting, setBalanceSorting] = useSharedState(
    'sorting_balance',
    SORTING.none,
  );
  const [jobSorting, setJobSorting] = useSharedState(
    'sorting_job',
    SORTING.none,
  );

  const accountsSorted = accounts.sort((a, b) => {
    if (accountNameSorting === SORTING.ascending) {
      return a.name > b.name ? 1 : -1;
    } else if (accountNameSorting === SORTING.descending) {
      return a.name > b.name ? -1 : 1;
    } else if (balanceSorting === SORTING.ascending) {
      return a.balance - b.balance;
    } else if (balanceSorting === SORTING.descending) {
      return b.balance - a.balance;
    } else if (jobSorting === SORTING.ascending) {
      return a.job > b.job ? 1 : -1;
    } else if (jobSorting === SORTING.descending) {
      return a.job > b.job ? -1 : 1;
    }
    return 0;
  });

  return (
    <Section scrollable height="320px">
      {!!crashing && (
        <Modal width="300px" align="center">
          <Blink time={500} interval={500}>
            {getRandomDoomMessage()}
          </Blink>
        </Modal>
      )}
      <Table>
        <Table.Row>
          <Table.Cell bold>
            <Stack>
              <Stack.Item>Account</Stack.Item>
              <Stack.Item>
                <SortButton
                  sorting={accountNameSorting}
                  setSorting={setAccountNameSorting}
                  otherSorters={[setBalanceSorting, setJobSorting]}
                />
              </Stack.Item>
            </Stack>
          </Table.Cell>
          <Table.Cell bold>
            <Stack>
              <Stack.Item>Balance</Stack.Item>
              <Stack.Item>
                <SortButton
                  sorting={balanceSorting}
                  setSorting={setBalanceSorting}
                  otherSorters={[setAccountNameSorting, setJobSorting]}
                />
              </Stack.Item>
            </Stack>
          </Table.Cell>
          <Table.Cell bold>
            <Stack>
              <Stack.Item>Job</Stack.Item>
              <Stack.Item>
                <SortButton
                  sorting={jobSorting}
                  setSorting={setJobSorting}
                  otherSorters={[setAccountNameSorting, setBalanceSorting]}
                />
              </Stack.Item>
            </Stack>
          </Table.Cell>
          <Table.Cell bold>Pay</Table.Cell>
          <Table.Cell bold>Advances</Table.Cell>
        </Table.Row>
        {accountsSorted.map((account, index) => (
          <Table.Row
            key={`account_${account.id}_${index}`}
            className="Accounting__TableHeader"
          >
            <Table.Cell>{account.name}</Table.Cell>
            <Table.Cell className="Accounting__TableCellSides">
              {account.balance} cr
            </Table.Cell>
            <Table.Cell className="Accounting__TableCellSides">
              {account.job}
            </Table.Cell>
            <Table.Cell className="Accounting__TableCellSides">
              <NumberInput
                value={account.modifier}
                minValue={min_pay_mod}
                maxValue={max_pay_mod}
                step={0.05}
                onChange={(value) =>
                  act('change_pay_mod', {
                    account_id: account.id,
                    pay_mod: value,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell className="Accounting__TableCellSides">
              <Stack>
                <Stack.Item>{account.num_advances}</Stack.Item>
                <Stack.Item>
                  <Button
                    ml={2}
                    height="12px"
                    width="12px"
                    fontSize="8px"
                    disabled={account.num_advances >= max_advances}
                    onClick={() =>
                      act('paycheck_advance', {
                        account_id: account.id,
                      })
                    }
                  >
                    +
                  </Button>
                </Stack.Item>
              </Stack>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
