require_relative 'utils.rb'

def make_menu(items, title, generator)
	initscr
	height = 20
	#height = max(Ncurses.LINES - 2, height)
	height = Ncurses.LINES - 6
	Ncurses.cbreak
	Ncurses.noecho
	Ncurses.keypad Ncurses::stdscr, true

	items = generator.call items
	menu = Ncurses::Menu::MENU.new items
	menu.set_menu_fore Ncurses.COLOR_PAIR 3
	menu.set_menu_grey Ncurses.COLOR_PAIR 2
	menu.opts_off Ncurses::Menu::O_SHOWDESC
	menu_win = Ncurses.newwin height, Width, 4, 4
	Ncurses.keypad menu_win, true
	menu.set_menu_win menu_win
	menu.set_menu_sub Ncurses.derwin(menu_win, height - 4, Width - 2, 3, 1)
	menu.set_menu_format height - 4, 1
	menu.set_menu_mark "> "

	Ncurses.box(menu_win, 0, 0)
	menu_win.mvaddch 2, 0, Ncurses::ACS_LTEE
	menu_win.mvhline 2, 1, Ncurses::ACS_HLINE, Width - 2
	menu_win.mvaddch 2, Width - 1, Ncurses::ACS_RTEE
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
			Ncurses.endwin
			return menu.current_item.user_object
		when "q".getbyte(0), Ncurses::KEY_LEFT, 27 # escape
			Ncurses.endwin
			return -1
		when Ncurses::KEY_NPAGE
			menu.menu_driver Ncurses::Menu::REQ_SCR_DPAGE
		when Ncurses::KEY_PPAGE
			menu.menu_driver Ncurses::Menu::REQ_SCR_UPAGE
		else
			;
		end
		menu_win.refresh
	end
end
