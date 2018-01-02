require_relative 'utils.rb'
ReplyStruct = Struct.new :title, :capcode, :comment
def make_form post, reply
	initscr
	Ncurses.cbreak
	Ncurses.noecho
	Ncurses.keypad Ncurses::stdscr, true

	if not reply
		title = Ncurses::Form::FIELD.new 1, 50, 2, 4, 0, 0
	end
	#capcode = Ncurses::Form::FIELD.new 1, 50, 4, 4, 0, 0
	comment = Ncurses::Form::FIELD.new 4, 50, 6, 4, 0, 0
	# TODO prepopulate with >>post if present
	comment.opts_off Ncurses::Form::O_STATIC
	submit = Ncurses::Form::FIELD.new 1, 1, 10, 55, 0, 0
	all_fields = [comment, submit
			   #, capcode
	]
	if not reply
		all_fields << title
	end
	all_fields.each do |field|
		Ncurses::Form.set_field_back field, Ncurses::A_UNDERLINE
		field.opts_off Ncurses::Form::O_AUTOSKIP
		field.set_field_back Ncurses::COLOR_PAIR(6)
		field.set_field_fore Ncurses::COLOR_PAIR(7)
	end
	submit.set_field_fore Ncurses::COLOR_PAIR(5)

	form = Ncurses::Form::FORM.new all_fields
	form.post_form
	Ncurses.refresh
	if not reply
		Ncurses.mvprintw 1, 4, "Title"
	end
	#Ncurses.mvprintw 3, 4, "Capcode"
	Ncurses.mvprintw 5, 4, "Comment"
	Ncurses.mvprintw 10, 54, "["
	Ncurses.mvprintw 10, 56, "] Check this box to submit"
	Ncurses.mvprintw 11, 58, "(then go back to the other field because ncurses is buggy as hell)"
	Ncurses.refresh

	while (c = Ncurses.getch) != 27 # escape
		case c
		when Ncurses::KEY_DOWN
			form.form_driver Ncurses::Form::REQ_NEXT_FIELD
			form.form_driver Ncurses::Form::REQ_END_LINE
		when Ncurses::KEY_UP
			form.form_driver Ncurses::Form::REQ_PREV_FIELD
			form.form_driver Ncurses::Form::REQ_END_LINE
		when Ncurses::KEY_LEFT
			form.form_driver(Ncurses::Form::REQ_PREV_CHAR);
		when Ncurses::KEY_RIGHT, Ncurses::KEY_STAB
			form.form_driver(Ncurses::Form::REQ_NEXT_CHAR);
		when Ncurses::KEY_BACKSPACE
			form.form_driver(Ncurses::Form::REQ_DEL_PREV);
		when "\n".getbyte(0)
			form.form_driver(Ncurses::Form::REQ_NEW_LINE);
		else
			form.form_driver c
		end
		if Ncurses::Form.field_status submit
			break
		end
		Ncurses.refresh
	end
	Ncurses.endwin
	title_str = ""
	if not reply
		title_str = title.buffer(0)
	end
	return ReplyStruct.new title_str, "", comment.buffer(0)
end
