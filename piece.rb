class Piece
  attr_accessor :color, :board, :location, :king

  def initialize(color, board, location)
    @color = color
    @board = board
    @location = location
    @king = false
  end

  def to_s
    if @color == :red
      " \u25CF ".red_on_black
    elsif @color == :white
      " \u25CF ".white_on_black
    end
  end

  def inspect
    { "color" => @color,
      "location" => @location }.inspect
  end

  def dup
    Piece.new(@color,@board,@location.dup) #king?
  end

  def move_to(to)
    unless @board[*to].nil?
      raise InvalidMoveError.new("You cannot move to where a piece already lives")
    end

    unless possible_moves.include?(to)
      raise InvalidMoveError.new("Sorry, that move is not possible")
    end

    @board[*to] = self
    @board[*@location] = nil
    @board[*to].location = to

    update_royal_status
  end

  def perform_moves(move_list)
    board_copy = @board.dup
    board_copy[*@location].perform_moves!(move_list.dup)
    self.perform_moves!(move_list)
  end

  def perform_moves!(move_list)
    move_count = 0
    last_move_was_jump = false

    move_list.each do |next_move|
      move_count += 1

      if (next_move[0] - @location[0]).abs == 1 # slide
        if move_count > 1
          raise InvalidMoveError.new("Cannot slide after jumping")
        end
        perform_slide(next_move)
      else
        last_move_was_jump = true
        perform_jump(next_move)
      end
    end
    if possible_jump_moves.length > 0 && last_move_was_jump
      raise InvalidMoveError.new("Must make all jumps available or none")
    end
  end

  def update_royal_status
    debugger
    old_king = @king
    @king = true if @location[0] == 0 && @color == :red
    @king = true if @location[0] == 7 && @color == :white
    if old_king != @king
      "All-Hail the King!"
    end
  end

  def perform_slide(to)
    unless possible_slide_moves.include?(to)
      raise InvalidMoveError.new("You can't slide there. possible slides: #{possible_slide_moves}")
    end

    move_to(to)
  end

  def perform_jump(to)
    #remove jumped piece
    unless possible_jump_moves.include?(to)
      raise InvalidMoveError.new("You can't jump there. possible jumps: #{possible_jump_moves}")
    end

    i, j = @location # 7, 2 going to need these after moved

    move_to(to)

    to_i, to_j = to  # 5, 0
    taken_i, taken_j = ((to_i + i)/2), ((to_j + j)/2) # 6, 1
    @board[taken_i,taken_j] = nil

  end

  def possible_slide_moves
    moves = []

    powers = [front]
    powers << back if @king
    puts "possible_slide direction count #{powers}"
    powers.each do |power|
      [left,right].each do |dir|
         if @board.game_space?(power, dir) && @board[power, dir].nil?
           moves << [power, dir]
         end
       end
    end

    moves
  end

  def possible_jump_moves
    moves = []

    left_2 = left - 1
    right_2 = right + 1

    powers = [[front + direction, front]]
    powers << [back - direction, back] if @king
    powers.each do |power|
      [[left_2, left], [right_2, right]].each do |dir|
         if @board.game_space?(power[0], dir[0]) &&
            @board.game_space?(power[1], dir[1]) &&
            @board[power[0], dir[0]].nil? &&
           !@board[power[1], dir[1]].nil? &&
            @board[power[1], dir[1]].other_color == @color
           moves << [power[0], dir[0]]
         end
       end
    end

    moves
  end

  def possible_moves
    possible_slide_moves + possible_jump_moves
  end

  def other_color
    @color == :red ? :white : :red
  end

  private

  def direction
    @color == :red ? -1 : 1
  end

  def back
    @location[0] - (-1*direction)
  end

  def front
    @location[0] + direction
  end

  def left
    @location[1] -1
  end

  def right
    @location[1] + 1
  end

end
