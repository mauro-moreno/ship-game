package game

import "core:fmt"
import "core:os"

DEBUG_DUMP_OUTPUT_DIRECTORY :: "build/debug-dumps"

Debug_Dump_File_Output :: struct {
	directory: string,
}

Debug_Dump_Write_Result :: struct {
	ok:   bool,
	path: string,
}

default_debug_dump_file_output :: proc() -> Debug_Dump_File_Output {
	return Debug_Dump_File_Output{directory = DEBUG_DUMP_OUTPUT_DIRECTORY}
}

write_debug_dump :: proc(ctx: Debug_Dump_Context) -> Debug_Dump_Write_Result {
	return write_debug_dump_document(
		format_debug_dump(ctx),
		debug_dump_file_name(ctx),
		default_debug_dump_file_output(),
	)
}

write_debug_dump_document :: proc(document: Debug_Dump_Document, file_name: string, output: Debug_Dump_File_Output) -> Debug_Dump_Write_Result {
	path := fmt.tprintf("%s/%s", output.directory, file_name)
	if !ensure_debug_dump_output_directory(output) {
		return Debug_Dump_Write_Result{path = path}
	}

	ok := os.write_entire_file(path, transmute([]byte)document.text)
	return Debug_Dump_Write_Result {
		ok = ok,
		path = path,
	}
}

debug_dump_file_name :: proc(ctx: Debug_Dump_Context) -> string {
	return fmt.tprintf(
		"ship-debug-dump-%s-frame-%v-%v.txt",
		string(ctx.scenario_id),
		u64(ctx.frame),
		ctx.reason,
	)
}

ensure_debug_dump_output_directory :: proc(output: Debug_Dump_File_Output) -> bool {
	if output.directory == DEBUG_DUMP_OUTPUT_DIRECTORY && !os.exists("build") {
		if os.make_directory("build") != nil {
			return false
		}
	}

	if !os.exists(output.directory) {
		if os.make_directory(output.directory) != nil {
			return false
		}
	}

	return true
}
