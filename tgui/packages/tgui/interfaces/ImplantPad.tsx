import { Box, Button, Divider, Flex } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type Data = {
  has_case: BooleanLike;
  has_implant: BooleanLike;
  case_information: string;
};

export const ImplantPad = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_case, has_implant, case_information } = data;
  const textHtml = {
    __html: sanitizeText(case_information),
  };
  return (
    <Window width={300} height={case_information ? 300 : 200}>
      <Window.Content scrollable>
        <Flex bold>
          <Flex.Item grow color="good" align="center">
            Implant Mini-Computer
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="eject"
              disabled={!has_case}
              onClick={() => act('eject_implant')}
            >
              Eject Case
            </Button>
          </Flex.Item>
        </Flex>
        <Divider />
        <Flex>
          <Flex.Item>
            {!has_case &&
              'No implant case detected. Please insert one to see its contents.'}
            {!!has_case &&
              !has_implant &&
              'Implant case does not have an implant. Please insert one to continue.'}
            {!!has_case && !!has_implant && (
              <Box
                style={{ whiteSpace: 'pre-line' }}
                dangerouslySetInnerHTML={textHtml}
              />
            )}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
