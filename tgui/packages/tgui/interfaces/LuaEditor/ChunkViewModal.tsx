import hljs from 'highlight.js/lib/core';
import type { Dispatch, SetStateAction } from 'react';
import { Box, Button, Modal, Section } from 'tgui-core/components';

import { sanitizeText } from '../../sanitize';
import type { LuaEditorModal } from './types';

type ChunkViewModalProps = {
  setModal: Dispatch<SetStateAction<LuaEditorModal>>;
  viewedChunk: string;
  setViewedChunk: Dispatch<SetStateAction<string | undefined>>;
};

export const ChunkViewModal = (props: ChunkViewModalProps) => {
  const { setModal, viewedChunk, setViewedChunk } = props;
  return (
    <Modal position="absolute" width="50%" height="80%" top="10%" left="25%">
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
              setModal(undefined);
              setViewedChunk(undefined);
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
