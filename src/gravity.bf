using System;
using System.Interop;

namespace gravity_Beef;

public static class gravity
{
	typealias size_t = uint;
	typealias char = c_char;
	typealias uint8_t = uint8;
	typealias uint16_t = uint16;
	typealias uint32_t = uint32;
	typealias uint64_t = uint64;
	typealias int8_t = int8;
	typealias int16_t = int16;
	typealias int32_t = int32;
	typealias int64_t = int64;
	typealias nanotime_t = uint64_t;

	public struct json_t;
	public struct json_value;

	public const String GRAVITY_CLASS_INT_NAME          = "Int";
	public const String GRAVITY_CLASS_FLOAT_NAME        = "Float";
	public const String GRAVITY_CLASS_BOOL_NAME         = "Bool";
	public const String GRAVITY_CLASS_STRING_NAME       = "String";
	public const String GRAVITY_CLASS_OBJECT_NAME       = "Object";
	public const String GRAVITY_CLASS_CLASS_NAME        = "Class";
	public const String GRAVITY_CLASS_NULL_NAME         = "Null";
	public const String GRAVITY_CLASS_FUNCTION_NAME     = "Func";
	public const String GRAVITY_CLASS_FIBER_NAME        = "Fiber";
	public const String GRAVITY_CLASS_INSTANCE_NAME     = "Instance";
	public const String GRAVITY_CLASS_CLOSURE_NAME      = "Closure";
	public const String GRAVITY_CLASS_LIST_NAME         = "List";
	public const String GRAVITY_CLASS_MAP_NAME          = "Map";
	public const String GRAVITY_CLASS_RANGE_NAME        = "Range";
	public const String GRAVITY_CLASS_UPVALUE_NAME      = "Upvalue";

	enum gtoken_t
	{
		// General (8)
		TOK_EOF    = 0, TOK_ERROR, TOK_COMMENT, TOK_STRING, TOK_NUMBER, TOK_IDENTIFIER, TOK_SPECIAL, TOK_MACRO,

		// Keywords (36)
		// remember to keep in sync functions token_keywords_indexes and token_name
		TOK_KEY_FUNC, TOK_KEY_SUPER, TOK_KEY_DEFAULT, TOK_KEY_TRUE, TOK_KEY_FALSE, TOK_KEY_IF,
		TOK_KEY_ELSE, TOK_KEY_SWITCH, TOK_KEY_BREAK, TOK_KEY_CONTINUE, TOK_KEY_RETURN, TOK_KEY_WHILE,
		TOK_KEY_REPEAT, TOK_KEY_FOR, TOK_KEY_IN, TOK_KEY_ENUM, TOK_KEY_CLASS, TOK_KEY_STRUCT, TOK_KEY_PRIVATE,
		TOK_KEY_FILE, TOK_KEY_INTERNAL, TOK_KEY_PUBLIC, TOK_KEY_STATIC, TOK_KEY_EXTERN, TOK_KEY_LAZY, TOK_KEY_CONST,
		TOK_KEY_VAR, TOK_KEY_MODULE, TOK_KEY_IMPORT, TOK_KEY_CASE, TOK_KEY_EVENT, TOK_KEY_NULL, TOK_KEY_UNDEFINED,
		TOK_KEY_ISA, TOK_KEY_CURRFUNC, TOK_KEY_CURRARGS,

		// Operators (36)
		TOK_OP_SHIFT_LEFT, TOK_OP_SHIFT_RIGHT, TOK_OP_MUL, TOK_OP_DIV, TOK_OP_REM, TOK_OP_BIT_AND, TOK_OP_ADD, TOK_OP_SUB,
		TOK_OP_BIT_OR, TOK_OP_BIT_XOR, TOK_OP_BIT_NOT, TOK_OP_RANGE_EXCLUDED, TOK_OP_RANGE_INCLUDED, TOK_OP_LESS, TOK_OP_LESS_EQUAL,
		TOK_OP_GREATER, TOK_OP_GREATER_EQUAL, TOK_OP_ISEQUAL, TOK_OP_ISNOTEQUAL, TOK_OP_ISIDENTICAL, TOK_OP_ISNOTIDENTICAL,
		TOK_OP_PATTERN_MATCH, TOK_OP_AND, TOK_OP_OR, TOK_OP_TERNARY, TOK_OP_ASSIGN, TOK_OP_MUL_ASSIGN, TOK_OP_DIV_ASSIGN,
		TOK_OP_REM_ASSIGN, TOK_OP_ADD_ASSIGN, TOK_OP_SUB_ASSIGN, TOK_OP_SHIFT_LEFT_ASSIGN, TOK_OP_SHIFT_RIGHT_ASSIGN,
		TOK_OP_BIT_AND_ASSIGN, TOK_OP_BIT_OR_ASSIGN, TOK_OP_BIT_XOR_ASSIGN, TOK_OP_NOT,

		// Punctuators (10)
		TOK_OP_SEMICOLON, TOK_OP_OPEN_PARENTHESIS, TOK_OP_COLON, TOK_OP_COMMA, TOK_OP_DOT, TOK_OP_CLOSED_PARENTHESIS,
		TOK_OP_OPEN_SQUAREBRACKET, TOK_OP_CLOSED_SQUAREBRACKET, TOK_OP_OPEN_CURLYBRACE, TOK_OP_CLOSED_CURLYBRACE,

		// Mark end of tokens (1)
		TOK_END
	}

	enum gliteral_t
	{
		LITERAL_STRING, LITERAL_FLOAT, LITERAL_INT, LITERAL_BOOL, LITERAL_STRING_INTERPOLATED
	}

	enum gbuiltin_t
	{
		BUILTIN_NONE, BUILTIN_LINE, BUILTIN_COLUMN, BUILTIN_FILE, BUILTIN_FUNC, BUILTIN_CLASS
	}

	struct gtoken_s
	{
		gtoken_t            type; // enum based token type
		uint32_t            lineno; // token line number (1-based)
		uint32_t            colno; // token column number (0-based) at the end of the token
		uint32_t            position; // offset of the first character of the token
		uint32_t            bytes; // token length in bytes
		uint32_t            length; // token length (UTF-8)
		uint32_t            fileid; // token file id
		gbuiltin_t          builtin; // builtin special identifier flag
		char          		* value; // token value (not null terminated)
	}

	public enum gnode_n
	{
		// statements: 7
		NODE_LIST_STAT, NODE_COMPOUND_STAT, NODE_LABEL_STAT, NODE_FLOW_STAT, NODE_JUMP_STAT, NODE_LOOP_STAT, NODE_EMPTY_STAT,

		// declarations: 6
		NODE_ENUM_DECL, NODE_FUNCTION_DECL, NODE_VARIABLE_DECL, NODE_CLASS_DECL, NODE_MODULE_DECL, NODE_VARIABLE,

		// expressions: 8
		NODE_BINARY_EXPR, NODE_UNARY_EXPR, NODE_FILE_EXPR, NODE_LIST_EXPR, NODE_LITERAL_EXPR, NODE_IDENTIFIER_EXPR,
		NODE_POSTFIX_EXPR, NODE_KEYWORD_EXPR,

		// postfix subexpression type
		NODE_CALL_EXPR, NODE_SUBSCRIPT_EXPR, NODE_ACCESS_EXPR
	}

	[CRepr]
	public enum gnode_location_type
	{
		LOCATION_LOCAL,
		LOCATION_GLOBAL,
		LOCATION_UPVALUE,
		LOCATION_CLASS_IVAR_SAME,
		LOCATION_CLASS_IVAR_OUTER
	}

	// BASE NODE
	[CRepr]
	public struct gnode_t
	{
		gnode_n     tag; // node type from gnode_n enum
		uint32_t    refcount; // reference count to manage duplicated nodes
		uint32_t    block_length; // total length in bytes of the block (used in autocompletion)
		gtoken_s    token; // token type and location
		bool        is_assignment; // flag to check if it is an assignment node
		void        * decl; // enclosing declaration node
	}

	// UPVALUE STRUCT
	[CRepr]
	public struct gupvalue_t
	{
		gnode_t     * node; // reference to the original var node
		uint32_t    index; // can be an index in the stack or in the upvalue list (depending on the is_direct flag)
		uint32_t    selfindex; // always index inside uplist
		bool        is_direct; // flag to check if var is local to the direct enclosing func
	}

