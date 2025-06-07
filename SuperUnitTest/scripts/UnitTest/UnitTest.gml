function A() constructor {
	static print_name = function() {
		show_debug_message("A")
	}
}

function B() : A() constructor {
	static print_name = function() {
		super()
		show_debug_message("B")
	}
}

function C() : B() constructor {
	static print_name = function() {
		super()
		show_debug_message("C")
	}
}

var t = new C()
t.print_name()


