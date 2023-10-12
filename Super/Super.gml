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
#macro __SUPER__ static __super__ = new __super(_GMFUNCTION_); __super.__self__ = self; __super__
function __super(_func_name) constructor {
	static __self__ = undefined;
	var _found = false;
	
	//this is only ever true when a constructor it's self is calling super
	if (asset_get_index(_func_name) != -1) {
		var _str = _func_name;
		_found = true
		var _statics = static_get(asset_get_index(_func_name))
	}
	else { //else we are calling from inside a function
		
		#region grab the callstack
		
			static is_browser = (os_browser != browser_not_a_browser);
			if (!is_browser) {
				var _callback = debug_get_callstack(2)[1];
			}
			else {
				//on html5 the callstack includes "__yy_gml_object_create"
				var _callback = debug_get_callstack(3)[2];
			}
		
			//support for when the compiled code doesnt return the line number ":40" on the suffix
			var _str = _callback;
			var _pos = string_pos(":", _callback);
			if (_pos != 0) {
				var _str = string_copy(_callback, 1, _pos-1);
			}
		
		#endregion
	
		#region Blank GML struct
			//this is used as a massive work around for html5 lacking support for `instanceof(_statics)`
			// in the future uncomment out the parent struct name != object lines
			static __blank_constructor__ = function() constructor {};
			static __blank_object__ = new __blank_constructor__();
			static __object_statics__ = static_get(static_get(__blank_object__));
			///////////////////////////////////////////////////////////////////////////////////////////
		#endregion
	
		//start instantly by grabbing the parent
		var _statics = static_get(other);
	
		var _calling_func_index = real(asset_get_index(_str));
		
		//loop through parents until we find the one which contain's this callstack
		while (_statics != __object_statics__) {
		
			var _names = struct_get_names(_statics);
			var _i=0; repeat(array_length(_names)) {
				var _key = _names[_i]
				var _value_index = method_get_index(_statics[$ _key])
				if (_value_index == _calling_func_index) {
					_found = true;
					break;
				}
			_i+=1;}//end repeat loop
		
			if (_found) { break; };
		
			_statics = static_get(_statics);
		}
	
	}
	
	if (!_found) { show_error($"`super` is being called when there is no static struct key with the matching function call,\nyou are only able to call `super` from inside a static function", true) };
	
	var _parent_statics = static_get(_statics);
	
	if (_parent_statics == __object_statics__) {
		show_error($"`super` called from inside a constructor which has no parents", true);
	}
	
	#region Find all parent structs
		
		while (__object_statics__ != _parent_statics) {
		
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
				
				//build a wrapper function so we can dynamically bind the method to the calling instance instead of who ever first called it.
				self[$ _key] = method({func: _val}, function(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15) {
					//run the function supplied with the given arguments
					return method(__super.__self__, func)(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15);
				})
				
			_i+=1;}//end repeat loop
			
			
			//continue to the next struct
			_parent_statics = static_get(_parent_statics);
		}
		
	#endregion
	
}