	[CRepr]
	public struct gnode_r
	{
		size_t n, m; gnode_t* p;
	}

	[CRepr]
	public struct gupvalue_r
	{
		size_t n, m; gupvalue_t* p;
	}

	[CRepr]
	public struct cstring_r
	{
		size_t n, m; char* p;
	}

	[CRepr]
	public struct symboltable_t;

	// LOCATION
	[CRepr]
	public struct gnode_location_t
	{
		gnode_location_type type; // location type
		uint16_t            index; // symbol index
		uint16_t            nup; // upvalue index or outer index
	}

	// STATEMENTS
	[CRepr]
	public struct gnode_compound_stmt_t
	{
		gnode_t             basen; // NODE_LIST_STAT | NODE_COMPOUND_STAT
		symboltable_t       * symtable; // node internal symbol table
		gnode_r             * stmts; // array of statements node
		uint32_t            nclose; // initialized to UINT32_MAX
	}

	typealias gnode_list_stmt_t = gnode_compound_stmt_t;

	[CRepr]
	public struct gnode_label_stmt_t
	{
		gnode_t             basen; // CASE or DEFAULT
		gnode_t             * expr; // expression in case of CASE
		gnode_t             * stmt; // common statement
		uint32_t            label_case; // for switch to jump
	}

	[CRepr]
	public struct gnode_flow_stmt_t
	{
		gnode_t             basen; // IF, SWITCH, TOK_OP_TERNARY
		gnode_t             * cond; // common condition (it's an expression)
		gnode_t             * stmt; // common statement
		gnode_t             * elsestmt; // optional else statement in case of IF
	}

	[CRepr]
	public struct gnode_loop_stmt_t
	{
		gnode_t             basen; // WHILE, REPEAT or FOR
		gnode_t             * cond; // used in WHILE and FOR
		gnode_t             * stmt; // common statement
		gnode_t             * expr; // used in REPEAT and FOR
		uint32_t            nclose; // initialized to UINT32_MAX
	}

	[CRepr]
	public struct gnode_jump_stmt_t
	{
		gnode_t             basen; // BREAK, CONTINUE or RETURN
		gnode_t             * expr; // optional expression in case of RETURN
	}

	// DECLARATIONS
	[CRepr]
	public struct gnode_function_decl_t
	{
		gnode_t             basen; // FUNCTION_DECL or FUNCTION_EXPR
		gnode_t             * env; // shortcut to node where function is declared
		gtoken_t            access; // TOK_KEY_PRIVATE | TOK_KEY_INTERNAL | TOK_KEY_PUBLIC
		gtoken_t            storage; // TOK_KEY_STATIC | TOK_KEY_EXTERN
		symboltable_t       * symtable; // function internal symbol table
		char                * identifier; // function name
		gnode_r             * parameters; // function params
		gnode_compound_stmt_t* block; // internal function statements
		uint16_t            nlocals; // locals counter
		uint16_t            nparams; // formal parameters counter
		bool                has_defaults; // flag set if parmas has default values
		bool                is_closure; // flag to check if function is a closure
		gupvalue_r          * uplist; // list of upvalues used in function (can be empty)
	}

	typealias gnode_function_expr_t = gnode_function_decl_t;

	[CRepr]
	public struct gnode_variable_decl_t
	{
		gnode_t             basen; // VARIABLE_DECL
		gtoken_t            type; // TOK_KEY_VAR | TOK_KEY_CONST
		gtoken_t            access; // TOK_KEY_PRIVATE | TOK_KEY_INTERNAL | TOK_KEY_PUBLIC
		gtoken_t            storage; // TOK_KEY_STATIC | TOK_KEY_EXTERN
		gnode_r             * decls; // variable declarations list (gnode_var_t)
	}

	[CRepr]
	public struct gnode_var_t
	{
		gnode_t             basen; // VARIABLE
		gnode_t             * env; // shortcut to node where variable is declared
		char                * identifier; // variable name
		char                * annotation_type; // optional annotation type
		gnode_t             * expr; // optional assignment expression/declaration
		gtoken_t            access; // optional access token (duplicated value from its gnode_variable_decl_t)
		uint16_t            index; // local variable index (if local)
		bool                upvalue; // flag set if this variable is used as an upvalue
		bool                iscomputed; // flag set is variable must not be backed
		gnode_variable_decl_t   * vdecl; // reference to enclosing variable declaration (in order to be able to have access to storage and access fields)
	}

	[CRepr]
	public struct gnode_enum_decl_t
	{
		gnode_t             basen; // ENUM_DECL
		gnode_t             * env; // shortcut to node where enum is declared
		gtoken_t            access; // TOK_KEY_PRIVATE | TOK_KEY_INTERNAL | TOK_KEY_PUBLIC
		gtoken_t            storage; // TOK_KEY_STATIC | TOK_KEY_EXTERN
		symboltable_t       * symtable; // enum internal hash table
		char                * identifier; // enum name
	}

	[CRepr]
	public struct gnode_class_decl_t
	{
		gnode_t             basen; // CLASS_DECL
		bool                bridge; // flag to check of a bridged class
		bool                is_struct; // flag to mark the class as a struct
		gnode_t             * env; // shortcut to node where class is declared
		gtoken_t            access; // TOK_KEY_PRIVATE | TOK_KEY_INTERNAL | TOK_KEY_PUBLIC
		gtoken_t            storage; // TOK_KEY_STATIC | TOK_KEY_EXTERN
		char                * identifier; // class name
		gnode_t             * superclass; // super class ptr
		bool                super_extern; // flag set when a superclass is declared as extern
		gnode_r             * protocols; // array of protocols (currently unused)
		gnode_r             * decls; // class declarations list
		symboltable_t       * symtable; // class internal symbol table
		void                * data; // used to keep track of super classes
		uint32_t            nivar; // instance variables counter
		uint32_t            nsvar; // static variables counter
	}

	[CRepr]
	public struct gnode_module_decl_t
	{
		gnode_t             basen; // MODULE_DECL
		gnode_t             * env; // shortcut to node where module is declared
		gtoken_t            access; // TOK_KEY_PRIVATE | TOK_KEY_INTERNAL | TOK_KEY_PUBLIC
		gtoken_t            storage; // TOK_KEY_STATIC | TOK_KEY_EXTERN
		char          		* identifier; // module name
		gnode_r             * decls; // module declarations list
		symboltable_t       * symtable; // module internal symbol table
	}

	// EXPRESSIONS
	[CRepr]
	public struct gnode_binary_expr_t
	{
		gnode_t             basen; // BINARY_EXPR
		gtoken_t            op; // operation
		gnode_t             * left; // left node
		gnode_t             * right; // right node
	}

	[CRepr]
	public struct  gnode_unary_expr_t
	{
		gnode_t             basen; // UNARY_EXPR
		gtoken_t            op; // operation
		gnode_t             * expr; // node
	}

	[CRepr]
	public struct gnode_file_expr_t
	{
		gnode_t             basen; // FILE
		cstring_r           * identifiers; // identifier name
		gnode_location_t    location; // identifier location
	}

	[CRepr]
	public struct gnode_literal_expr_t
	{
		gnode_t             basen; // LITERAL
		gliteral_t          type; // LITERAL_STRING, LITERAL_FLOAT, LITERAL_INT, LITERAL_BOOL, LITERAL_INTERPOLATION
		uint32_t            len; // used only for TYPE_STRING [Union] struct
		/**/ [Union] struct
		{
			char            * str; // LITERAL_STRING
			double          d; // LITERAL_FLOAT
			int64_t         n64; // LITERAL_INT or LITERAL_BOOL
			gnode_r         * r; // LITERAL_STRING_INTERPOLATED
		} value;
	}

	[CRepr]
	public struct gnode_identifier_expr_t
	{
		gnode_t             basen; // IDENTIFIER or ID
		char                * value; // identifier name
		char                * value2; // NULL for IDENTIFIER (check if just one value or an array)
		gnode_t             * symbol; // pointer to identifier declaration (if any)
		gnode_location_t    location; // location coordinates
		gupvalue_t          * upvalue; // upvalue location reference
	}

