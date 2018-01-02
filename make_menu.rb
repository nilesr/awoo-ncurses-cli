require_relative 'utils.rb'

def make_menu(items, title, generator)
	initscr
	height = 20
	width = 80
	height = max(Ncurses.LINES - 2, height)
	Ncurses.cbreak
	Ncurses.noecho
	Ncurses.keypad Ncurses::stdscr, true

	items = generator.call items
	menu = Ncurses::Menu::MENU.new items
	menu_win = Ncurses.newwin height, width, 4, 4
	Ncurses.keypad menu_win, true
	menu.set_menu_win menu_win
	menu.set_menu_sub Ncurses.derwin(menu_win, height - 4, width - 2, 3, 1)
	menu.set_menu_format height - 4, 1
	menu.set_menu_mark "> "

	Ncurses.box(menu_win, 0, 0)
	menu_win.mvaddch 2, 0, Ncurses::ACS_LTEE
	menu_win.mvhline 2, 1, Ncurses::ACS_HLINE, width - 2
	menu_win.mvaddch 2, width - 1, Ncurses::ACS_RTEE
	menu_win.attron Ncurses::COLOR_PAIR(1)
	menu_win.mvprintw 1, 2, title
	menu_win.attroff Ncurses::COLOR_PAIR(1)

	menu.post_menu
	menu_win.refresh

	while c = Ncurses.wgetch(menu_win)
		case c
		when Ncurses::KEY_DOWN
			menu.menu_driver Ncurses::Menu::REQ_DOWN_ITEM
		when Ncurses::KEY_UP
			menu.menu_driver Ncurses::Menu::REQ_UP_ITEM
		when Ncurses::KEY_RIGHT, "\n".getbyte(0), " ".getbyte(0)
			return menu.current_item.user_object
		when "q".getbyte(0), Ncurses::KEY_LEFT, 27 # escape
			return -1
		else
			;
		end
		menu_win.refresh
	end

	Ncurses.endwin
end
