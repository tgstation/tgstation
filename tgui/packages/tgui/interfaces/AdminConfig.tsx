import { Window } from '../layouts';
import { useAIFoundationStore } from '../stores/ai_foundation';
import { PolicyEditor } from './AIFoundationBlackboard';

export const AdminConfig = () => {
  const { policy, gatewayStatus, lastPatchResponse, patchConfig } =
    useAIFoundationStore();

  return (
    <Window title="AI Foundation Config" width={640} height={540} resizable>
      <Window.Content scrollable>
        <PolicyEditor
          policy={policy}
          gatewayStatus={gatewayStatus}
          lastPatchResponse={lastPatchResponse}
          onSubmit={patchConfig}
        />
      </Window.Content>
    </Window>
  );
};