	[CRepr]
	public struct gnode_keyword_expr_t
	{
		gnode_t             basen; // KEYWORD token
	}

	typealias gnode_empty_stmt_t = gnode_keyword_expr_t;

	typealias gnode_base_t = gnode_keyword_expr_t;

	[CRepr]
	public struct gnode_postfix_expr_t
	{
		gnode_t             basen; // NODE_CALLFUNC_EXPR, NODE_SUBSCRIPT_EXPR, NODE_ACCESS_EXPR
		gnode_t             * id; // id(...) or id[...] or id.
		gnode_r             * list; // list of postfix_subexpr
	}

	[CRepr]
	public struct gnode_postfix_subexpr_t
	{
		gnode_t             basen; // NODE_CALLFUNC_EXPR, NODE_SUBSCRIPT_EXPR, NODE_ACCESS_EXPR [Union] struct

		/**/ [Union] struct
		{
			gnode_t         * expr; // used in case of NODE_SUBSCRIPT_EXPR or NODE_ACCESS_EXPR
			gnode_r         * args; // used in case of NODE_CALLFUNC_EXPR
		} sub;
	}

	[CRepr]
	public struct gnode_list_expr_t
	{
		gnode_t             basen; // LIST_EXPR
		bool                ismap; // flag to check if the node represents a map (otherwise it is a list)
		gnode_r             * list1; // node items (cannot use a symtable here because order is mandatory in array)
		gnode_r             * list2; // used only in case of map
	}

	// error type and code definitions
	[CRepr]
	public enum error_type_t
	{
		GRAVITY_ERROR_NONE = 0,
		GRAVITY_ERROR_SYNTAX,
		GRAVITY_ERROR_SEMANTIC,
		GRAVITY_ERROR_RUNTIME,
		GRAVITY_ERROR_IO,
		GRAVITY_WARNING,
	}

	[CRepr]
	public struct error_desc_t
	{
		uint32_t        lineno;
		uint32_t        colno;
		uint32_t        fileid;
		uint32_t        offset;
	}

	public function void                gravity_error_callback(gravity_vm* vm, error_type_t error_type, char* description, error_desc_t error_desc, void* xdata);
	public function void                gravity_log_callback(gravity_vm* vm, char* message, void* xdata);
	public function void                gravity_log_clear(gravity_vm* vm, void* xdata);
	public function void                gravity_unittest_callback(gravity_vm* vm, error_type_t error_type, char* desc, char* note, gravity_value_t value, int32_t row, int32_t col, void* xdata);
	public function char*               gravity_filename_callback(uint32_t fileid, void* xdata);
	public function char*               gravity_loadfile_callback(char* file, size_t* size, uint32_t* fileid, void* xdata, bool* is_static);
	public function char**              gravity_optclass_callback(void* xdata);
	public function void                gravity_parser_callback(void* token, void* xdata);
	public function char*               gravity_precode_callback(void* xdata);
	public function void                gravity_type_callback(void* token, char* type, void* xdata);

	public function void                gravity_bridge_blacken(gravity_vm* vm, void* xdata);
	public function void*               gravity_bridge_clone(gravity_vm* vm, void* xdata);
	public function bool                gravity_bridge_equals(gravity_vm* vm, void* obj1, void* obj2);
	public function bool                gravity_bridge_execute(gravity_vm* vm, void* xdata, gravity_value_t ctx, gravity_value_t args, int16_t nargs, uint32_t vindex);
	public function void                gravity_bridge_free(gravity_vm* vm, gravity_object_t* obj);
	public function bool                gravity_bridge_getundef(gravity_vm* vm, void* xdata, gravity_value_t target, char* key, uint32_t vindex);
	public function bool                gravity_bridge_getvalue(gravity_vm* vm, void* xdata, gravity_value_t target, char* key, uint32_t vindex);
	public function bool                gravity_bridge_initinstance(gravity_vm* vm, void* xdata, gravity_value_t ctx, gravity_instance_t* instance, gravity_value_t args, int16_t nargs);
	public function bool                gravity_bridge_setvalue(gravity_vm* vm, void* xdata, gravity_value_t target, char* key, gravity_value_t value);
	public function bool                gravity_bridge_setundef(gravity_vm* vm, void* xdata, gravity_value_t target, char* key, gravity_value_t value);
	public function uint32_t            gravity_bridge_size(gravity_vm* vm, gravity_object_t* obj);
	public function char*               gravity_bridge_string(gravity_vm* vm, void* xdata, uint32_t* len);

	[CRepr]
	public struct gravity_delegate_t
	{
		// user data
		void                        * xdata; // optional user data transparently passed between callbacks
		bool                        report_null_errors; // by default messages sent to null objects are silently ignored (if this flag is false)
		bool                        disable_gccheck_1; // memory allocations are protected so it could be useful to automatically check gc when enabled is restored
		
		// callbacks
		gravity_log_callback        log_callback; // log reporting callback
		gravity_log_clear           log_clear; // log reset callback
		public gravity_error_callback      error_callback; // error reporting callback
		gravity_unittest_callback   unittest_callback; // special unit test callback
		gravity_parser_callback     parser_callback; // lexer callback used for syntax highlight
		gravity_type_callback       type_callback; // callback used to bind a token with a declared type
		gravity_precode_callback    precode_callback; // called at parse time in order to give the opportunity to add custom source code
		gravity_loadfile_callback   loadfile_callback; // callback to give the opportunity to load a file from an import statement
		gravity_filename_callback   filename_callback; // called while reporting an error in order to be able to convert a fileid to a real filename
		gravity_optclass_callback   optional_classes; // optional classes to be exposed to the semantic checker as extern (to be later registered)

		// bridge
		gravity_bridge_initinstance bridge_initinstance; // init class
		gravity_bridge_setvalue     bridge_setvalue; // setter
		gravity_bridge_getvalue     bridge_getvalue; // getter
		gravity_bridge_setundef     bridge_setundef; // setter not found
		gravity_bridge_getundef     bridge_getundef; // getter not found
		gravity_bridge_execute      bridge_execute; // execute a method/function
		gravity_bridge_blacken      bridge_blacken; // blacken obj to be GC friend
		gravity_bridge_string       bridge_string; // instance string conversion
		gravity_bridge_equals       bridge_equals; // check if two objects are equals
		gravity_bridge_clone        bridge_clone; // clone
		gravity_bridge_size         bridge_size; // size of obj
		gravity_bridge_free         bridge_free; // free obj
	}

	// core functions
	[CLink] public static extern gravity_class_t  * gravity_core_class_from_name(char* name);
	[CLink] public static extern void              gravity_core_free();
	[CLink] public static extern char            ** gravity_core_identifiers();
	[CLink] public static extern void              gravity_core_init();
	[CLink] public static extern void              gravity_core_register(gravity_vm* vm);
	[CLink] public static extern bool              gravity_iscore_class(gravity_class_t* c);

	// conversion functions
	function gravity_value_t convert_value2bool(gravity_vm* vm, gravity_value_t v);
	function gravity_value_t convert_value2float(gravity_vm* vm, gravity_value_t v);
	function gravity_value_t convert_value2int(gravity_vm* vm, gravity_value_t v);
	function gravity_value_t convert_value2string(gravity_vm* vm, gravity_value_t v);

	// internal functions
	function gravity_closure_t* computed_property_create(gravity_vm* vm, gravity_function_t* getter_func, gravity_function_t* setter_func);
	function void               computed_property_free(gravity_class_t* c, char* name, bool remove_flag);

	// opaque compiler data type
	[CRepr]
	public struct gravity_compiler_t;

	[CLink] public static extern gravity_compiler_t  * gravity_compiler_create(gravity_delegate_t* dlg);
	[CLink] public static extern gravity_closure_t   * gravity_compiler_run(gravity_compiler_t* compiler, char* source, size_t len, uint32_t fileid, bool is_static, bool add_debug);

