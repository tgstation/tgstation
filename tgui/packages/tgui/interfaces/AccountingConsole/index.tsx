import { Button, DmIcon, Stack } from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { Window } from '../../layouts';
import { AuditScreen } from './AuditScreen';
import { FakeDesktopButton } from './FakeDesktopButton';
import { FakeToolbarButton } from './FakeToolbarButton';
import { FakeWindow, FakeWindowIan } from './FakeWindow';
import { type Data, SCREENS } from './types';
import { UsersScreen } from './UsersScreen';

export const AccountingConsole = () => {
  const { data } = useBackend<Data>();
  const {
    station_time = '00:00',
    pic_file_format = 'png',
    young_ian = false,
  } = data;
  const [screenmode, setScreenmode] = useSharedState('screen', SCREENS.none);

  const ianFileName = young_ian
    ? `Ian's first birthday.${pic_file_format}`
    : `Ian.${pic_file_format}`;

  return (
    <Window width={600} height={440} theme="ntOS95">
      <Window.Content fontFamily="Tahoma">
        <Stack vertical fill>
          <Stack.Item>
            <Stack height="355px">
              <Stack.Item width="100px">
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
              </Stack.Item>
              {screenmode === SCREENS.users && (
                <Stack.Item grow ml={3}>
                  <FakeWindow
                    name="Crew Account Summary"
                    setScreenmode={setScreenmode}
                  >
                    <UsersScreen />
                  </FakeWindow>
                </Stack.Item>
              )}
              {screenmode === SCREENS.audit && (
                <Stack.Item grow ml={3}>
                  <FakeWindow name="Audit Log" setScreenmode={setScreenmode}>
                    <AuditScreen />
                  </FakeWindow>
                </Stack.Item>
              )}
              {screenmode === SCREENS.ian && (
                <Stack.Item ml={10}>
                  <FakeWindowIan
                    name={ianFileName}
                    setScreenmode={setScreenmode}
                  />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item
            grow
            mt={1}
            p={0.5}
            ml={-1}
            mr={-1}
            mb={-1}
            className="Accounting__Toolbar"
          >
            <Stack>
              <Stack.Item mr={1}>
                <Button
                  disabled
                  textColor="black"
                  icon="user"
                  p={0.75}
                  pl={1}
                  pr={1}
                  iconSize={1.25}
                />
              </Stack.Item>
              <Stack.Item mr={1}>
                <FakeToolbarButton
                  name="Account Management"
                  currentScreenMode={screenmode}
                  setScreenmode={setScreenmode}
                  ownerScreenMode={SCREENS.users}
                />
              </Stack.Item>
              <Stack.Item mr={1}>
                <FakeToolbarButton
                  name="Audit Log"
                  currentScreenMode={screenmode}
                  setScreenmode={setScreenmode}
                  ownerScreenMode={SCREENS.audit}
                />
              </Stack.Item>
              <Stack.Item mr={1}>
                <FakeToolbarButton
                  name={ianFileName}
                  currentScreenMode={screenmode}
                  setScreenmode={setScreenmode}
                  ownerScreenMode={SCREENS.ian}
                />
              </Stack.Item>
              <Stack.Item grow />
              <Stack.Item>
                <Button p={0.75} pl={1} pr={1} disabled textColor="black">
                  {station_time} ST
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
