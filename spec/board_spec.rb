require "spec_helper"
require "board"

module TicTacToe
  describe Board do
    include_context "default_values"
    include_context "helper_methods"

    let(:_) { Board.blank_mark }
    let(:x) { @default_player_marks.first }
    let(:o) { @default_player_marks.last }

    describe ".blank_mark" do
      it "returns the mark used by board to indicate a blank cell" do
        board = blank_board(@default_board_size)

        board.all_coordinates.each do |coordinates|
          expect(board.read_cell(*coordinates)).to eq Board.blank_mark
        end
      end
    end

    describe "#initialize" do
      context "given the configuration of a board with preexisting marks" do
        let(:config) do
          [ x, _, _,
            _, o, _,
            _, _, x ]
        end

        it "generates a board with the specified marks in each cell" do
          board = new_board(size: Math.sqrt(config.size).to_i, config: config)

          board.all_coordinates.zip(config).each do |coordinates, mark|
            expect(board.read_cell(*coordinates)).to eq mark
          end
        end
      end

      context "when not given a configuration of a board with preexisting marks" do
        it "generates a NxN board of the given size" do
          (3..5).each do |size|
            custom_board = new_board(size: size)

            expect(custom_board.size).to eq size
            expect(custom_board.all_coordinates.count).to eq size**2
          end
        end

        it "leaves the generated board blank" do
          expect(new_board(size: @default_board_size).all_blank?).to be true
        end
      end
    end

    describe "#read_cell" do
      it "gets the contents of cell at given row and column" do
        mark = @default_player_marks.sample
        config = blank_board_configuration(@default_board_size)
        config[0] = mark
        board = build_board(config)

        expect(board.read_cell(0, 0)).to eq mark
      end
    end

    describe "#mark_cell" do
      let(:board) { blank_board(@default_board_size) }
      let(:coordinates) { random_coordinates(board.size) }
      let(:mark) { @default_player_marks.sample }

      it "returns a new board with the given coordinates played" do
        board = blank_board(@default_board_size)

        expect(board.mark_cell(mark, *coordinates).read_cell(*coordinates)).to eq(mark)
      end

      it "does not mutate the board" do
        board = blank_board(@default_board_size)

        board.mark_cell(mark, *coordinates)

        expect(board).to be_all_blank
      end

      it "records the coordinates of the last mark made" do
        returned_board = board.mark_cell(mark, *coordinates)

        expect(returned_board.last_move_made).to eq coordinates
      end
    end

    describe "#lines" do
      let(:board) { blank_board(@default_board_size) }

      it "returns the contents of every board-length line (rows, cols, and diagonals)" do
        lines = board.lines

        lines.each do |line|
          expect(line.count).to eq board.size
        end
        expect(lines.count).to eq board.size * 2 + 2
      end
    end

    describe "#all_coordinates" do
      let(:board) { blank_board(@default_board_size) }

      it "returns the coordinates of every cell in board" do
        all_coordinates = (0...board.size).to_a.repeated_permutation(2).to_a

        expect(board.all_coordinates).to match_array all_coordinates
      end
    end

    describe "#blank_cell_coordinates" do
      it "returns all cell coordinates when board is blank" do
        board = blank_board(@default_board_size)

        expect(board.blank_cell_coordinates).to match_array board.all_coordinates
      end

      it "returns the coordinates of all blank cells in board" do
        config = [x, o, _, _, _, _, _, _, _].shuffle
        board = build_board(config)
        unmarked_coordinates = board.all_coordinates.reject { |coords| board.marked?(coords) }

        expect(board.blank_cell_coordinates).to match_array unmarked_coordinates
      end

      it "returns no coordinates when no cells are blank" do
        config = [x, o, x, o, x, o, x, o, x].shuffle
        board = build_board(config)

        expect(board.blank_cell_coordinates.count).to eq 0
      end
    end

    describe "#last_mark_made" do
      context "when board is blank" do
        it "returns nil" do
          expect(blank_board(@default_board_size).last_mark_made).to be nil
        end
      end

      context "when board is not blank" do
        it "returns the last mark made on the board" do
          board = blank_board(@default_board_size)
          mark = @default_player_marks.sample
          returned_board = board.mark_cell(mark, *random_coordinates(board.size))

          expect(returned_board.last_mark_made).to eq mark
        end
      end
    end

    describe "#blank?" do
      it "returns true if cell at given coordinates is blank" do
        board = blank_board(@default_board_size)

        expect(board.blank?(random_coordinates(board.size))).to be true
      end

      it "returns false if cell at given coordinates is not blank" do
        board = blank_board(@default_board_size)
        coordinates = random_coordinates(board.size)
        returned_board = board.mark_cell(@default_player_marks.sample, *coordinates)

        expect(returned_board.blank?(coordinates)).to be false
      end
    end

    describe "#marked?" do
      it "returns true if cell at given coordinates has any player's mark" do
        board = blank_board(@default_board_size)
        coordinates = random_coordinates(board.size)
        returned_board = board.mark_cell(@default_player_marks.sample, *coordinates)

        expect(returned_board.marked?(coordinates)).to be true
      end

      it "returns false if cell at given coordinates does not have a player's mark" do
        blank_board = blank_board(@default_board_size)
        coordinates = random_coordinates(blank_board.size)

        expect(blank_board.marked?(coordinates)).to be false
      end
    end

    describe "#out_of_bounds?" do
      it "returns true if given coordinates are not within bounds of board" do
        board = blank_board(@default_board_size)
        coordinates = [0, board.size]

        expect(board.out_of_bounds?(coordinates)).to be true
      end

      it "returns false if given coordinates are within bounds of board" do
        board = blank_board(@default_board_size)

        board.all_coordinates.each do |coordinates|
          expect(board.out_of_bounds?(coordinates)).to be false
        end
      end
    end

    describe "#all_blank?" do
      it "returns true if no cell in board is marked" do
        board = blank_board(@default_board_size)

        expect(board.all_blank?).to be true
      end

      it "returns false if any cell in board is marked" do
        config = [x, _, _, _, _, _, _, _, _].shuffle
        board = build_board(config)

        expect(board.all_blank?).to be false
      end
    end

    describe "#all_marked?" do
      it "returns true if all cells in board are marked" do
        config = [x, x, x, x, x, o, o, o, o].shuffle
        board = build_board(config)

        expect(board.all_marked?).to be true
      end

      it "returns false if any cell in board is blank" do
        config = [x, x, x, x, _, o, o, o, o].shuffle
        board = build_board(config)

        expect(board.all_marked?).to be false
      end
    end

    describe "#has_winning_line?" do
      it "returns true if board has a horizontal winning line" do
        winning_configs = [
          [ x, x, x,
            _, _, _,
            _, _, _ ],
          [ _, _, _,
            x, x, x,
            _, _, _ ],
          [ _, _, _,
            _, _, _,
            x, x, x ]
        ]

        winning_configs.each do |config|
          expect(build_board(config).has_winning_line?).to be true
        end
      end

      it "returns true if board has a vertical winning line" do
        winning_configs = [
          [ x, _, _,
            x, _, _,
            x, _, _ ],
          [ _, x, _,
            _, x, _,
            _, x, _ ],
          [ _, _, x,
            _, _, x,
            _, _, x ]
        ]

        winning_configs.each do |config|
          expect(build_board(config).has_winning_line?).to be true
        end
      end

      it "returns true if board has a diagonal winning line" do
        winning_configs = [
          [ x, _, _,
            _, x, _,
            _, _, x ],
          [ _, _, x,
            _, x, _,
            x, _, _ ]
        ]

        winning_configs.each do |config|
          expect(build_board(config).has_winning_line?).to be true
        end
      end

      it "returns false if board has no winning line" do
        non_winning_configs = [
          [ _, _, _,
            _, _, _,
            _, _, _ ],
          [ _, _, _,
            x, x, o,
            _, _, _ ],
          [ x, _, _,
            x, _, _,
            o, _, _ ],
          [ x, _, _,
            _, x, _,
            _, _, o ],
          [ x, o, x,
            x, o, x,
            o, x, o ]
        ]

        non_winning_configs.each do |config|
          expect(build_board(config).has_winning_line?).to be false
        end
      end
    end
  end
end