	[CLink] public static extern gnode_t  * gravity_compiler_ast(gravity_compiler_t* compiler);
	[CLink] public static extern void      gravity_compiler_free(gravity_compiler_t* compiler);
	[CLink] public static extern json_t   * gravity_compiler_serialize(gravity_compiler_t* compiler, gravity_closure_t* closure);
	[CLink] public static extern bool      gravity_compiler_serialize_infile(gravity_compiler_t* compiler, gravity_closure_t* closure, char* path);
	[CLink] public static extern void      gravity_compiler_transfer(gravity_compiler_t* compiler, gravity_vm* vm);

	const char8* GRAVITY_VM_GCENABLED            = "gcEnabled";
	const char8* GRAVITY_VM_GCMINTHRESHOLD       = "gcMinThreshold";
	const char8* GRAVITY_VM_GCTHRESHOLD          = "gcThreshold";
	const char8* GRAVITY_VM_GCRATIO              = "gcRatio";
	const char8* GRAVITY_VM_MAXCALLS             = "maxCCalls";
	const char8* GRAVITY_VM_MAXBLOCK             = "maxBlock";
	const char8* GRAVITY_VM_MAXRECURSION         = "maxRecursionDepth";

	public function void vm_cleanup_cb(gravity_vm* vm);
	public function bool vm_filter_cb(gravity_object_t* obj);
	public function void vm_transfer_cb(gravity_vm* vm, gravity_object_t* obj);

	[CLink] public static extern gravity_delegate_t* gravity_vm_delegate(gravity_vm* vm);
	[CLink] public static extern gravity_fiber_t    * gravity_vm_fiber(gravity_vm* vm);
	[CLink] public static extern void                gravity_vm_free(gravity_vm* vm);
	[CLink] public static extern gravity_closure_t  * gravity_vm_getclosure(gravity_vm* vm);
	[CLink] public static extern gravity_value_t     gravity_vm_getvalue(gravity_vm* vm, char* key, uint32_t keylen);
	[CLink] public static extern gravity_value_t     gravity_vm_keyindex(gravity_vm* vm, uint32_t index);
	[CLink] public static extern bool                gravity_vm_ismini(gravity_vm* vm);
	[CLink] public static extern bool                gravity_vm_isaborted(gravity_vm* vm);
	[CLink] public static extern void                gravity_vm_loadclosure(gravity_vm* vm, gravity_closure_t* closure);
	[CLink] public static extern gravity_value_t     gravity_vm_lookup(gravity_vm* vm, gravity_value_t key);
	[CLink] public static extern gravity_vm         * gravity_vm_new(gravity_delegate_t* dlg);
	[CLink] public static extern gravity_vm         * gravity_vm_newmini(void);
	[CLink] public static extern void                gravity_vm_reset(gravity_vm* vm);
	[CLink] public static extern gravity_value_t     gravity_vm_result(gravity_vm* vm);
	[CLink] public static extern bool                gravity_vm_runclosure(gravity_vm* vm, gravity_closure_t* closure, gravity_value_t sender, gravity_value_t[] parameters, uint16_t nparams);
	[CLink] public static extern bool                gravity_vm_runmain(gravity_vm* vm, gravity_closure_t* closure);
	[CLink] public static extern void                gravity_vm_set_callbacks(gravity_vm* vm, vm_transfer_cb vm_transfer, vm_cleanup_cb vm_cleanup);
	[CLink] public static extern void                gravity_vm_setaborted(gravity_vm* vm);
	[CLink] public static extern void                gravity_vm_seterror(gravity_vm* vm, char* format, ...);
	[CLink] public static extern void                gravity_vm_seterror_string(gravity_vm* vm, char* s);
	[CLink] public static extern void                gravity_vm_setfiber(gravity_vm* vm, gravity_fiber_t* fiber);
	[CLink] public static extern void                gravity_vm_setvalue(gravity_vm* vm, char* key, gravity_value_t value);
	[CLink] public static extern double              gravity_vm_time(gravity_vm* vm);

	[CLink] public static extern void                gravity_gray_object(gravity_vm* vm, gravity_object_t* obj);
	[CLink] public static extern void                gravity_gray_value(gravity_vm* vm, gravity_value_t v);
	[CLink] public static extern void                gravity_gc_setenabled(gravity_vm* vm, bool enabled);
	[CLink] public static extern void                gravity_gc_setvalues(gravity_vm* vm, gravity_int_t threshold, gravity_int_t minthreshold, gravity_float_t ratio);
	[CLink] public static extern void                gravity_gc_start(gravity_vm* vm);
	[CLink] public static extern void                gravity_gc_tempnull(gravity_vm* vm, gravity_object_t* obj);
	[CLink] public static extern void                gravity_gc_temppop(gravity_vm* vm);
	[CLink] public static extern void                gravity_gc_temppush(gravity_vm* vm, gravity_object_t* obj);

	[CLink] public static extern void                gravity_vm_cleanup(gravity_vm* vm);
	[CLink] public static extern void                gravity_vm_filter(gravity_vm* vm, vm_filter_cb cleanup_filter);
	[CLink] public static extern void                gravity_vm_transfer(gravity_vm* vm, gravity_object_t* obj);

	[CLink] public static extern void                gravity_vm_initmodule(gravity_vm* vm, gravity_function_t* f);
	[CLink] public static extern gravity_closure_t  * gravity_vm_loadbuffer(gravity_vm* vm, char* buffer, size_t len);
	[CLink] public static extern gravity_closure_t  * gravity_vm_loadfile(gravity_vm* vm, char* path);

	[CLink] public static extern gravity_closure_t  * gravity_vm_fastlookup(gravity_vm* vm, gravity_class_t* c, int index);
	[CLink] public static extern void               * gravity_vm_getdata(gravity_vm* vm);
	[CLink] public static extern gravity_value_t     gravity_vm_getslot(gravity_vm* vm, uint32_t index);
	[CLink] public static extern void                gravity_vm_setdata(gravity_vm* vm, void* data);
	[CLink] public static extern void                gravity_vm_setslot(gravity_vm* vm, gravity_value_t value, uint32_t index);
	[CLink] public static extern gravity_int_t       gravity_vm_maxmemblock(gravity_vm* vm);
	[CLink] public static extern void                gravity_vm_memupdate(gravity_vm* vm, gravity_int_t value);

	[CLink] public static extern char               * gravity_vm_anonymous(gravity_vm* vm);
	[CLink] public static extern gravity_value_t     gravity_vm_get(gravity_vm* vm, char* key);
	[CLink] public static extern bool                gravity_vm_set(gravity_vm* vm, char* key, gravity_value_t value);

	[CLink] public static extern bool                gravity_isopt_class(gravity_class_t* c);
	[CLink] public static extern void                gravity_opt_free(void);
	[CLink] public static extern void                gravity_opt_register(gravity_vm* vm);

	const int GRAVITYHASH_ENABLE_STATS    = 1; // if 0 then stats are not enabled
	const int GRAVITYHASH_DEFAULT_SIZE    = 32; // default hash table size (used if 0 is passed in gravity_hash_create)
	const float GRAVITYHASH_THRESHOLD     = 0.75f; // threshold used to decide when re-hash the table
	const int GRAVITYHASH_MAXENTRIES      = 1073741824; // please don't put more than 1 billion values in my hash table (2^30)

	[CRepr]
	public struct gravity_hash_t; // opaque hash table struct

	// CALLBACK functions
	public function bool        gravity_hash_compare_fn(gravity_value_t value1, gravity_value_t value2, void* data);
	public function uint32_t    gravity_hash_compute_fn(gravity_value_t key);
	public function bool        gravity_hash_isequal_fn(gravity_value_t v1, gravity_value_t v2);
	public function void        gravity_hash_iterate_fn(gravity_hash_t* hashtable, gravity_value_t key, gravity_value_t value, void* data);
	public function void        gravity_hash_iterate2_fn(gravity_hash_t* hashtable, gravity_value_t key, gravity_value_t value, void* data1, void* data2);
	public function void        gravity_hash_iterate3_fn(gravity_hash_t* hashtable, gravity_value_t key, gravity_value_t value, void* data1, void* data2, void* data3);
	public function void        gravity_hash_transform_fn(gravity_hash_t* hashtable, gravity_value_t key, gravity_value_t* value, void* data);

