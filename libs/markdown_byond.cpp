#include <string>
#include <iostream>
#include <stdio.h>
#include "html.h"

#ifdef _WIN32
#define DLL_EXPORT __declspec(dllexport)
#else
#define DLL_EXPORT __attribute__ ((visibility ("default")))
#endif


extern "C" DLL_EXPORT const char * render_html(int argc, char ** argv);
extern "C" DLL_EXPORT char * free_memory(int argc, char ** argv);
extern "C" DLL_EXPORT char * init_renderer(int argc, char ** argv);

std::string result;
hoedown_html_flags flags = HOEDOWN_HTML_ESCAPE;
hoedown_buffer *html = NULL; //= hoedown_buffer_new(16);
hoedown_document *document = NULL;
hoedown_renderer *renderer = NULL;



char * init_renderer(int argc, char ** argv) {
	renderer = hoedown_html_renderer_new(flags, 0);
	document = hoedown_document_new(renderer, HOEDOWN_EXT_TABLES, 16);
	html = hoedown_buffer_new(16);
	return "Initalized";
}

const char * render_html(int argc, char ** argv) {
	if (argc < 1 || argv[0] == NULL)
		return "";
	result.clear();
	if (renderer == NULL) return "Renderer was NULL. [Notify Host/Coder]";
	if (document == NULL) return "Document was NULL. [Notify Host/Coder]";
	if (html == NULL) return "HTML was NULL. [Notify Host/Coder]";

	char* input_text = (char*)argv[0];
	int input_length = strlen(input_text);
	hoedown_document_render(document, html, (uint8_t*)input_text, input_length);

	result.assign((char*)html->data, html->size);
	hoedown_buffer_reset(html);
	return result.c_str();
}

char * free_memory(int argc, char ** argv) {
	hoedown_buffer_free(html);
	hoedown_document_free(document);
	hoedown_html_renderer_free(renderer);
	return "Freed Memory";
}