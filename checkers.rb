#!/usr/bin/env ruby

require 'colored'
require_relative 'player'
require_relative 'piece'
require_relative 'board'

require 'debugger'

class Checkers

  def self.human_vs_human
    h = HumanPlayer.new(:white)
    h2 = HumanPlayer.new(:red)
    b = Board.new
    b.setup
    Checkers.new(h, h2, b).play
  end

  def self.human_vs_computer
    h = HumanPlayer.new(:white)
    c = ComputerPlayer.new(:red)
    b = Board.new
    b.setup
    Checkers.new(h, c, b).play
  end

  def initialize(player1, player2, board)
    raise RuntimeError.new("Players colors must be different") if player1.color == player2.color
    @board = board
    @players = {
      player1.color => player1,
      player2.color => player2
    }
    @current_player = :white
  end

  def play
    until @board.won?
      begin
        @players[@current_player].take_turn(@board)
        @current_player = (@current_player == :red) ? :white : :red
      rescue StandardError => e
        puts e.message
        puts e.backtrace
        puts "Lets try that again..."
        retry
      end
    end
  end

  def inspect
    puts
  end
end

class InvalidMoveError < ArgumentError
end

Checkers.human_vs_computer