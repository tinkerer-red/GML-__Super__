/// feather ignore all
#macro super static __super__ = __super(_GMFUNCTION_, self); __super__
function __super(_func_str, _caller) {
	
	var _func_ref = asset_get_index(_func_str)
	
	//init the loop with the original caller
	var _parent_str = instanceof(_caller);
	var _parent_ref = asset_get_index(_parent_str);
	
	while (_parent_ref != undefined) {
		
		//get the ref
		var _constructor_str = _parent_str;
		var _constructor_ref = asset_get_index(_constructor_str);
		
		#region Find Func Ref
		//check if the function ref exists in this struct
		var _statics = static_get(_constructor_ref);
		
		var _names = struct_get_names(_statics);
		var _i=0; repeat(array_length(_names)) {
			var _static_name = _names[_i];
			var _static_value = _statics[$ _static_name];
			
			//we need to transpose this function reference into a script reference
			var _static_ref = is_callable(_static_value) ? asset_get_index(script_get_name(_static_value)) : undefined;
			
			if (_static_ref == _func_ref) break;
			
		_i++}
		
		//if we found the ref, break out of the while loop
		if (_static_ref == _func_ref) break;
		
		#endregion
		
		#region Get Parent Constructor
		var _child_tags = asset_get_tags(_constructor_ref);
		var _parent_str = undefined;
		var _parent_ref = undefined;
	
		var i=0; repeat(array_length(_child_tags)) {
			var _tag = _child_tags[i];
		
			var _pos = string_pos("@@parent=", _tag)
			if (_pos) {
				_parent_str = string_delete(_tag, 0, 9);
				_parent_ref = asset_get_index(_parent_str);
				break;
			}
		
		i++;}
		#endregion
		
	}
	
	//if we found the func ref
	if (_static_ref == _func_ref) {
		//jump up one static
		var _parent_statics = static_get(_statics);
		
		if (!struct_exists(_parent_statics, _static_name)){
			show_error($"Found function `{_static_name}`, but parent constroctors do not contain this static name", true)
		}
		
		var _super_func_ref = struct_get(_parent_statics, _static_name);
		if (is_callable(_super_func_ref)) {
			return _super_func_ref
		}
		else {
			show_error($"Found function `{_static_name}`, but parent constroctors have non-callable variable, type: `{typeof(_super_func_ref)}`", true)
		}
	}
	else {
		show_error($"unable to find super() for function `{_func_str}`", true)
	}
	
}