	// PUBLIC functions
	[CLink] public static extern gravity_hash_t  * gravity_hash_create(uint32_t size, gravity_hash_compute_fn compute, gravity_hash_isequal_fn isequal, gravity_hash_iterate_fn free, void* data);
	[CLink] public static extern void             gravity_hash_free(gravity_hash_t* hashtable);
	[CLink] public static extern bool             gravity_hash_insert(gravity_hash_t* hashtable, gravity_value_t key, gravity_value_t value);
	[CLink] public static extern bool             gravity_hash_isempty(gravity_hash_t* hashtable);
	[CLink] public static extern gravity_value_t* gravity_hash_lookup(gravity_hash_t* hashtable, gravity_value_t key);
	[CLink] public static extern gravity_value_t* gravity_hash_lookup_cstring(gravity_hash_t* hashtable, char* key);
	[CLink] public static extern bool             gravity_hash_remove  (gravity_hash_t* hashtable, gravity_value_t key);

	[CLink] public static extern void             gravity_hash_append(gravity_hash_t* hashtable1, gravity_hash_t* hashtable2);
	[CLink] public static extern uint32_t         gravity_hash_compute_buffer(char* key, uint32_t len);
	[CLink] public static extern uint32_t         gravity_hash_compute_float(gravity_float_t f);
	[CLink] public static extern uint32_t         gravity_hash_compute_int(gravity_int_t n);
	[CLink] public static extern uint32_t         gravity_hash_count(gravity_hash_t* hashtable);
	[CLink] public static extern void             gravity_hash_dump(gravity_hash_t* hashtable);
	[CLink] public static extern void             gravity_hash_iterate(gravity_hash_t* hashtable, gravity_hash_iterate_fn iterate, void* data);
	[CLink] public static extern void             gravity_hash_iterate2(gravity_hash_t* hashtable, gravity_hash_iterate2_fn iterate, void* data1, void* data2);
	[CLink] public static extern void             gravity_hash_iterate3(gravity_hash_t* hashtable, gravity_hash_iterate3_fn iterate, void* data1, void* data2, void* data3);
	[CLink] public static extern uint32_t         gravity_hash_memsize(gravity_hash_t* hashtable);
	[CLink] public static extern void             gravity_hash_resetfree(gravity_hash_t* hashtable);
	[CLink] public static extern void             gravity_hash_stat(gravity_hash_t* hashtable);
	[CLink] public static extern void             gravity_hash_transform(gravity_hash_t* hashtable, gravity_hash_transform_fn iterate, void* data);

	[CLink] public static extern bool             gravity_hash_compare(gravity_hash_t* hashtable1, gravity_hash_t* hashtable2, gravity_hash_compare_fn compare, void* data);

	// MARK: - CALLBACKS -
	// HASH FREE CALLBACK FUNCTION
	[CLink] public static extern void                gravity_hash_interalfree(gravity_hash_t* table, gravity_value_t key, gravity_value_t value, void* data);
	[CLink] public static extern void                gravity_hash_keyfree(gravity_hash_t* table, gravity_value_t key, gravity_value_t value, void* data);
	[CLink] public static extern void                gravity_hash_keyvaluefree(gravity_hash_t* table, gravity_value_t key, gravity_value_t value, void* data);
	[CLink] public static extern void                gravity_hash_valuefree(gravity_hash_t* table, gravity_value_t key, gravity_value_t value, void* data);

	const char8* MAIN_FUNCTION                       = "main";
	const char8* ITERATOR_INIT_FUNCTION              = "iterate";
	const char8* ITERATOR_NEXT_FUNCTION              = "next";
	const char8* INITMODULE_NAME                     = "$moduleinit";
	const char8* CLASS_INTERNAL_INIT_NAME            = "$init";
	const char8* CLASS_CONSTRUCTOR_NAME              = "init";
	const char8* CLASS_DESTRUCTOR_NAME               = "deinit";
	const char8* SELF_PARAMETER_NAME                 = "self";
	const char8* OUTER_IVAR_NAME                     = "outer";
	const char8* GETTER_FUNCTION_NAME                = "get";
	const char8* SETTER_FUNCTION_NAME                = "set";
	const char8* SETTER_PARAMETER_NAME               = "value";

	const int GLOBALS_DEFAULT_SLOT                = 4096;
	const int CPOOL_INDEX_MAX                     = 4096; // 2^12
	const int CPOOL_VALUE_SUPER                   = CPOOL_INDEX_MAX + 1;
	const int CPOOL_VALUE_NULL                    = CPOOL_INDEX_MAX + 2;
	const int CPOOL_VALUE_UNDEFINED               = CPOOL_INDEX_MAX + 3;
	const int CPOOL_VALUE_ARGUMENTS               = CPOOL_INDEX_MAX + 4;
	const int CPOOL_VALUE_TRUE                    = CPOOL_INDEX_MAX + 5;
	const int CPOOL_VALUE_FALSE                   = CPOOL_INDEX_MAX + 6;
	const int CPOOL_VALUE_FUNC                    = CPOOL_INDEX_MAX + 7;

	const int MAX_INSTRUCTION_OPCODE              = 64; // 2^6
	const int MAX_REGISTERS                       = 256; // 2^8
	const int MAX_LOCALS                          = 200; // maximum number of local variables
	const int MAX_UPVALUES                        = 200; // maximum number of upvalues
	const int MAX_INLINE_INT                      = 131072; // 32 - 6 (OPCODE) - 8 (register) - 1 bit sign = 17
	const int MAX_FIELDSxFLUSH                    = 64; // used in list/map serialization
	const int MAX_IVARS                           = 768; // 2^10 - 2^8
	const int MAX_ALLOCATION                      = 4194304; // 1024 * 1024 * 4 (about 4 millions entry)
	const int MAX_CCALLS                          = 100; // default maximum number of nested C calls
	const int MAX_MEMORY_BLOCK                    = 157286400; // 150MB

	const int DEFAULT_CONTEXT_SIZE                = 256; // default VM context entries (can grow)
	const int DEFAULT_MINSTRING_SIZE              = 32; // minimum string allocation size
	const int DEFAULT_MINSTACK_SIZE               = 256; // sizeof(gravity_value_t) * 256     = 16 * 256 => 4 KB
	const int DEFAULT_MINCFRAME_SIZE              = 32; // sizeof(gravity_callframe_t) * 48  = 32 * 48 => 1.5 KB
	const int DEFAULT_CG_THRESHOLD                = 5 * 1024 * 1024; // 5MB
	const int DEFAULT_CG_MINTHRESHOLD             = 1024 * 1024; // 1MB
	const float DEFAULT_CG_RATIO                  = 0.5f; // 50%

	// #define MAXNUM(a,b)                         ((a) > (b) ? a : b)
	// #define MINNUM(a,b)                         ((a) < (b) ? a : b)
	const float EPSILON                            = 0.000001f;
	const int MIN_LIST_RESIZE                      = 12; // value used when a List is resized

	/*const uint GRAVITY_DATA_REGISTER               = UINT32_MAX;
	const uint GRAVITY_FIBER_REGISTER              = UINT32_MAX - 1;
	const uint GRAVITY_MSG_REGISTER                = UINT32_MAX - 2;

	const uint GRAVITY_BRIDGE_INDEX                = UINT16_MAX;
	const uint GRAVITY_COMPUTED_INDEX              = UINT16_MAX - 1;*/

	// MARK: - STRUCT -

	// FLOAT_MAX_DECIMALS FROM https://stackoverflow.com/questions/13542944/how-many-significant-digits-have-floats-and-doubles-in-java
#if GRAVITY_ENABLE_DOUBLE
	typealias gravity_float_t                   	= double;
	const double GRAVITY_FLOAT_MAX                 	= DBL_MAX;
	const double GRAVITY_FLOAT_MIN                 	= DBL_MIN;
	const int FLOAT_MAX_DECIMALS                	= 16;
	const float FLOAT_EPSILON                   	= 0.00001;
#else
	typealias gravity_float_t                   	= float;
	//const float GRAVITY_FLOAT_MAX               	= FLT_MAX;
	//const float GRAVITY_FLOAT_MIN                   = FLT_MIN;
	const int FLOAT_MAX_DECIMALS                  	= 7;
	const float FLOAT_EPSILON                       = 0.00001f;
#endif

#if GRAVITY_ENABLE_INT64
	typedef int64_t                             = gravity_int_t;
	const int GRAVITY_INT_MAX                   = 9223372036854775807;
	const int GRAVITY_INT_MIN                   = (-GRAVITY_INT_MAX-1LL);
#else
	typealias gravity_int_t = int32_t;
	const int GRAVITY_INT_MAX                   = 2147483647;
	const int GRAVITY_INT_MIN                   = -2147483648;
#endif

