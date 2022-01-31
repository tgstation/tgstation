import { BooleanLike } from "common/react";
import { useBackend } from "../backend";
import { Window } from "../layouts";

type Surgery = {
  name: string,
  blocked?: BooleanLike,
};

type SurgeryInitiatorData = {
  selected_zone: string,
  surgeries: Surgery[],
  target_name: string,
};

export const SurgeryInitiator = (props, context) => {
  const { act, data } = useBackend<SurgeryInitiatorData>(context);

  return (
    <Window
      width={400}
      height={300}
      title={`Surgery on ${data.target_name}`}
    >
      <Window.Content>
        {JSON.stringify(data.surgeries)}
      </Window.Content>
    </Window>
  );
};
