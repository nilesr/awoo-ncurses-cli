require 'ncurses.rb'
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
end
def loading
	initscr
	Ncurses.endwin
end
def max a, b
	a if a > b
	b
end
