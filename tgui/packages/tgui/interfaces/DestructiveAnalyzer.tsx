import { Box, Button, Image, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  server_connected: BooleanLike;
  loaded_item: string;
  item_icon: string;
  indestructible: BooleanLike;
  already_deconstructed: BooleanLike;
  recoverable_points: string;
  node_data: NodeData[];
  research_point_id: string;
};

type NodeData = {
  node_name: string;
  node_id: string;
  node_hidden: BooleanLike;
};

export const DestructiveAnalyzer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    server_connected,
    indestructible,
    loaded_item,
    item_icon,
    already_deconstructed,
    recoverable_points,
    research_point_id,
    node_data = [],
  } = data;
  if (!server_connected) {
    return (
      <Window width={400} height={260} title="Destructive Analyzer">
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            Not connected to a server. Please sync one using a multitool.
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  if (!loaded_item) {
    return (
      <Window width={400} height={260} title="Destructive Analyzer">
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            No item loaded! <br />
            Put any item inside to see what it&apos;s capable of!
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={400} height={260} title="Destructive Analyzer">
      <Window.Content scrollable>
        <Section
          title={loaded_item}
          buttons={
            <Button
              icon="eject"
              tooltip="Ejects the item currently inside the machine."
              onClick={() => act('eject_item')}
            />
          }
        >
          <Image
            src={`data:image/jpeg;base64,${item_icon}`}
            height="64px"
            width="64px"
            verticalAlign="middle"
          />
        </Section>
        <Section title="Deconstruction Methods">
          {!indestructible && (
            <NoticeBox textAlign="center" danger>
              This item can&apos;t be deconstructed!
            </NoticeBox>
          )}
          {!!indestructible && (
            <>
              {!!recoverable_points && (
                <>
                  <Box fontSize="14px">Research points from deconstruction</Box>
                  <Box>{recoverable_points}</Box>
                </>
              )}
              <Button.Confirm
                content="Deconstruct"
                icon="hammer"
                tooltip={
                  already_deconstructed
                    ? 'This item item has already been deconstructed, and will not give any additional information.'
                    : 'Destroys the object currently residing in the machine.'
                }
                onClick={() =>
                  act('deconstruct', { deconstruct_id: research_point_id })
                }
              />
            </>
          )}
          {node_data.map((node) => (
            <Button.Confirm
              icon="cash-register"
              mt={1}
              disabled={!node.node_hidden}
              key={node.node_id}
              tooltip={
                node.node_hidden
                  ? 'Deconstruct this to research the selected node.'
                  : 'This node has already been researched.'
              }
              onClick={() =>
                act('deconstruct', { deconstruct_id: node.node_id })
              }
            >
              {node.node_name}
            </Button.Confirm>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
