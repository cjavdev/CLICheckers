class Board
  attr_accessor :grid

  def self.default_grid
    Array.new(8) { Array.new(8) }
  end

  def initialize(grid = Board.default_grid)
    @grid = grid
  end

  def won?
    red = false
    white = false
    @grid.each do |row|
      row.each do |piece|
        red = true if !piece.nil? && piece.color == :red
        white = true if !piece.nil? && piece.color == :white
      end
    end
    white != red
  end

  def setup
    #[0,1,2,5,6,7].each do |row|
    [0].each do |row|
      (0...8).each do |col|
        color = row > 4 ? :red : :white
        if (row.even? != col.even?)
          @grid[row][col] = Piece.new(color, self, [row,col])
        end
      end
    end
    @grid[7][0] = Piece.new(:red,self,[7,0])
    @grid[6][5] = Piece.new(:white,self,[6,5])
  end

  def setup_king_test
    @grid[1][0] = Piece.new(:red, self, [1,0])
  end

  def setup_jump_test
    [0,1,2,5,6,7].each do |row|
      (0...8).each do |col|
        color = row > 4 ? :red : :white
        if (row.even? != col.even?)
          @grid[row][col] = Piece.new(color, self, [row,col])
        end
      end
    end

    @grid[3][2] = @grid[5][0]
    @grid[5][0] = nil

  end

  def setup_2jump_test
    [0,1,2,5,6,7].each do |row|
      (0...8).each do |col|
        color = row > 4 ? :red : :white
        if (row.even? != col.even?)
          @grid[row][col] = Piece.new(color, self, [row,col])
        end
      end
    end

    @grid[6][5] = nil
    @grid[3][4] = @grid[5][2]
    @grid[5][2] = nil

  end

  def display
    system("clear")
    print_cols
    @grid.each_with_index do |row,x|
      print "#{x} "
      row.each_with_index do |piece,y|
        if !piece.nil?
          print piece.to_s
        elsif x.even? != y.even?
          print "   ".red_on_black
        else
          print "   ".red_on_white
        end
      end
      puts
    end
    print_cols
  end

  def print_cols
    puts "   0  1  2  3  4  5  6  7"
  end

  def dup
    new_board = Board.new(grid)
    new_board.grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        next if piece.nil? || i.even? == j.even?
        new_board[i,j] = piece.dup
        new_board[i,j].board = new_board
      end
    end
    new_board
  end

  def grid
    @grid.map(&:dup)
  end

  def []=(i, j ,piece)
    raise InvalidMoveError.new("A piece cannot move to that space #{i}, #{j}") unless game_space?(i,j)
    @grid[i][j] = piece
  end

  def [](i,j)
    @grid[i][j]
  end

  def game_space?(i,j)
    [i,j].all? { |x| x.between?(0,7) } # && (i.even? != j.even?) # dark space
  end
end