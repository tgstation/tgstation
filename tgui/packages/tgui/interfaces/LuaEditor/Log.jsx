import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  LabeledList,
  Stack,
} from '../../components';
import { logger } from '../../logging';
import { ListMapper } from './ListMapper';

const parsePanic = (name, panic_json) => {
  const panic_info = JSON.parse(panic_json);
  const {
    message,
    location: { file, line },
    backtrace,
  } = panic_info;
  return (
    <>
      <Box textColor="red">
        <b>{name}</b> panicked at {file}:{line}: {message}
      </Box>
      <Collapsible title="Backtrace">
        <Stack vertical>
          {backtrace
            ?.filter(
              (frame) => frame.file !== undefined && frame.line !== undefined,
            )
            ?.map(({ name, file, line }, i) => (
              <>
                {i > 0 && <Divider />}
                <Stack.Item key={i}>
                  <LabeledList>
                    <LabeledList.Item label="function">{name}</LabeledList.Item>
                    <LabeledList.Item label="location">
                      {file}:{line}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </>
            ))}
        </Stack>
      </Collapsible>
    </>
  );
};

export const Log = (props) => {
  const { act, data } = useBackend();
  const { stateLog } = data;
  const [, setViewedChunk] = useLocalState('viewedChunk');
  const [, setModal] = useLocalState('modal');
  return stateLog.map((element, i) => {
    const { name, status, return_values, variants, message, chunk, repeats } =
      element;
    logger.log(element);
    let output;
    let messageColor;
    switch (status) {
      case 'sleep':
        if (chunk) {
          messageColor = 'blue';
          output = (
            <>
              <b>{name}</b> slept.
            </>
          );
        }
        break;
      case 'yield':
        output = (
          <>
            <b>{name}</b> yielded
            {return_values.length
              ? ` ${return_values.length} value${
                  return_values.length > 1 ? 's' : ''
                }`
              : ''}
            .
            {return_values.length ? (
              <ListMapper
                list={return_values}
                variants={variants}
                skipNulls
                name="Return Values"
                collapsible
                vvAct={(path) =>
                  act('vvReturnValue', {
                    entryIndex: i + 1,
                    tableIndices: path,
                  })
                }
              />
            ) : (
              <br />
            )}
          </>
        );
        messageColor = 'yellow';
        break;
      case 'finished':
        output = (
          <>
            <b>{name}</b> returned
            {return_values.length
              ? ` ${return_values.length} value${
                  return_values.length > 1 ? 's' : ''
                }`
              : ''}
            .
            <Box color="default">
              {return_values.length ? (
                <ListMapper
                  list={return_values}
                  variants={variants}
                  skipNulls
                  name="Return Values"
                  collapsible
                  vvAct={(path) =>
                    act('vvReturnValue', {
                      entryIndex: i + 1,
                      tableIndices: path,
                    })
                  }
                />
              ) : (
                <br />
              )}
            </Box>
          </>
        );
        messageColor = 'green';
        break;
      case 'error':
        output = (
          <>
            <b>{name}</b> errored with the message &quot;{message}&quot;
          </>
        );
        messageColor = 'red';
        break;
      case 'panic':
        output = parsePanic(name, message);
        break;
      case 'print':
        output = message;
        break;
      default:
        logger.warn(`unknown log status ${status}`);
    }
    if (output === undefined) {
      return;
    }
    if (chunk) {
      output = (
        <>
          {output}
          <Button
            onClick={() => {
              setViewedChunk(chunk);
              setModal('viewChunk');
            }}
          >
            View Source
          </Button>
        </>
      );
    }
    return (
      <>
        {i > 0 && <Divider />}
        <Box width="100%" key={i} color={messageColor}>
          {output}
        </Box>
        {repeats && (
          <Box
            inline
            px="0.25rem"
            mt="0.25rem"
            style={{
              borderRadius: '0.5em',
            }}
            backgroundColor={messageColor}
          >
            x{repeats + 1}
          </Box>
        )}
      </>
    );
  });
};