	[CRepr]
	public struct gravity_object_t;

	[CRepr, Union]
	public struct gravity_slot_t
	{
		public gravity_int_t       	n; // integer slot
		public gravity_float_t     	f; // float/double slot
		public gravity_object_t*   	p; // ptr to object slot
	}

	// Everything inside Gravity VM is a gravity_value_t struct
	[CRepr]
	public struct gravity_value_t
	{
		public gravity_class_t* isa; // EVERY object must have an ISA pointer (8 bytes on a 64bit system) [Union] struct

		// union takes 8 bytes on a 64bit system
		public gravity_slot_t p;
	}

	// All VM shares the same foundation classes
	/*typealias gravity_class_object = gravity_class_t*;
	typealias gravity_class_bool = gravity_class_t*;
	typealias gravity_class_null = gravity_class_t*;
	typealias gravity_class_int = gravity_class_t*;
	typealias gravity_class_float = gravity_class_t*;
	typealias gravity_class_function = gravity_class_t*;
	typealias gravity_class_closure = gravity_class_t*;
	typealias gravity_class_fiber = gravity_class_t*;
	typealias gravity_class_class = gravity_class_t*;
	typealias gravity_class_string = gravity_class_t*;
	typealias gravity_class_instance = gravity_class_t*;
	typealias gravity_class_list = gravity_class_t*;
	typealias gravity_class_map = gravity_class_t*;
	typealias gravity_class_module = gravity_class_t*;
	typealias gravity_class_range = gravity_class_t*;
	typealias gravity_class_upvalue = gravity_class_t*;*/

	// typedef marray_t(gravity_value_t)        gravity_value_r;   // array of values
	[CRepr]
	public struct gravity_value_r
	{
		size_t n, m; gravity_value_t* p;
	}

	[CRepr]
	public struct gravity_vm; // vm is an opaque data type

	function bool gravity_c_internal(gravity_vm* vm, gravity_value_t* args, uint16_t nargs, uint32_t rindex);

	function uint32_t gravity_gc_callback(gravity_vm* vm, gravity_object_t* obj);

	[CRepr]
	public enum gravity_special_index
	{
		EXEC_TYPE_SPECIAL_GETTER = 0, // index inside special gravity_function_t union to represent getter func
		EXEC_TYPE_SPECIAL_SETTER = 1, // index inside special gravity_function_t union to represent setter func
	}

	[CRepr]
	public enum gravity_exec_type
	{
		EXEC_TYPE_NATIVE, // native gravity code (can change stack)
		EXEC_TYPE_INTERNAL, // c internal code (can change stack)
		EXEC_TYPE_BRIDGED, // external code to be executed by delegate (can change stack)
		EXEC_TYPE_SPECIAL // special execution like getter and setter (can be NATIVE, INTERNAL)
	}

	public struct gravity_gc_t
	{
		bool                    isdark; // flag to check if object is reachable
		bool                    visited; // flag to check if object has already been counted in memory size
		gravity_gc_callback     free; // free callback
		gravity_gc_callback     size; // size callback
		gravity_gc_callback     blacken; // blacken callback
		gravity_object_t        * next; // to track next object in the linked list
	}

	[CRepr]
	public struct gravity_function_t
	{
		gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector

		void                    * xdata; // extra bridged data
		char                    * identifier; // function name
		uint16_t                nparams; // number of formal parameters
		uint16_t                nlocals; // number of local variables
		uint16_t                ntemps; // number of temporary values used
		uint16_t                nupvalues; // number of up values (if any)
		gravity_exec_type       tag; // can be EXEC_TYPE_NATIVE (default), EXEC_TYPE_INTERNAL, EXEC_TYPE_BRIDGED or EXEC_TYPE_SPECIAL [Union] struct


		/**/ [Union] struct
		{
			// tag == EXEC_TYPE_NATIVE
			struct
			{
				gravity_value_r cpool; // constant pool
				gravity_value_r pvalue; // default param value
				gravity_value_r pname; // param names
				uint32_t        ninsts; // number of instructions in the bytecode
				uint32_t        * bytecode; // bytecode as array of 32bit values
				uint32_t        * lineno; // debug: line number <-> current instruction relation
				float           purity; // experimental value
				bool            useargs; // flag set by the compiler to optimize the creation of the arguments array only if needed
			};

			// tag == EXEC_TYPE_INTERNAL
			gravity_c_internal internal_cb; // function callback

			// tag == EXEC_TYPE_SPECIAL
			struct
			{
				uint16_t        index; // property index to speed-up default getter and setter
				void*[2] 		special; // getter/setter functions
			};
		};
	}

	[CRepr]
	public struct gravity_upvalue_t
	{
		gravity_class_t             * isa; // to be an object
		gravity_gc_t                gc; // to be collectable by the garbage collector

		gravity_value_t             * value; // ptr to open value on the stack or to closed value on this struct
		gravity_value_t             closed; // copy of the value once has been closed
		gravity_upvalue_t    		* next; // ptr to the next open upvalue
	}

	[CRepr]
	public struct gravity_closure_t
	{
		public gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector

		gravity_vm              * vm; // vm bound to this closure (useful when executed from a bridge)
		gravity_function_t      * f; // function prototype
		gravity_object_t        * context; // context where the closure has been created (or object bound by the user)
		gravity_upvalue_t       ** upvalue; // upvalue array
		uint32_t                refcount; // bridge language sometimes needs to protect closures from GC
	}

	[CRepr]
	public struct gravity_list_t
	{
		gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector

		gravity_value_r         array; // dynamic array of values
	}

	[CRepr]
	public struct gravity_map_t
	{
		gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector

		gravity_hash_t          * hash; // hash table
	}

	// Call frame used for function call
	[CRepr]
	public struct gravity_callframe_t
	{
		uint32_t                * ip; // instruction pointer
		uint32_t                dest; // destination register that will receive result
		uint16_t                nargs; // number of effective arguments passed to the function
		gravity_list_t          * args; // implicit special _args array
		gravity_closure_t       * closure; // closure being executed
		gravity_value_t         * stackstart; // first stack slot used by this call frame (receiver, plus parameters, locals and temporaries)
		bool                    outloop; // special case for events or native code executed from C that must be executed separately
	}

	[CRepr]
	public enum gravity_fiber_status
	{
		FIBER_NEVER_EXECUTED = 0,
		FIBER_ABORTED_WITH_ERROR = 1,
		FIBER_TERMINATED = 2,
		FIBER_RUNNING = 3,
		FIBER_TRYING = 4
	}

	// Fiber is the core executable model
	[CRepr]
	public struct gravity_fiber_t
	{
		gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector

		gravity_value_t         * stack; // stack buffer (grown as needed and it holds locals and temps)
		gravity_value_t         * stacktop; // current stack ptr
		uint32_t                stackalloc; // number of allocated values

		gravity_callframe_t     * frames; // callframes buffer (grown as needed but never shrinks)
		uint32_t                nframes; // number of frames currently in use
		uint32_t                framesalloc; // number of allocated frames

		gravity_upvalue_t       * upvalues; // linked list used to keep track of open upvalues

		char                    * error; // runtime error message
		bool                    trying; // set when the try flag is set by the user
		gravity_fiber_t         * caller; // optional caller fiber
		gravity_value_t         result; // end result of the fiber

		gravity_fiber_status    status; // Fiber status (see enum)
		nanotime_t              lasttime; // last time Fiber has been called
		gravity_float_t         timewait; // used in yieldTime
		gravity_float_t         elapsedtime; // time passed since last execution
	};

	[CRepr]
	public struct gravity_class_t
	{
		public gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector

