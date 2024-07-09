import { useBackend } from '../backend';
import {
  Image,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Box,
  Icon,
  Flex,
} from '../components';
import { Window } from '../layouts';

type Data = {
  bounty_name: String;
  bounty_icon: String;
  bounty_reward: String;
  bounty_gps: String;
};

export const bountypaper = (props) => {
  const { act, data } = useBackend<Data>();
  const { bounty_name, bounty_icon, bounty_reward, bounty_gps } = data;
  return (
    <Window title="Bounty Contract" width={300} height={440} theme="oldpaper">
      <Window.Content>
        <Stack vertical textAlign="center" fontFamily="playbill">
          <Stack.Item>
            <Box
              style={{
                borderTop: '2px solid #642600',
                fontSize: '50px',
                color: '#642600',
              }}
            >
              WANTED
            </Box>
          </Stack.Item>
          <Stack.Item
            mt={-1}
            style={{
              borderBottom: '2px solid #642600',
            }}
          >
            {Array.from({ length: 5 }, (_, index) => (
              <Icon color={'#642600'} name={'star'} />
            ))}
          </Stack.Item>
          <Stack.Item>
            <Box
              style={{
                fontSize: '35px',
                color: '#642600',
              }}
            >
              DEAD{' '}
              <span style={{ textDecoration: 'underline', fontSize: '35px' }}>
                OR
              </span>{' '}
              ALIVE
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Image
              m={1}
              src={`data:image/jpeg;base64,${bounty_icon}`}
              height="160px"
              width="160px"
              style={{
                verticalAlign: 'middle',
                borderRadius: '1em',
                border: '1px solid #642600',
              }}
            />
          </Stack.Item>
          <Stack.Item>
            <Section
              style={{
                color: '#642600',
              }}
            >
              <Stack vertical fontFamily="serif">
                <Stack.Item
                  mt={-3}
                  style={{
                    fontSize: '35px',
                    fontWeight: 'bold',
                  }}
                >
                  <Stack
                    style={{
                      justifyContent: 'center',
                    }}
                  >
                    <Stack.Item
                      width="80px"
                      style={{
                        borderRight: '2px solid #642600',
                      }}
                    >
                      <Box
                        style={{
                          fontSize: '15px',
                          fontWeight: 'bold',
                        }}
                      >
                        <div style={{ display: 'block' }}>CASH</div>
                        <div style={{ display: 'block' }}>REWARD</div>
                      </Box>
                    </Stack.Item>
                    <Stack.Item mt={0.2}>{bounty_reward}$</Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item
                  mt={-0.5}
                  fontFamily="playbill"
                  style={{
                    fontSize: '35px',
                  }}
                >
                  <Icon color={'#642600'} name={'hand-point-right'} />
                  {bounty_name}
                  <Icon color={'#642600'} name={'hand-point-left'} />
                </Stack.Item>
                <Stack.Item
                  mt={1}
                  fontFamily="playbill"
                  style={{
                    borderTop: '2px solid #642600',
                    fontSize: '40px',
                  }}
                >
                  {bounty_gps}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
