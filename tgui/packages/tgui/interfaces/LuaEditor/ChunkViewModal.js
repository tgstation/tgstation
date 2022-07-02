import { useLocalState } from '../../backend';
import { Button, Modal, Section, Box } from '../../components';
import { sanitizeText } from '../../sanitize';
import hljs from 'highlight.js/lib/core';

export const ChunkViewModal = (props, context) => {
  const [, setModal] = useLocalState(context, 'modal');
  const [viewedChunk, setViewedChunk] = useLocalState(context, 'viewedChunk');
  return (
    <Modal height="600px" width="500px">
      <Section
        fill
        scrollable
        scrollableHorizontal
        title="Chunk"
        buttons={
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(null);
              setViewedChunk(null);
            }}>
            Close
          </Button>
        }>
        <Box
          as="pre"
          dangerouslySetInnerHTML={{
            __html: hljs.highlight(sanitizeText(viewedChunk), {
              language: 'lua',
            }).value,
          }}
        />
      </Section>
    </Modal>
  );
};
