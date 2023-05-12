#macro __SUPER__ __super(self)
function __super(_calling_inst) {
	
	#region grab the callstack
		var _callback = debug_get_callstack(2)[1];
		var _pos = string_pos(":", _callback);
		if (_pos != 0) {
			var _str = string_copy(_callback, 1, _pos-1);
		}
		else {
			//support for when the compiled code doesnt return the line number ":40" on the suffix
			var _str = _callback;
		}
	#endregion
	
	#region find the owner struct
		//it may already be the owner struct, but it could be a function inside the struct's function
		
		//if it's a function
		static _anon_func_str_header = "gml_Script_anon_"
		_pos = string_pos(_anon_func_str_header, _str)
		
		//anon function declaired inside a constructor
		if (_pos == 1) {
		  static _anon_func_str_tail = "_gml_GlobalScript_";
		  static _anon_func_header_end = string_length(_anon_func_str_header)+1;
		  var _tail_pos = string_pos(_anon_func_str_tail, _str);
		  _str = string_copy(_str, _anon_func_header_end, _tail_pos-_anon_func_header_end);
		}
		else {
			//calling from constructor it's self
			static _constructor_func_str_header = "gml_Script_"
			_pos = string_pos(_constructor_func_str_header, _str)
			if (_pos == 1) {
				static _constructor_header_end = string_length(_constructor_func_str_header);
		    _str = string_delete(_str, 1, _constructor_header_end);
			}
		}
		
		//there are probably a lot more i could add but they are either really bad practice or not currently possible
		
	#endregion
	
	var _methodID = asset_get_index(_str);
	var _parent_statics = static_get(static_get(_methodID))
	
	
	var _names = variable_struct_get_names(_parent_statics);
	var _super = {};
	
	var _key, _val;
	var _size = array_length(_names);
	var _i=0; repeat(_size) {
		_key = _names[_i]
		
		if (_key == "<unknown built-in variable>") {
			_i+=1;
			continue;
		}
		
		_val = _parent_statics[$ _key]
		
		//scope the function to the calling instance
		_super[$ _key] = (is_method(_val)) ? method(_calling_inst, _val) : _val;
		
	_i+=1;}//end repeat loop
	
	return _super;
}