		gravity_class_t         * objclass; // meta class
		char                    * identifier; // class name
		bool                    has_outer; // flag used to automatically set ivar 0 to outer class (if any)
		bool                    is_struct; // flag to mark class as a struct
		bool                    is_inited; // flag used to mark already init meta-classes (to be improved)
		bool                    unused; // unused padding byte
		void                    * xdata; // extra bridged data
		gravity_class_t         * superclass; // reference to the super class
		char                    * superlook; // when a superclass is set to extern a runtime lookup must be performed
		gravity_hash_t          * htable; // hash table
		uint32_t                nivars; // number of instance variables
		//gravity_value_r			inames;			    // ivar names
		gravity_value_t         * ivars; // static variables
	}

	[CRepr]
	public struct gravity_module_t
	{
		gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector

		char                    * identifier; // module name
		gravity_hash_t          * htable; // hash table
	}

	[CRepr]
	public struct gravity_instance_t
	{
		gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector

		gravity_class_t         * objclass; // real instance class
		void                    * xdata; // extra bridged data
		gravity_value_t         * ivars; // instance variables
	}

	[CRepr]
	public struct  gravity_string_t
	{
		gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector

		char                    * s; // pointer to NULL terminated string
		uint32_t                hash; // string hash (type to be keept in sync with gravity_hash_size_t)
		uint32_t                len; // actual string length
		uint32_t                alloc; // bytes allocated for string
	}

	[CRepr]
	public struct gravity_range_t
	{
		gravity_class_t         * isa; // to be an object
		gravity_gc_t            gc; // to be collectable by the garbage collector
		gravity_int_t           from; // range start
		gravity_int_t           to; // range end
	}

	public function void code_dump_function(void* code);
	// function marray_t(gravity_function_t*)   gravity_function_r;     // array of functions
	// function marray_t(gravity_class_t*)      gravity_class_r;        // array of classes
	// function marray_t(gravity_object_t*)     gravity_object_r;       // array of objects

	// MARK: - MODULE -
	[CLink] public static extern gravity_module_t   * gravity_module_new(gravity_vm* vm, char* identifier);
	[CLink] public static extern void                gravity_module_free(gravity_vm* vm, gravity_module_t* m);
	[CLink] public static extern void                gravity_module_blacken(gravity_vm* vm, gravity_module_t* m);
	[CLink] public static extern uint32_t            gravity_module_size(gravity_vm* vm, gravity_module_t* m);

	// MARK: - FUNCTION -
	[CLink] public static extern uint32_t           * gravity_bytecode_deserialize(char* buffer, size_t len, uint32_t* ninst);
	[CLink] public static extern void                gravity_function_blacken(gravity_vm* vm, gravity_function_t* f);
	[CLink] public static extern uint16_t            gravity_function_cpool_add(gravity_vm* vm, gravity_function_t* f, gravity_value_t v);
	[CLink] public static extern gravity_value_t     gravity_function_cpool_get(gravity_function_t* f, uint16_t i);
	[CLink] public static extern gravity_function_t* gravity_function_deserialize(gravity_vm* vm, json_value* json);
	[CLink] public static extern void                gravity_function_dump(gravity_function_t* f, code_dump_function codef);
	[CLink] public static extern void                gravity_function_free(gravity_vm* vm, gravity_function_t* f);
	[CLink] public static extern gravity_function_t* gravity_function_new(gravity_vm* vm, char* identifier, uint16_t nparams, uint16_t nlocals, uint16_t ntemps, void* code);
	[CLink] public static extern gravity_function_t* gravity_function_new_bridged(gravity_vm* vm, char* identifier, void* xdata);
	[CLink] public static extern gravity_function_t* gravity_function_new_internal(gravity_vm* vm, char* identifier, gravity_c_internal exec, uint16_t nparams);
	[CLink] public static extern gravity_function_t* gravity_function_new_special(gravity_vm* vm, char* identifier, uint16_t index, void* getter, void* setter);
	[CLink] public static extern gravity_list_t     * gravity_function_params_get(gravity_vm* vm, gravity_function_t* f);
	[CLink] public static extern void                gravity_function_serialize(gravity_function_t* f, json_t* json);
	[CLink] public static extern void                gravity_function_setouter(gravity_function_t* f, gravity_object_t* outer);
	[CLink] public static extern void                gravity_function_setxdata(gravity_function_t* f, void* xdata);
	[CLink] public static extern uint32_t            gravity_function_size(gravity_vm* vm, gravity_function_t* f);

	// MARK: - CLOSURE -
	[CLink] public static extern void                gravity_closure_blacken(gravity_vm* vm, gravity_closure_t* closure);
	[CLink] public static extern void                gravity_closure_dec_refcount(gravity_vm* vm, gravity_closure_t* closure);
	[CLink] public static extern void                gravity_closure_inc_refcount(gravity_vm* vm, gravity_closure_t* closure);
	[CLink] public static extern void                gravity_closure_free(gravity_vm* vm, gravity_closure_t* closure);
	[CLink] public static extern uint32_t            gravity_closure_size(gravity_vm* vm, gravity_closure_t* closure);
	[CLink] public static extern gravity_closure_t  * gravity_closure_new(gravity_vm* vm, gravity_function_t* f);

	// MARK: - UPVALUE -
	[CLink] public static extern void                gravity_upvalue_blacken(gravity_vm* vm, gravity_upvalue_t* upvalue);
	[CLink] public static extern void                gravity_upvalue_free(gravity_vm* vm, gravity_upvalue_t* upvalue);
	[CLink] public static extern gravity_upvalue_t  * gravity_upvalue_new(gravity_vm* vm, gravity_value_t* value);
	[CLink] public static extern uint32_t            gravity_upvalue_size(gravity_vm* vm, gravity_upvalue_t* upvalue);

	// MARK: - CLASS -
	[CLink] public static extern void                gravity_class_blacken(gravity_vm* vm, gravity_class_t* c);
	[CLink] public static extern int16_t             gravity_class_add_ivar(gravity_class_t* c, char* identifier);
	[CLink] public static extern void                gravity_class_bind(gravity_class_t* c, char* key, gravity_value_t value);
	[CLink] public static extern uint32_t            gravity_class_count_ivars(gravity_class_t* c);
	[CLink] public static extern gravity_class_t    * gravity_class_deserialize(gravity_vm* vm, json_value* json);
	[CLink] public static extern void                gravity_class_dump(gravity_class_t* c);
	[CLink] public static extern void                gravity_class_free(gravity_vm* vm, gravity_class_t* c);
	[CLink] public static extern void                gravity_class_free_core(gravity_vm* vm, gravity_class_t* c);
	[CLink] public static extern gravity_class_t    * gravity_class_get_meta(gravity_class_t* c);
	[CLink] public static extern gravity_class_t    * gravity_class_getsuper(gravity_class_t* c);
	[CLink] public static extern bool                gravity_class_grow(gravity_class_t* c, uint32_t n);
	[CLink] public static extern bool                gravity_class_is_anon(gravity_class_t* c);
	[CLink] public static extern bool                gravity_class_is_meta(gravity_class_t* c);
	[CLink] public static extern gravity_object_t   * gravity_class_lookup(gravity_class_t* c, gravity_value_t key);
	[CLink] public static extern gravity_closure_t  * gravity_class_lookup_closure(gravity_class_t* c, gravity_value_t key);
	[CLink] public static extern gravity_closure_t  * gravity_class_lookup_constructor(gravity_class_t* c, uint32_t nparams);
	[CLink] public static extern gravity_class_t    * gravity_class_lookup_class_identifier(gravity_class_t* c, char* identifier);
	[CLink] public static extern gravity_class_t    * gravity_class_new_pair(gravity_vm* vm, char* identifier, gravity_class_t* superclass, uint32_t nivar, uint32_t nsvar);
	[CLink] public static extern gravity_class_t    * gravity_class_new_single(gravity_vm* vm, char* identifier, uint32_t nfields);
	[CLink] public static extern void                gravity_class_serialize(gravity_class_t* c, json_t* json);
	[CLink] public static extern bool                gravity_class_setsuper(gravity_class_t* subclass, gravity_class_t* superclass);
	[CLink] public static extern bool                gravity_class_setsuper_extern(gravity_class_t* baseclass, char* identifier);
	[CLink] public static extern void                gravity_class_setxdata(gravity_class_t* c, void* xdata);
	[CLink] public static extern uint32_t            gravity_class_size(gravity_vm* vm, gravity_class_t* c);

