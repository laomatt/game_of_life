class NilClass
	def [] arg
		nil
	end
end

class GameBoard
	def initialize(rank)
		@rank = rank

		@current_matrix = []
		rank.times do |a|
			row = []
			rank.times do |b|
				row << "[   ]"
			end
			@current_matrix << row
		end
	end

	def input_matrix(char)
		random_row_placement = rand @rank
		random_column_placement = rand @rank

		matrix = []
		row_counter = 0

		@rank.times do |a|
			row = []
			column_counter = 0
			@rank.times do |b|
				if @current_matrix[row_counter][column_counter].include?(char)|| (
						(column_counter == random_column_placement) && 
						(row_counter == random_row_placement)
					)
					row << " #{char} "
				else
					row << "   "
				end
				column_counter += 1
			end

			row_counter += 1
			matrix << row
		end

		@current_matrix = matrix
	end


	def display
		output = ""
		@current_matrix.each do |row|
			output += "#{row.join(' ')}" + "\n"
		end

		print "#{output} \r"
	end

	def apply_rules
		# Any live cell with fewer than two live neighbors dies, as if by underpopulation.
		# Any live cell with two or three live neighbors lives on to the next generation.
		# Any live cell with more than three live neighbors dies, as if by overpopulation.
		# Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.

		new_matrix = []


		@current_matrix.each_with_index do |row, y|
			new_row = []
			row.each_with_index do |cell, x|
				count = 0
				# find neighbors\[]
				[
					@current_matrix[y][x + 1],
					@current_matrix[y][x - 1],
					@current_matrix[y + 1][x + 1],
					@current_matrix[y + 1][x - 1],
					@current_matrix[y + 1][x],
					@current_matrix[y - 1][x + 1],
					@current_matrix[y - 1][x - 1],
					@current_matrix[y - 1][x]
				].compact.each do |neighbor|
					if neighbor.include?("*")
						count += 1
					end
				end

				# decide fate
				next_gen = begin
					if cell.include?("*")
						if count < 2
							"   "
						elsif count == 2 || count == 3
							" * "
						else
							"   "
						end
					else
						if count == 3
							" * "
						else
							"   "
						end
					end
				end

				# build new matrix
				new_row << next_gen
			end

			new_matrix << new_row
		end

		# replace current matrix

		@current_matrix = new_matrix
	end

	def run
		print  "\r" + ("\e[A\e[K"*@rank)
		apply_rules
		display
	end

	def initialize_board amt
		amt.times do 
			print  "\r" + ("\e[A\e[K"*@rank)
			input_matrix "*"
			display
		end

		print "\n"
		print "\n"
		print "\n"
		print "\n"*@rank
	end

	def play
		while true do 
			run
			sleep(1)
		end
	end
end

b = GameBoard.new(40)
b.initialize_board 700
b.play
