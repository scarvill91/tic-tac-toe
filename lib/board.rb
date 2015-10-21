module TicTacToe
  class Board
    BoardError = Class.new(StandardError)
    BLANK_MARK = nil

    attr_reader :size, :last_move_made

    def self.blank_mark
      BLANK_MARK
    end

    def initialize(parameters)
      @size = parameters[:size]
      @cells = parameters[:config] || blank_board_configuration
      @last_move_made = parameters[:last_move_made]
    end

    def read_cell(row, col)
      @cells[row * @size + col]
    end

    def mark_cell(mark, row, col)
      config = @cells.dup
      config[row * @size + col] = mark
      Board.new(size: @size, config: config, last_move_made: [row, col])
    end

    def lines
      (0...@size).each_with_object([left_diag, right_diag]) do |index, lines|
        lines << row_at(index) << col_at(index)
      end
    end

    def all_coordinates
      (0...@size).to_a.repeated_permutation(2).to_a
    end

    def blank_cell_coordinates
      all_coordinates.reject { |coordinates| marked?(coordinates) }
    end

    def last_mark_made
      return if @last_move_made.nil?
      self.read_cell(*last_move_made)
    end

    def blank?(coordinates)
      self.read_cell(*coordinates) == BLANK_MARK
    end

    def marked?(coordinates)
      !blank?(coordinates)
    end

    def out_of_bounds?(coordinates)
      coordinates.any? { |i| !i.between?(0, @size - 1) }
    end

    def all_blank?
      all_coordinates.all? { |coordinates| blank?(coordinates) }
    end

    def all_marked?
      all_coordinates.all? { |coordinates| marked?(coordinates) }
    end

    def has_winning_line?
      lines.each do |line|
        return true if line.first != BLANK_MARK && line.all? { |cell| cell == line.first }
      end
      false
    end

    private

    def blank_board_configuration
      Array.new(@size**2) { BLANK_MARK }
    end

    def row_at(row)
      (0...@size).map { |col| self.read_cell(row, col) }
    end

    def col_at(col)
      (0...@size).map { |row| self.read_cell(row, col) }
    end

    def left_diag
      (0...@size).map { |index| self.read_cell(index, index) }
    end

    def right_diag
      (0...@size).map { |row| self.read_cell(row, @size - row - 1) }
    end
  end
end