	// MARK: - FIBER -
	[CLink] public static extern void                gravity_fiber_blacken(gravity_vm* vm, gravity_fiber_t* fiber);
	[CLink] public static extern void                gravity_fiber_free(gravity_vm* vm, gravity_fiber_t* fiber);
	[CLink] public static extern gravity_fiber_t    * gravity_fiber_new(gravity_vm* vm, gravity_closure_t* closure, uint32_t nstack, uint32_t nframes);
	[CLink] public static extern void                gravity_fiber_reassign(gravity_fiber_t* fiber, gravity_closure_t* closure, uint16_t nargs);
	[CLink] public static extern void                gravity_fiber_reset(gravity_fiber_t* fiber);
	[CLink] public static extern void                gravity_fiber_seterror(gravity_fiber_t* fiber, char* error);
	[CLink] public static extern uint32_t            gravity_fiber_size(gravity_vm* vm, gravity_fiber_t* fiber);

	// MARK: - INSTANCE -
	[CLink] public static extern void                gravity_instance_blacken(gravity_vm* vm, gravity_instance_t* i);
	[CLink] public static extern gravity_instance_t* gravity_instance_clone(gravity_vm* vm, gravity_instance_t* src_instance);
	[CLink] public static extern void                gravity_instance_deinit(gravity_vm* vm, gravity_instance_t* i);
	[CLink] public static extern void                gravity_instance_free(gravity_vm* vm, gravity_instance_t* i);
	[CLink] public static extern bool                gravity_instance_isstruct(gravity_instance_t* i);
	[CLink] public static extern gravity_closure_t  * gravity_instance_lookup_event(gravity_instance_t* i, char* name);
	[CLink] public static extern gravity_value_t     gravity_instance_lookup_property(gravity_vm* vm, gravity_instance_t* i, gravity_value_t key);
	[CLink] public static extern gravity_instance_t* gravity_instance_new(gravity_vm* vm, gravity_class_t* c);
	[CLink] public static extern void                gravity_instance_serialize(gravity_instance_t* i, json_t* json);
	[CLink] public static extern void                gravity_instance_setivar(gravity_instance_t* instance, uint32_t idx, gravity_value_t value);
	[CLink] public static extern void                gravity_instance_setxdata(gravity_instance_t* i, void* xdata);
	[CLink] public static extern uint32_t            gravity_instance_size(gravity_vm* vm, gravity_instance_t* i);

	// MARK: - VALUE -
	[CLink] public static extern void                gravity_value_blacken(gravity_vm* vm, gravity_value_t v);
	[CLink] public static extern void                gravity_value_dump(gravity_vm* vm, gravity_value_t v, char* buffer, uint16_t len);
	[CLink] public static extern bool                gravity_value_equals(gravity_value_t v1, gravity_value_t v2);
	[CLink] public static extern void                gravity_value_free(gravity_vm* vm, gravity_value_t v);
	[CLink] public static extern gravity_class_t    * gravity_value_getclass(gravity_value_t v);
	[CLink] public static extern gravity_class_t    * gravity_value_getsuper(gravity_value_t v);
	[CLink] public static extern uint32_t            gravity_value_hash(gravity_value_t value);
	[CLink] public static extern bool                gravity_value_isobject(gravity_value_t v);
	[CLink] public static extern char               * gravity_value_name(gravity_value_t value);
	[CLink] public static extern void                gravity_value_serialize(char* key, gravity_value_t v, json_t* json);
	[CLink] public static extern uint32_t            gravity_value_size(gravity_vm* vm, gravity_value_t v);
	[CLink] public static extern bool                gravity_value_vm_equals(gravity_vm* vm, gravity_value_t v1, gravity_value_t v2);
	[CLink] public static extern void               * gravity_value_xdata(gravity_value_t value);

	[CLink] public static extern gravity_value_t     gravity_value_from_bool(bool b);
	[CLink] public static extern gravity_value_t     gravity_value_from_error(char* msg);
	[CLink] public static extern gravity_value_t     gravity_value_from_float(gravity_float_t f);
	[CLink] public static extern gravity_value_t     gravity_value_from_int(gravity_int_t n);
	[CLink] public static extern gravity_value_t     gravity_value_from_null(void);
	[CLink] public static extern gravity_value_t     gravity_value_from_object(void* obj);
	[CLink] public static extern gravity_value_t     gravity_value_from_undefined(void);

	// MARK: - OBJECT -
	[CLink] public static extern void                gravity_object_blacken(gravity_vm* vm, gravity_object_t* obj);
	[CLink] public static extern char               * gravity_object_debug(gravity_object_t* obj, bool is_free);
	[CLink] public static extern gravity_object_t   * gravity_object_deserialize(gravity_vm* vm, json_value* entry);
	[CLink] public static extern void                gravity_object_free(gravity_vm* vm, gravity_object_t* obj);
	[CLink] public static extern void                gravity_object_serialize(gravity_object_t* obj, json_t* json);
	[CLink] public static extern uint32_t            gravity_object_size(gravity_vm* vm, gravity_object_t* obj);

	// MARK: - LIST -
	[CLink] public static extern void                gravity_list_append_list(gravity_vm* vm, gravity_list_t* list1, gravity_list_t* list2);
	[CLink] public static extern void                gravity_list_blacken(gravity_vm* vm, gravity_list_t* list);
	[CLink] public static extern void                gravity_list_free(gravity_vm* vm, gravity_list_t* list);
	[CLink] public static extern gravity_list_t     * gravity_list_from_array(gravity_vm* vm, uint32_t n, gravity_value_t* p);
	[CLink] public static extern gravity_list_t     * gravity_list_new(gravity_vm* vm, uint32_t n);
	[CLink] public static extern uint32_t            gravity_list_size(gravity_vm* vm, gravity_list_t* list);

	// MARK: - MAP -
	[CLink] public static extern void                gravity_map_blacken(gravity_vm* vm, gravity_map_t* map);
	[CLink] public static extern void                gravity_map_append_map(gravity_vm* vm, gravity_map_t* map1, gravity_map_t* map2);
	[CLink] public static extern void                gravity_map_free(gravity_vm* vm, gravity_map_t* map);
	[CLink] public static extern void                gravity_map_insert(gravity_vm* vm, gravity_map_t* map, gravity_value_t key, gravity_value_t value);
	[CLink] public static extern gravity_map_t      * gravity_map_new(gravity_vm* vm, uint32_t n);
	[CLink] public static extern uint32_t            gravity_map_size(gravity_vm* vm, gravity_map_t* map);

	// MARK: - RANGE -
	[CLink] public static extern void                gravity_range_blacken(gravity_vm* vm, gravity_range_t* range);
	[CLink] public static extern gravity_range_t    * gravity_range_deserialize(gravity_vm* vm, json_value* json);
	[CLink] public static extern void                gravity_range_free(gravity_vm* vm, gravity_range_t* range);
	[CLink] public static extern gravity_range_t    * gravity_range_new(gravity_vm* vm, gravity_int_t from, gravity_int_t to, bool inclusive);
	[CLink] public static extern void                gravity_range_serialize(gravity_range_t* r, json_t* json);
	[CLink] public static extern uint32_t            gravity_range_size(gravity_vm* vm, gravity_range_t* range);

	/// MARK: - STRING -
	[CLink] public static extern void                gravity_string_blacken(gravity_vm* vm, gravity_string_t* string);
	[CLink] public static extern void                gravity_string_free(gravity_vm* vm, gravity_string_t* value);
	[CLink] public static extern gravity_string_t   * gravity_string_new(gravity_vm* vm, char* s, uint32_t len, uint32_t alloc);
	[CLink] public static extern void                gravity_string_set(gravity_string_t* obj, char* s, uint32_t len);
	[CLink] public static extern uint32_t            gravity_string_size(gravity_vm* vm, gravity_string_t* string);
	[CLink] public static extern gravity_value_t     gravity_string_to_value(gravity_vm* vm, char* s, uint32_t len);
}