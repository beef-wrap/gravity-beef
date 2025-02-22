using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using static gravity_Beef.gravity;

namespace example;

static class Program
{
	const String SOURCE	= """
		extern var Foo
	
		func main() {
			// instance
			var f = Foo();
			var sum1 = f.sum(1, 2);
	
			// static
			var sum2 = Foo.sum(20, 30);
	
			return sum1 + sum2
		}
	""";

	static void report_error(gravity_vm* vm, error_type_t error_type, char8* description, error_desc_t error_desc, void* xdata)
	{
		Debug.WriteLine($"{StringView(description)}");
	}

	static bool sum(gravity_vm* vm, gravity_value_t* args, uint16 nargs, uint32 rindex)
	{
		// SKIPPED: check nargs (must be 3 because arg[0] is self)
		gravity_value_t v1 = args[1];
		gravity_value_t v2 = args[2];
		gravity_value_t sum = .()
			{
				isa = gravity_core_class_from_name(GRAVITY_CLASS_INT_NAME),
				p = .() { n = v1.p.n + v2.p.n }
			};

		// SKIPPED: check that both v1 and v2 are int numbers
		gravity_vm_setslot(vm, sum, rindex);

		return true;
	}

	static void setup_foo(gravity_vm* vm)
	{
		// create sum method
		let fn = gravity_function_new_internal(null, null, => sum, 0);
		let closure =  gravity_closure_new(null, fn);
		let sum = gravity_value_t { isa = closure.isa, p = .() { p = (gravity_object_t*)closure } };

		// create a new Foo class and bind sum as instance method
		gravity_class_t* c = gravity_class_new_pair(vm, "Foo", null, 0, 0);
		gravity_class_bind(c, "sum", sum);

		// also bind sum as static method to class meta
		gravity_class_t* c_meta = gravity_class_get_meta(c);
		gravity_class_bind(c_meta, "sum", sum);

		// register class c inside VM
		let foo = gravity_value_t { isa = c.isa, p = .() { p = (gravity_object_t*)c } };
		gravity_vm_setvalue(vm, "Foo", foo);
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

		setup_foo(vm);

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