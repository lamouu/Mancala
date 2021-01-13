use strict;
use warnings;

use v5.18;

# TODO: opposite banks not allowed, order subroutines and finish comments

#    0:bank1
# 1:pit1  13:pit12
# 2:pit2  12:pit11
# 3:pit3  11:pit10
# 4:pit4  10:pit9
# 5:pit5   9:pit8
# 6:pit6   8:pit7
#    7:bank2

# current board state
my @board_state = (0,4,4,4,4,4,4,0,4,4,4,4,4,4);

# prints board state in readable form
sub printb {
    printf("\n          $board_state[0]\n (1)  $board_state[1]       $board_state[13]\n (2)  $board_state[2]       $board_state[12]\n (3)  $board_state[3]       $board_state[11]\n (4)  $board_state[4]       $board_state[10]\n (5)  $board_state[5]       $board_state[9]\n (6)  $board_state[6]       $board_state[8]\n          $board_state[7]\n\n")
}

# hash converting right pits to left and left to right
my %R2L = (13 => 1, 12 => 2, 11 => 3, 10 => 4, 9 => 5, 8 => 6);
my %L2R = reverse %R2L;

# calculated pip changes from input
my $game_over = 0;
sub pipcalc {
    my $input = $_[0];
    my $turn = $_[1];
    my $count = 1;
    my $loopvar = 0;
    while($count <= $board_state[$input]){
        if($input + $count > 13){
            $loopvar = -14;
        }else{
            $loopvar = 0;
        }
        $board_state[$input + $count + $loopvar]++;
        $count++;
    }

    take($input,$loopvar,$turn);

    $board_state[$input] = 0;

    end_test();
    if($game_over == 1){
        $board_state[7] = $board_state[7] + $board_state[6] + $board_state[5] + $board_state[4] + $board_state[3] + $board_state[2] + $board_state[1];
    }if($game_over == 2){
        $board_state[0] = $board_state[0] + $board_state[13] + $board_state[12] + $board_state[11] + $board_state[10] + $board_state[9] + $board_state[8];
    }
}

my $final_pip = 0;
sub take {
    my $input = $_[0];
    my $loopvar = $_[1];
    my $turn = $_[2];
    $final_pip = $input + $board_state[$input] + $loopvar;

    if($turn == "0"){ #player
        if(($board_state[$final_pip] == 1) && ($final_pip > 0) && ($final_pip < 7)){
            $board_state[7] = $board_state[7] + $board_state[$L2R{$final_pip}];
            $board_state[$L2R{$final_pip}] = 0;
        }
    }if($turn == "1"){ #computer
        if(($board_state[$final_pip] == 1) && ($final_pip > 7) && ($final_pip < 14)){
            $board_state[0] = $board_state[0] + $board_state[$R2L{$final_pip}];
            $board_state[$R2L{$final_pip}] = 0;
        }
    }
}

# 0: no winner  1: player empty  2: computer empty
sub end_test {
    # test LHS
    if($board_state[6] + $board_state[5] + $board_state[4] + $board_state[3] + $board_state[2] + $board_state[1] == 0){
        $game_over = 1;
    }
    # test RHS
    if($board_state[13] + $board_state[12] + $board_state[11] + $board_state[10] + $board_state[9] + $board_state[8] == 0){
        $game_over = 2;
    }
}

sub quit {
    my $savedata;
    open(FH, '>', 'savedata.txt') or die $!;
    print FH join('',@board_state);
    close(FH);
    exit();
}

# player move
sub playermove {
    my $input = 0;

    $final_pip = 7;
    while($final_pip == 7){
        # check if user input is 1-6 and pip != 0
        my $valid_input = 0;
        while($valid_input == 0){
            printf("Select move (1-6): ");
            $input = <>;
            if(($input > 0) && ($input < 7) && ($board_state[$input] != 0)){
                $valid_input = 1;
            }
            if($input == 0){
                quit(@board_state);
            }
        }

        my $turn = "0";
        pipcalc($input,$turn);

        printb();
    }
}

# computer move
sub compmove {
    my $input = 0;

    $final_pip = 0;
    while($final_pip == 0){
        # random input out of playable moves (pip != 0)
        $input = int(rand(6)) + 8;
        while($board_state[$input] == 0){
            $input = int(rand(6)) + 8;
        }
        printf("Computer move: %0d\n",$R2L{$input});

        my $turn = "1";
        pipcalc($input,$turn);

        printb();
    }
}

# main
printf("\n\n ~ ~ ~ MANCALA ~ ~ ~\n");

my $valid_input = 0;
my $load_choice = 0;
while($valid_input == 0){
    printf("(1) Load last game\n(2) Start a new game\n ~ ~ ~ ~ ~ ~ ~ ~ ~ ~\n");
    $load_choice = <>;
    if(($load_choice == 1) or ($load_choice == 2)){
        $valid_input = 1;
    }
}
if($load_choice == 1){
    open(FH, '<', 'savedata.txt') or die $!;
    @board_state = split //,<FH>;

}

printf(" ~ ~ ~ ~ ~ ~ ~ ~ ~ ~\n(0)   Save and exit\n(1-6) Move pits 1-6\n ~ ~ ~ ~ ~ ~ ~ ~ ~ ~\n");

printb();
while($game_over == 0){
    playermove();
    compmove();
}

printf("\n\n ~ ~ ~ GAME OVER ~ ~ ~\n\n");
if($game_over == 1){
    printf("      Player wins\n\n");
}if($game_over == 2){
    printf("      Computer wins\n\n");
}

sleep(2);
