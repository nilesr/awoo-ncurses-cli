require 'ncurses.rb'
require 'dangeru'
require_relative 'utils.rb'
require_relative 'make_menu.rb'
puts "Fetching boards..."
api = Dangeru.new("dangeru.us", true)
cookie = nil
boards = JSON.parse((api.get Dangeru::API + "/boards", cookie).body)
while (board_idx = make_menu(boards, "danger/u/")) != -1
	board = boards[board_idx]
	loading
	puts "Loading board " + board
	threads = api.get_board board
	thread_names = threads.map do |x| x["title"] end
	while (thread_idx = make_menu(thread_names, make_title(board, api, cookie))) != -1
		thread = threads[thread_idx]
		loading
		puts "Loading thread " + thread["post_id"].to_s + " - " + thread["title"]
		#
	end
end
