import { classes } from 'common/react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Stack } from 'tgui-core/components';
type Data = {
  entered_pin: string;
  lockstate: string;
  ref: string;
};

const KEYPAD = [
  ['1', '4', '7', 'C'],
  ['2', '5', '8', '0'],
  ['3', '6', '9', 'E'],
] as const;

export default function PINPart(props: { ourData: Data }): JSX.Element {
  const { act } = useBackend();
  const { ourData } = props;
  return (
    <Box>
      <Stack>
        <Stack.Item>
          <Stack>
            {KEYPAD.map((keyColumn) => (
              <Stack.Item key={keyColumn[0]}>
                {keyColumn.map((key) => (
                  <Button
                    fluid
                    bold
                    key={key}
                    mb={1}
                    textAlign="center"
                    fontSize="25px"
                    lineHeight={1.2}
                    width="40px"
                    className={classes([
                      'NuclearBomb__Button',
                      'NuclearBomb__Button--keypad',
                      key !== '1' && 'NuclearBomb__Button--' + key,
                    ])}
                    onClick={() =>
                      act('keypad', { partRef: ourData.ref, digit: key })
                    }
                  >
                    {key}
                  </Button>
                ))}
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Box textAlign="center" mb={1} className="NuclearBomb__displayBox">
            {ourData.entered_pin}
          </Box>
          <Box
            mb={1}
            width="100%"
            fontSize="1.8em"
            textAlign="center"
            className="NuclearBomb__displayBox"
          >
            {ourData.lockstate}
          </Box>
          <Box fontSize="10px">
            If not set, enter one to set it. If set, enter again to remove PIN.
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
}
