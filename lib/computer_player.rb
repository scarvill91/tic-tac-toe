require 'player_interface'
require 'game_state'

module TicTacToe
  class ComputerPlayer < PlayerInterface

    attr_reader :player_mark, :opponent_mark

    def initialize(parameters)
      @player_mark = parameters[:player]
      @opponent_mark = parameters[:opponent]
      @board = parameters[:board]
    end

    def minimax(game_state)
      evaluate(game_state)
    end

    private

    def evaluate(game_state)
      game_state.board.lines.each do |line|
        return 1 if line.all?{ |cell| cell == @player_mark }
        return -1 if line.all?{ |cell| cell == @opponent_mark }
      end

      game_state.board.filled? ? 0 : nil
    end
  end
end