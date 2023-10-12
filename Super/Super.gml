/// feather ignore all
//explanation:

// This line builds a struct which contains methods storing the function index of the parent statics
//		static __super__ = new __super();

// Because we want to avoid string manipulation every frame, we want to make that struct static
// Because that struct is static we need some way of refering to the object which should be running the method.
// So this line is used as essentially a "other.other.other" 
//		global.__super_self__ = self;

// Last we leave it with this line so it makes it easier to read in the sense of doing `__SUPER__.get_value()`
//		__super__
#macro __SUPER__ static __super__ = new __super(_GMFUNCTION_); global.__super_self__ = self; __super__
function __super(_func_name) constructor {
	//if we're calling from the base constructor, we already know it's name
	
	
	//used to break out once we have found a reliable answer
	repeat(1) {
		//this is only ever true when a constructor it's self is calling super
		if (asset_get_index(_func_name) != -1) {
			var _str = _func_name;
			log(["case 1 _str", _str])
			break;
		}
		
		//from here unfoertunately we have to guess a lot of it, though we can make some educated guesses
		
		//secondly if the naming convention sticks to the standards of camel case, we can find the last "_" check if the next charactor is upper case, and if so we will be pretty sure it's the full name of the constructor
		var _pos = string_last_pos("_", _func_name);
		//make sure the constructor doesnt end with a "_"
		if (_pos != string_length(_func_name))
		&& (_pos) {
			var _char = string_copy(_func_name, _pos+1, 1)
			if (_char == string_upper(_char)){
				var _str = string_copy(_func_name, _pos+1, string_length(_func_name)-_pos);
				if (asset_get_index(_str) != -1) {
					log(["case 2 _str", _str])
					break
				}
			}
		}
		
		//if there is only a single "_" we know the structure is `<function name>_<Constructo name>` like bar_Foo which would be Foo.bar()
		//given that this happens fairly rarely, we've deprioritized this check
		var _count = string_count("_", _func_name);
		if (_count == 1) {
			var _arr = string_split(_func_name, "_", false);
			var _str = _arr[1];
			if (asset_get_index(_str) != -1) {
				log(["case 1 _str", _str])
				break
			}
		}
		
		
		
		//cooincidently, if the constructor does end with a "_" likely because it's private, then we are in luck because we can simply find how many it has, then find the seppoerator for it. bar___Foo__ has 2 "_" on the end so we know somewhere in the string we will find 3 "_" in a row.
		var _pos = string_last_pos("_", _func_name);
		if (_pos = string_length(_func_name)) {
			var _current_index = _pos;
			while (string_char_at(_func_name, _current_index) == "_") {
				_current_index -= 1;
			}
			_current_index += 1;
			var _string_to_search = "_"+string_copy(_func_name, _current_index, string_length(_func_name)-_current_index+1);
			var _pos = string_pos(_string_to_search, _func_name)
			if (_pos) {
				var _str = string_copy(_func_name, _pos+1, string_length(_func_name)-_pos);
				if (asset_get_index(_str) != -1) {
					log(["case 4 _str", _str])
					break
				}
			}
		}
		
		//any other structure is very problematic, so as a last ditch effort, since we know the information provided will have the constructor at the very end, we loop backwards until we find a function of the same name. This is not ideal as a constructor of "A_B_C" will return the constructor "C"
		var _i=string_length(_func_name)-1;
		repeat(string_length(_func_name)-1) {
			var _str = string_copy(_func_name, _i, string_length(_func_name)-_i+1)
			if (asset_get_index(_str) != -1) {
				log(["case 5 _str", _str]);
				break
			}
		_i-=1}//end repeat loop
		
		if (asset_get_index(_str) != -1) {
			break
		}
		
		//else we should just drop an error message
		show_error($"Super string manipulation is unable to reliably find the constructor from the supplied function {_func_name} please consider using camel case for your constructor names", true);
	}
	
	var _parent_struct_name = _str;
	
	var _parent_methodID = asset_get_index(_parent_struct_name);
	var _statics = static_get(_parent_methodID);
	var _parent_statics = static_get(_statics);
	
	
	//this is used as a massive work around for html5 lacking support for `instanceof(_statics)`
	// in the future uncomment out the parent struct name != object lines
	static __blank_constructor__ = function() constructor {};
	static __blank_object__ = new __blank_constructor__();
	static __object_statics__ = static_get(static_get(__blank_object__));
	///////////////////////////////////////////////////////////////////////////////////////////
	
	#region Find all parent structs
		
		while (_parent_struct_name != "Object") {
		//while (__object_statics__ != _parent_statics) {
			
			var _key, _val;
			var _names = variable_struct_get_names(_parent_statics);
			var _size = array_length(_names);
			var _i=0; repeat(_size) {
				_key = _names[_i]
				
				//skip internal keys and already included keys
				if (_key == "<unknown built-in variable>")
				|| (variable_struct_exists(self, _key)) {
					_i+=1;
					continue;
				}
				
				_val = _parent_statics[$ _key]
				
				self[$ _key] = method({func: _val}, function(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15) {
					return method(global.__super_self__, func)(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15)
				})
				
			_i+=1;}//end repeat loop
			
			
			//continue to the next struct
			var _parent_struct_name = instanceof(_parent_statics)
			//_parent_statics = static_get(_parent_statics);
		}
		
	#endregion
	
}
