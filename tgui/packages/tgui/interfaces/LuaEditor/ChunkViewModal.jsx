import hljs from 'highlight.js/lib/core';

import { useLocalState } from '../../backend';
import { Box, Button, Modal, Section } from '../../components';
import { sanitizeText } from '../../sanitize';

export const ChunkViewModal = (props) => {
  const [, setModal] = useLocalState('modal');
  const [viewedChunk, setViewedChunk] = useLocalState('viewedChunk');
  return (
    <Modal
      height={`${window.innerHeight * 0.8}px`}
      width={`${window.innerWidth * 0.5}px`}
    >
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
            }}
          >
            Close
          </Button>
        }
      >
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
