using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using static gravity_Beef.gravity;

namespace example;

static class Program
{
	const String SOURCE	= "func main() {var a = 10; var b=20; return a + b}";

	static void report_error(gravity_vm* vm, error_type_t error_type, char8* description, error_desc_t error_desc, void* xdata)
	{
		Debug.WriteLine($"{description}");
	}

	static int Main(params String[] args)
	{
		// configure a VM delegate
		gravity_delegate_t dlg = .() { error_callback = => report_error };

		// compile Gravity source code into bytecode
		gravity_compiler_t* compiler = gravity_compiler_create(&dlg);
		gravity_closure_t* closure = gravity_compiler_run(compiler, SOURCE, (.)SOURCE.Length, 0, true, true);

		// sanity check on compiled source
		if (closure == null)
		{
			// an error occurred while compiling source code and it has already been reported by the report_error callback
			gravity_compiler_free(compiler);
			return 1;
		}

		// create a new VM
		gravity_vm* vm = gravity_vm_new(&dlg);

		// transfer objects owned by the compiler to the VM (so they can be part of the GC)
		gravity_compiler_transfer(compiler, vm);

		// compiler can now be freed
		gravity_compiler_free(compiler);

		// run main closure inside Gravity bytecode
		if (gravity_vm_runmain(vm, closure))
		{
			// print result (INT) 30 in this simple example
			char8[512] buffer;

			gravity_value_t result = gravity_vm_result(vm);
			gravity_value_dump(vm, result, &buffer, 512);

			Debug.WriteLine($"{StringView(&buffer)}");
		}

		// free VM memory and core libraries
		gravity_vm_free(vm);

		gravity_core_free();

		return 0;
	}
}