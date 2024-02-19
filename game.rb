require 'colorize'
require 'sequel'

class NilClass
	def [] arg
		nil
	end
end

class GameBoard
	def initialize(rank)
		@log = {}
		@rank = rank
		@step = 0
		@disp_char = '███'

		@current_matrix = []
		rank.times do |a|
			row = []
			rank.times do |b|
				row << " "
			end
			@current_matrix << row
		end
	end

	def input_matrix
		random_row_placement = rand @rank
		random_column_placement = rand @rank

		matrix = []
		row_counter = 0

		@rank.times do |a|
			row = []
			column_counter = 0
			@rank.times do |b|
				if @current_matrix[row_counter][column_counter] == 1|| (
						(column_counter == random_column_placement) && 
						(row_counter == random_row_placement)
					)
					row << "#{1}"
				else
					row << " "
				end
				column_counter += 1
			end

			row_counter += 1
			matrix << row
		end

		@current_matrix = matrix
	end


	def display(first=false)
		output = ""
		@current_matrix.each do |row|
			output += "#{row.map { |e| e == 1 ? @disp_char : @disp_char.gsub(/./) { |match| ' '  } }.join('')}" + "\n"
		end

		if first
			print "#{output} \r".yellow
		else
			print "#{output} \r".red
		end
	end

	def apply_rules
		# Any live cell with fewer than two live neighbors dies, as if by underpopulation.
		# Any live cell with two or three live neighbors lives on to the next generation.
		# Any live cell with more than three live neighbors dies, as if by overpopulation.
		# Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.
		@step += 1

		new_matrix = []
		@log[@current_matrix.clone] = @step

		@current_matrix.each_with_index do |row, y|
			new_row = []
			row.each_with_index do |cell, x|
				count = 0
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
					if neighbor == 1
						count += 1
					end
				end

				# decide fate
				next_gen = begin
					if cell == 1
						if count < 2
							0
						elsif count == 2 || count == 3
							1
						else
							0
						end
					else
						if count == 3
							1
						else
							0
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
		@current_matrix.map! { |row| row.map { rand(2) } }
		display(true)

		print "\n"
		print "\n"
		print "\n"
		print "\n"*@rank
	end

	def play
		still_go = true
		while still_go do 
			run
			sleep(0.1)

			if @log[@current_matrix.clone] 
				print "Finished in #{@log.length} steps.  Loop begins at step: #{@log[@current_matrix.clone]} \n"
				break 
			end
		end
	end
end

input_length = ARGV[0].to_i

b = GameBoard.new(input_length)
b.initialize_board rand(input_length*input_length)
b.play
