import { useBackend } from '../backend';
import { Section, Box, Button } from '../components';
import { Window } from '../layouts';

export const ArtifactPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { artifacts } = data;
  return (
    <Window title="Artifact Panel" width={420} height={675} theme="admin">
      <Window.Content overflowY="scroll" overflowX="hidden">
        {data.artifacts.map((artifact_data) => (
          <Section
            title={artifact_data.name}
            key={artifact_data.ref}
            buttons={
              <>
                <Button
                  content="Delete"
                  color="bad"
                  onClick={() => act('delete', { ref: artifact_data.ref })}
                />
                <Button
                  key={artifact_data.ref}
                  content={artifact_data.active ? 'Deactivate' : 'Activate'}
                  selected={artifact_data.active}
                  onClick={() =>
                    act('toggle', {
                      ref: artifact_data.ref,
                    })
                  }
                />
              </>
            }>
            <Box>{'Type name: ' + artifact_data.typename}</Box>
            <Box>{'Located at: ' + artifact_data.loc}</Box>
            <Box>{'Last touched by: ' + artifact_data.lastprint}</Box>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
