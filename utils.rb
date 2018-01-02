require 'ncurses.rb'
Width = 80
def make_items arr
	index = 0
	r = []
	arr.each do |item|
		i = Ncurses::Menu::ITEM.new item, ""
		if not i
			next
		end
		i.user_object = index
		index += 1
		r.push i
	end
	r
end
def make_title board, api, cookie
	desc = JSON.parse((api.get Dangeru::API + "/board/#{board}/detail", cookie).body)["desc"]
	"/#{board}/ - #{desc}"
end
def initscr
	old = $VERBOSE
	$VERBOSE = nil
	Ncurses.initscr
	$VERBOSE = old
	Ncurses.start_color
	Ncurses.init_pair 1, Ncurses::COLOR_RED, Ncurses::COLOR_BLACK
	Ncurses.init_pair 2, Ncurses::COLOR_CYAN, Ncurses::COLOR_BLACK
	Ncurses.init_pair 3, Ncurses::COLOR_GREEN, Ncurses::COLOR_BLACK
	Ncurses.init_pair 4, Ncurses::COLOR_MAGENTA, Ncurses::COLOR_BLACK
	Ncurses.init_pair 5, Ncurses::COLOR_MAGENTA, Ncurses::COLOR_MAGENTA
	Ncurses.init_pair 6, Ncurses::COLOR_WHITE, Ncurses::COLOR_WHITE
	Ncurses.init_pair 7, Ncurses::COLOR_BLACK, Ncurses::COLOR_WHITE

	Ncurses.attron Ncurses::COLOR_PAIR(2)
	Ncurses.mvprintw 1, 2, "Arrow keys to select, right arrow, enter or space to select"
	Ncurses.mvprintw 2, 2, "left arrow, escape or q to go back. Page up and page down are also supported"
	Ncurses.attroff Ncurses::COLOR_PAIR(2)
	Ncurses.refresh
end
def max a, b
	a if a > b
	b
end
def make_thread_items arr
	r = []
	arr.each do |item|
		if item.has_key? "capcode"
			author = item["capcode"]
		else
			author = "Anonymous (#{item["hash"]})"
		end
		header = "#{author} No. #{item["post_id"]}"
		i = Ncurses::Menu::ITEM.new header, ""
		i.user_object = item["post_id"]
		r.push i
		first = "| "
		word_wrap(item["comment"] + "\n").each do |line|
			i = Ncurses::Menu::ITEM.new fix(first + line), ""
			if not i
				Ncurses.endwin
				puts "Critical error - Ncurses::Menu::Item.new returned nil"
				puts fix(first + line).inspect
				exit
			end
			first = ""
			i.user_object = item["post_id"]
			i.opts_off Ncurses::Menu::O_SELECTABLE
			r.push i
		end
	end
	i = Ncurses::Menu::ITEM.new "Reply", ""
	r.push i
	r
end
def fix str
	# this could be better
	r = str.gsub("\n", "").gsub("\r", "")
	if r == ""
		r = " "
	end
	r
end
def word_wrap str
	arr = str.each_line.to_a
	r = []
	arr.each do |line|
		rr = []
		running = ""
		line.split(" ").each do |word|
			if (running + " " + word).length > (Width - 6)
				rr.push running
				running = word
			else
				space = " "
				if running.length == 0
					space = ""
				end
				running += space + word
			end
		end
		rr << running
		r << rr
	end
	r.flatten
end
