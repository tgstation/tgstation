import { useState } from 'react';
import {
  Blink,
  Box,
  Button,
  DmIcon,
  Flex,
  Modal,
  NumberInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  accounts: PlayerAccount[];
  audit_log: AuditLog[];
  crashing: BooleanLike;
  pic_file_format: string;
  max_pay_mod: number;
  min_pay_mod: number;
  max_advances: number;
  station_time: string;
  young_ian: BooleanLike;
};

type PlayerAccount = {
  id: number;
  name: string;
  balance: number;
  job: string;
  modifier: number;
  num_advances: number;
};

type AuditLog = {
  account: number;
  cost: number;
  vendor: string;
  stationtime: string;
};

enum SCREENS {
  none,
  users,
  audit,
  ian,
}

export const AccountingConsole = () => {
  const { data } = useBackend<Data>();
  const {
    station_time = '00:00',
    pic_file_format = 'png',
    young_ian = false,
  } = data;
  const [screenmode, setScreenmode] = useState(SCREENS.none);

  const ianFileName = young_ian
    ? `Ian's first birthday.${pic_file_format}`
    : `Ian.${pic_file_format}`;

  return (
    <Window width={600} height={440} theme="ntOS95">
      <Window.Content fontFamily="Tahoma">
        <Stack vertical fill>
          <Stack.Item>
            <Flex height="355px">
              <Flex.Item width="100px">
                <Stack mt={1} ml={2}>
                  <Stack.Item>
                    <Stack vertical align="center">
                      <FakeDesktopButton
                        name="paychecks.exe"
                        setScreenmode={setScreenmode}
                        ownerScreenMode={SCREENS.users}
                      >
                        <DmIcon
                          width="70px"
                          height="70px"
                          mt={1}
                          icon="icons/obj/card.dmi"
                          icon_state="budgetcard"
                        />
                      </FakeDesktopButton>
                      <FakeDesktopButton
                        name="audit.exe"
                        setScreenmode={setScreenmode}
                        ownerScreenMode={SCREENS.audit}
                      >
                        <DmIcon
                          width="70px"
                          height="70px"
                          mt={1}
                          icon="icons/obj/service/bureaucracy.dmi"
                          icon_state="docs_verified"
                        />
                      </FakeDesktopButton>
                      <FakeDesktopButton
                        name={ianFileName}
                        setScreenmode={setScreenmode}
                        ownerScreenMode={SCREENS.ian}
                      >
                        <DmIcon
                          width="70px"
                          height="70px"
                          mt={1}
                          icon="icons/mob/simple/pets.dmi"
                          icon_state={young_ian ? 'puppy' : 'corgi'}
                        />
                      </FakeDesktopButton>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Flex.Item>
              {screenmode === SCREENS.users && (
                <Flex.Item grow ml={3}>
                  <FakeWindow
                    name="Crew Account Summary"
                    setScreenmode={setScreenmode}
                  >
                    <UsersScreen />
                  </FakeWindow>
                </Flex.Item>
              )}
              {screenmode === SCREENS.audit && (
                <Flex.Item grow ml={3}>
                  <FakeWindow name="Audit Log" setScreenmode={setScreenmode}>
                    <AuditScreen />
                  </FakeWindow>
                </Flex.Item>
              )}
              {screenmode === SCREENS.ian && (
                <Flex.Item ml={10}>
                  <FakeWindowIan
                    name={ianFileName}
                    setScreenmode={setScreenmode}
                  />
                </Flex.Item>
              )}
            </Flex>
          </Stack.Item>
          <Stack.Item
            grow
            color="grey"
            backgroundColor="rgb(195, 195, 195)"
            mt={1}
            p={0.5}
            ml={-1}
            mr={-1}
            mb={-1}
          >
            <Flex>
              <Flex.Item mr={1}>
                <Button
                  disabled
                  icon="user"
                  p={0.75}
                  pl={1}
                  pr={1}
                  iconSize={1.25}
                />
              </Flex.Item>
              <Flex.Item mr={1}>
                <FakeToolbarButton
                  name="Account Management"
                  currentScreenMode={screenmode}
                  setScreenmode={setScreenmode}
                  ownerScreenMode={SCREENS.users}
                />
              </Flex.Item>
              <Flex.Item mr={1}>
                <FakeToolbarButton
                  name="Audit Log"
                  currentScreenMode={screenmode}
                  setScreenmode={setScreenmode}
                  ownerScreenMode={SCREENS.audit}
                />
              </Flex.Item>
              <Flex.Item mr={1}>
                <FakeToolbarButton
                  name={ianFileName}
                  currentScreenMode={screenmode}
                  setScreenmode={setScreenmode}
                  ownerScreenMode={SCREENS.ian}
                />
              </Flex.Item>
              <Flex.Item grow />
              <Flex.Item>
                <Button p={0.75} pl={1} pr={1} disabled>
                  {station_time} ST
                </Button>
              </Flex.Item>
            </Flex>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const getRandomDoomMessage = () => {
  const messages = [
    'BUY GOLD!',
    'BUY LOW, SELL HIGH!',
    'INVEST IN CRYPTO!',
    'SELL EVERYTHING!',
    'THE ECONOMY IS COLLAPSING!',
    'THE ECONOMY IS RUINED!',
    'THE MARKET IS CRASHING!',
    'THE STATION IS GOING BANKRUPT!',
  ];
  return messages[Math.floor(Math.random() * messages.length)];
};

type FakeWindowProps = {
  name: string;
  setScreenmode: (mode: SCREENS) => void;
};

const FakeWindowIan = (props: FakeWindowProps) => {
  const { data } = useBackend<Data>();
  const { young_ian } = data;

  return (
    <FakeWindow {...props}>
      <DmIcon
        width="300px"
        height="300px"
        mt={1}
        icon="icons/mob/simple/pets.dmi"
        icon_state={young_ian ? 'puppy' : 'corgi'}
      />
    </FakeWindow>
  );
};

const FakeWindow = (
  props: FakeWindowProps & {
    children: React.ReactNode;
  },
) => {
  const { act } = useBackend();
  const { name, children, setScreenmode } = props;

  return (
    <Stack
      style={{
        flexDirection: 'column',
        outline: 'solid 1px black',
        outlineStyle: 'outset',
        outlineWidth: '2px',
        outlineColor: 'hsl(0, 0%, 85%)',
        backgroundColor: 'rgb(195, 195, 195)',
      }}
    >
      <Stack.Item>
        <Flex height="30px" backgroundColor="hsl(240, 100%, 25.1%)">
          <Flex.Item grow p={1}>
            <Box color="white">{name}</Box>
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="times"
              mr={0.75}
              mt={0.75}
              onClick={() => {
                setScreenmode(SCREENS.none);
                act('typesound');
              }}
            />
          </Flex.Item>
        </Flex>
      </Stack.Item>
      <Stack.Item grow mt={-1}>
        <Box p={1}>
          <Box
            height="100%"
            style={{
              backgroundColor: 'white',
              outline: 'solid',
              outlineStyle: 'outset',
              outlineWidth: '2px',
              outlineColor: 'hsl(0, 0%, 85%)',
            }}
          >
            {children}
          </Box>
        </Box>
      </Stack.Item>
    </Stack>
  );
};

const FakeDesktopButton = (props: {
  children: React.ReactNode;
  name: string;
  setScreenmode: (mode: SCREENS) => void;
  ownerScreenMode: SCREENS;
}) => {
  const { act } = useBackend();
  const { children, name, setScreenmode, ownerScreenMode } = props;

  return (
    <>
      <Stack.Item>
        <Button
          color="transparent"
          onClick={() => {
            setScreenmode(ownerScreenMode);
            act('typesound');
          }}
        >
          {children}
        </Button>
      </Stack.Item>
      <Stack.Item color="white">{name}</Stack.Item>
    </>
  );
};

const FakeToolbarButton = (props: {
  name: string;
  currentScreenMode: SCREENS;
  setScreenmode: (mode: SCREENS) => void;
  ownerScreenMode: SCREENS;
}) => {
  const { act } = useBackend();
  const { name, currentScreenMode, setScreenmode, ownerScreenMode } = props;

  return (
    <Button
      height="100%"
      width="120px"
      ellipsis
      lineHeight="28px"
      textColor={currentScreenMode === ownerScreenMode ? 'black' : undefined}
      backgroundColor={
        currentScreenMode === ownerScreenMode ? 'white' : undefined
      }
      onClick={() => {
        setScreenmode(ownerScreenMode);
        act('typesound');
      }}
    >
      {name}
    </Button>
  );
};

enum SORTING {
  ascending,
  descending,
  none,
}

const SortButton = (props: {
  sorting: SORTING;
  setSorting: (sorting: SORTING) => void;
  otherSorters: ((sorting: SORTING) => void)[];
}) => {
  const { sorting, setSorting, otherSorters } = props;

  return (
    <Button
      height="16px"
      fontSize="10px"
      ml={1}
      onClick={() => {
        if (sorting === SORTING.none) {
          setSorting(SORTING.ascending);
        } else if (sorting === SORTING.ascending) {
          setSorting(SORTING.descending);
        } else {
          setSorting(SORTING.none);
        }
        for (const otherSorter of otherSorters) {
          otherSorter(SORTING.none);
        }
      }}
    >
      {sorting === SORTING.ascending ? '^' : ''}
      {sorting === SORTING.descending ? 'v' : ''}
      {sorting === SORTING.none ? 'x' : ''}
    </Button>
  );
};

const UsersScreen = () => {
  const { act, data } = useBackend<Data>();
  const { crashing, accounts, max_pay_mod, min_pay_mod, max_advances } = data;

  const [accountNameSorting, setAccountNameSorting] = useState(
    SORTING.ascending,
  );
  const [balanceSorting, setBalanceSorting] = useState(SORTING.none);
  const [jobSorting, setJobSorting] = useState(SORTING.none);

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
    <Section scrollable fill height="320px">
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
            <Flex>
              <Flex.Item>Account</Flex.Item>
              <Flex.Item>
                <SortButton
                  sorting={accountNameSorting}
                  setSorting={setAccountNameSorting}
                  otherSorters={[setBalanceSorting, setJobSorting]}
                />
              </Flex.Item>
            </Flex>
          </Table.Cell>
          <Table.Cell bold>
            <Flex>
              <Flex.Item>Balance</Flex.Item>
              <Flex.Item>
                <SortButton
                  sorting={balanceSorting}
                  setSorting={setBalanceSorting}
                  otherSorters={[setAccountNameSorting, setJobSorting]}
                />
              </Flex.Item>
            </Flex>
          </Table.Cell>
          <Table.Cell bold>
            <Flex>
              <Flex.Item>Job</Flex.Item>
              <Flex.Item>
                <SortButton
                  sorting={jobSorting}
                  setSorting={setJobSorting}
                  otherSorters={[setAccountNameSorting, setBalanceSorting]}
                />
              </Flex.Item>
            </Flex>
          </Table.Cell>
          <Table.Cell bold>Pay</Table.Cell>
          <Table.Cell bold>Advances</Table.Cell>
        </Table.Row>
        {accountsSorted.map((account, index) => (
          <Table.Row
            key={`account_${account.id}_${index}`}
            style={{
              borderStyle: 'solid',
              borderWidth: '2px',
              borderLeft: '0px',
              borderRight: '0px',
              borderBottom: '0px',
            }}
          >
            <Table.Cell>{account.name}</Table.Cell>
            <Table.Cell
              style={{
                borderStyle: 'solid',
                borderWidth: '1px',
                borderTop: '0px',
                borderBottom: '0px',
              }}
            >
              {account.balance} cr
            </Table.Cell>
            <Table.Cell>{account.job}</Table.Cell>
            <Table.Cell
              style={{
                borderStyle: 'solid',
                borderWidth: '1px',
                borderTop: '0px',
                borderBottom: '0px',
              }}
            >
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
            <Table.Cell>
              <Flex>
                <Flex.Item>
                  <Box>{account.num_advances}</Box>
                </Flex.Item>
                <Flex.Item>
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
                </Flex.Item>
              </Flex>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const AuditScreen = (props) => {
  const { data } = useBackend<Data>();
  const { crashing, audit_log } = data;

  return (
    <Section scrollable fill height="320px">
      {!!crashing && (
        <Modal width="300px" align="center">
          <Blink time={500} interval={500}>
            {getRandomDoomMessage()}
          </Blink>
        </Modal>
      )}
      <Table>
        <Table.Row>
          <Table.Cell bold>Account</Table.Cell>
          <Table.Cell bold>Cost</Table.Cell>
          <Table.Cell bold>Location</Table.Cell>
          <Table.Cell bold>Timestamp</Table.Cell>
        </Table.Row>
        {audit_log.map((purchase, index) => (
          <Table.Row
            key={`audit_${index}`}
            style={{
              borderStyle: 'solid',
              borderWidth: '2px',
              borderLeft: '0px',
              borderRight: '0px',
              borderBottom: '0px',
            }}
          >
            <Table.Cell p={0.5}>{purchase.account}</Table.Cell>
            <Table.Cell
              p={0.5}
              style={{
                borderStyle: 'solid',
                borderWidth: '1px',
                borderTop: '0px',
                borderBottom: '0px',
              }}
            >
              {purchase.cost} cr
            </Table.Cell>
            <Table.Cell p={0.5}>{purchase.vendor}</Table.Cell>
            <Table.Cell
              p={0.5}
              style={{
                borderStyle: 'solid',
                borderWidth: '1px',
                borderTop: '0px',
                borderBottom: '0px',
                borderRight: '0px',
              }}
            >
              {purchase.stationtime || '00:00'} ST
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
