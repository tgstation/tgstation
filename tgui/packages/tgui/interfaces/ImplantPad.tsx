import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Button, Divider, Flex } from '../components';
import { Window } from '../layouts';

type Data = {
  has_case: BooleanLike;
  has_implant: BooleanLike;
  case_information: string;
};

export const ImplantPad = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_case, has_implant, case_information } = data;
  return (
    <Window width={300} height={200}>
      <Window.Content scrollable>
        <Flex>
          <Flex.Item grow color="good" align="center">
            Implant Mini-Computer
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="eject"
              content="Eject Implant"
              disabled={!has_case}
              onClick={() => act('eject_implant')}
            />
          </Flex.Item>
        </Flex>
        <Divider />
        <Flex bold>
          <Flex.Item>
            {!has_case &&
              'No implant case detected. Please insert one to see its contents.'}
            {!!has_case &&
              !has_implant &&
              'Implant case does not have an implant. Please insert one to continue.'}
            {!!has_case && !!has_implant && case_information}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
