function [pits,Wumpus] = CS4300_WP_estimates(breezes,stench,num_trials)
% CS4300_WP_estimates - estimate pit and Wumpus likelihoods
% On input:
%     breezes (4x4 Boolean array): presence of breeze percept at cell
%         -1: no knowledge
%          0: no breeze detected
%          1: breeze detected
%     stench (4x4 Boolean array): presence of stench in cell
%         -1: no knowledge
%          0: no stench detected
%          1: stench detected
%     num_trials (int): number of trials to run (subset will be OK)
% On output:
%     pits (4x4 [0,1] array): likelihood of pit in cell
%     Wumpus (4x4 [0 to 1] array): likelihood of Wumpus in cell
% Call:
%     breezes = -ones(4,4);
%     breezes(4,1) = 1;
%     stench = -ones(4,4);
%     stench(4,1) = 0;
%     [pts,Wumpus] = CS4300_WP_estimates(breezes,stench,10000)
% pts =
%     0.2021  0.1967  0.1956  0.1953
%     0.1972  0.1999  0.2016  0.1980
%     0.5527  0.1969  0.1989  0.2119
%     0       0.5552  0.1948  0.1839
%
% Wumpus =
%     0.0806  0.0800  0.0827  0.0720
%     0.0780  0.0738  0.0723  0.0717
%     0       0.0845  0.0685  0.0803
%     0       0       0.0741  0.0812
% Author:
%     Christian Boyd
%     Ken Richard
%     UU
%     Fall 2016
%

% breeze & stench values
UNKNOWN = -1;
NO = 0;
YES = 1;

% board values
SAFE = 0;
PIT = 1;
GOLD = 2;
WUMPUS = 3;
BOTH = 4;

% initialize
pits = ones(4,4);           % default is failure
Wumpus = ones(4,4);         % default is failure
pitCounts = zeros(4,4);
wumpCounts = zeros(4,4);
p = 0.2;                    % pit probability: wrong?
true_boards = 0;
all_boards = 0;
fail_ratio = 0.05;           % 0: never give up,  1: only perfection

% generate boards until num_trials are acceptable
while true_boards < num_trials
    board = CS4300_gen_board(p);
    all_boards = all_boards + 1;
    
    % check if board is not possible
    board_possible = true;
    for r = 4:-1:1
        for c = 4:-1:1
            % verify wumpus with stenches
            if board(r,c) >= WUMPUS
                if (c < 4 && stench(r, c+1) == NO)   % north
                    board_possible = false;
                end
                if (r < 4 && stench(r+1, c) == NO)   % east
                    board_possible = false;
                end
                if (c > 1 && stench(r, c-1) == NO)   % south
                    board_possible = false;
                end
                if (r > 1 && stench(r-1, c) == NO)   % west
                    board_possible = false;
                end
            end
            % verify pits with breezes
            if board(r,c) == PIT || board(r,c) == BOTH
                if (c < 4 && breezes(r, c+1) == NO)   % north
                    board_possible = false;
                end
                if (r < 4 && breezes(r+1, c) == NO)   % east
                    board_possible = false;
                end
                if (c > 1 && breezes(r, c-1) == NO)   % south
                    board_possible = false;
                end
                if (r > 1 && breezes(r-1, c) == NO)   % west
                    board_possible = false;
                end
            end
            % verify breezes with pits
            if breezes(r,c) == YES
                if board_possible
                    board_possible = false;
                    if (c < 4 && board(r, c+1) == PIT)   % north
                        board_possible = true;
                    end
                    if (r < 4 && board(r+1, c) == PIT)   % east
                        board_possible = true;
                    end
                    if (c > 1 && board(r, c-1) == PIT)   % south
                        board_possible = true;
                    end
                    if (r > 1 && board(r-1, c) == PIT)   % west
                        board_possible = true;
                    end
                end
            end
            % verify stenches with wumpuses
            if stench(r,c) == YES
                if board_possible
                    board_possible = false;
                    if (c < 4 && board(r, c+1)>=WUMPUS)   % north
                        board_possible = true;
                    end
                    if (r < 4 && board(r+1, c) >=WUMPUS)   % east
                        board_possible = true;
                    end
                    if (c > 1 && board(r, c-1) >=WUMPUS)   % south
                        board_possible = true;
                    end
                    if (r > 1 && board(r-1, c) >=WUMPUS)   % west
                        board_possible = true;
                    end
                end
            end
        end
    end
    
    % when this board is possible
    if board_possible
        true_boards = true_boards +1;
        
        % increment the pit and wumpus counts for later
        for r = 4:-1:1
            for c = 4:-1:1
                if board(r,c) >= WUMPUS
                    wumpCounts(r,c) = wumpCounts(r,c) + 1;
                elseif board(r,c) == PIT
                    pitCounts(r,c) = pitCounts(r,c) + 1;
                end
            end
        end
    end
    
    % check if failure rate is too high after num_trials
    if (all_boards >= num_trials) && (true_boards/all_boards < fail_ratio)
        % give up and return the signature failure results
        pits = ones(4,4);
        Wumpus = ones(4,4);
        return
    end
    
end % next generated board

% return probabilities (all boards required were genetated)
for r = 4:-1:1
        for c = 4:-1:1
            pits(r,c) = pitCounts(r,c)/true_boards;
            Wumpus(r,c) = wumpCounts(r,c)/true_boards;
        end
    end
end
