class HumanPlayer
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def take_turn(board)
    board.display
    puts "#{@color.capitalize}, it's your turn."
    begin
      puts "enter a set of move locations (5 0) separated by a comma starting with the from pieces location"
      puts "example  5 0, 4 1, 3 2 this will try to move from [5][0] to [4][1] to [3][2]"
      moves = gets.chomp.split(",").map(&:strip).map do |spot|
        spot.split(/ /).map(&:to_i)
      end
      raise ArgumentError.new("Please place from and to locations for a piece") unless moves.count > 1
      from = moves.shift
      raise ArgumentError.new("You can only move your pieces") if board[*from].nil? || board[*from].color != @color
      board[*from].perform_moves(moves)
    rescue ArgumentError => e
      puts e.message
      retry
    end
  end
end

class ComputerPlayer
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def take_turn(board)
    all_moves = Hash.new()
    jump_moves = Hash.new()

    board.grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        next if piece.nil? || board[i,j].color != @color
        piece_moves = board[i,j].possible_moves
        piece_jump_moves = board[i,j].possible_jump_moves
        all_moves[[i,j]] = piece_moves unless piece_moves.empty?
        jump_moves[[i,j]] = piece_jump_moves unless piece_jump_moves.empty?
      end
    end

    begin

      if jump_moves.count > 0

        from = jump_moves.max_by { |k,v| v.flatten.length }[0]
        jumps = [jump_moves[from].first]

        board_copy = board.dup
        while true
          board_copy[*from].perform_moves([jumps.last])
          more_jumps = board_copy[*jumps.last].possible_jump_moves
          unless more_jumps.empty?
            jumps << more_jumps.first
          else
            break
          end
        end
        p jumps

        board[*from].perform_moves(jumps)
      else
        from = all_moves.keys.sample
        board[*from].perform_moves([all_moves[from].first])
      end
    rescue ArgumentError => e
      puts e.message
      retry
    end
  end


end