require 'ncurses.rb'
require 'dangeru'
require_relative 'utils.rb'
require_relative 'make_menu.rb'
puts "Fetching boards..."
api = Dangeru.new("dangeru.us", true)
cookie = nil
boards = JSON.parse((api.get Dangeru::API + "/boards", cookie).body)
make_items_l = -> (x) { make_items x}
while (board_idx = make_menu(boards, "danger/u/", make_items_l)) != -1
	board = boards[board_idx]
	loading
	puts "Loading board " + board
	threads = api.get_board board
	thread_names = threads.map do |x| x["title"] end
	while (thread_idx = make_menu(thread_names, make_title(board, api, cookie), make_items_l)) != -1
		thread = threads[thread_idx]
		loading
		puts "Loading thread " + thread["post_id"].to_s + " - " + thread["title"]
		replies = api.get_thread_replies thread["post_id"]
		result = make_menu replies, "/#{board}/ - #{thread["title"]}", ->(x) {make_thread_items x}
		if result == -1
			break
		end
		# TODO reply
	end
end
