def clear_screen():
    """clears the screen from everything before the game starts
    :param none
    :type none
    :return: none
    """
    import os
    clear = lambda: os.system('cls')
    clear()


def print_winner(answer_word):
    """printing the winner screen
    :parm none
    :type none
    :return: none
    """
    clear_screen()
    title_winner = """
     __      __.___ _______    _______  _____________________ \n
    /  \    /  \   |\      \   \      \ \_   _____/\______   \\\n
    \   \/\/   /   |/   |   \  /   |   \ |    __)_  |       _/\n
     \        /|   /    |    \/    |    \|        \ |    |   \\\n
      \__/\  / |___\____|__  /\____|__  /_______  / |____|_  /\n
           \/              \/         \/        \/         \/ \n
    """
    print(title_winner)
    print("end of game - you win! the answer was - ", answer_word, " -")
    temp = input("click THE ENTER KEY to continue")  # variable not used - only here to pause the play


#  print HANGMAN status
def print_hangman(try_number):
    """ prints the title of the hangman and after every try the status of the hangman
    :param try_number: the number of tries that where guessed
    :type try_number: integer
    :return: prints to the screen and returns nothing
    :rtype: none
    """
    # title
    hangman_title = """      _    _                                         
     | |  | |                                        
     | |__| | __ _ _ __   __ _ _ __ ___   __ _ _ __  
     |  __  |/ _` | '_ \ / _` | '_ ` _ \ / _` | '_ \ 
     | |  | | (_| | | | | (_| | | | | | | (_| | | | |
     |_|  |_|\__,_|_| |_|\__, |_| |_| |_|\__,_|_| |_|
                          __/ |                      
                         |___/\n\n\n\n"""
    try_1 = "\t\tx-------x\n\n"

    try_2 = """\t\t        x-------x
        \t\t|
        \t\t|
        \t\t|
        \t\t|
        \t\t|\n\n"""

    try_3 = """\t\t        x-------x
        \t\t|       |
        \t\t|       0
        \t\t|
        \t\t|
        \t\t|\n\n"""

    try_4 = """\t\t        x-------x
        \t\t|       |
        \t\t|       0
        \t\t|       |
        \t\t|
        \t\t|\n\n"""

    try_5 = """\t\t        x-------x
        \t\t|       |
        \t\t|       0
        \t\t|      /|\\
        \t\t|
        \t\t|\n\n"""

    try_6 = """\t\t        x-------x
        \t\t|       |
        \t\t|       0
        \t\t|      /|\\
        \t\t|      /
        \t\t|\n\n"""

    try_7 = """\t\t        x-------x
        \t\t|       |
        \t\t|       0
        \t\t|      /|\\
        \t\t|      / \\
        \t\t|\n\n"""

    print(hangman_title)
    if try_number == 1:
        print(try_1)
    elif try_number == 2:
        print(try_2)
    elif try_number == 3:
        print(try_3)
    elif try_number == 4:
        print(try_4)
    elif try_number == 5:
        print(try_5)
    elif try_number == 6:
        print(try_6)
    elif try_number == 7:
        print(try_7)
    elif try_number == 8:
        print(try_7)
        print("END OF GAME - YOU LOOSE!!!!")
        temp = input("click THE ENTER KEY to the end the game")  # variable not used - only here to pause the play
    elif try_number > 8:
        print("error")


def check_valid_input(letter_guessed):
    """ check if the input is legit
    :param letter_guessed: the letter that the player thinks is in the word he is looking for
    :type letter_guessed: string
    :return: true if its a one letter of the ABC. false if its more then one letter or not in the ABC
    :rtype: boolean 0 if the input letter is an error, 1 if its a valid letter
    """
    if letter_guessed.isalpha() == 0:
        print("error #1 - you didn't enter a letter from the ABC")
        return 0
    elif len(letter_guessed) != 1:
        print("error #2 - enter only one letter")
        return 0
    else:
        return 1


def try_update_letter_guessed(letter_guessed, old_letters_guessed):
    """ check if the input is legit + wasn't in past attempts
    :param letter_guessed: the letter that the player thinks is in the word he is looking for
    :param old_letters_guessed: all of the letters that where guested in past attempts
    :type letter_guessed: string
    :type old_letters_guessed: list of char
    :return: true if its a one letter of the ABC. false if its more then one letter or not in the ABC or is in the old_letters_guessed
    :rtype: boolean 0 if the input letter is an error, 1 if its a valid letter
    """
    if letter_guessed in old_letters_guessed:
        print("error #3 - you already tried this letter in the past")
        return 0
    else:
        return 1


def update_good_guesses_word_list(good_guesses_word_list, letter_guessed, answer_list):
    """update and print the result of the word the player succeeded to find until now
    :param good_guesses_word_list : the list of letters the player succeeded to find until now
    :param letter_guessed : the current letter the player guessed in this turn
    :param answer_list : all of the letters the player tried until now including wrong guesses
    :type good_guesses_word_list : list of char
    :type letter_guessed : char
    :type answer_list : list of char
    :return good_guesses_word_list : updated list of letters the player succeeded to find until now
    :rtype : list of char
    """
    for i in range(len(answer_list)):
        if answer_list[i] == letter_guessed:
            good_guesses_word_list[i] = list(letter_guessed)
    return good_guesses_word_list


# ------------------------------------------------------------------------#
def main():
    """ this is the main function that the programs starts with """
    clear_screen()
    number_of_tries = 0
    success_tries_max = 0
    success_tries_actual = 0
    good_guesses = ""
    answer_list = list()
    my_old_letters_guessed = ""
    print_hangman(0)
    # receive the word the player needs to find in lower case
    answer = input("enter the word the player need to find: ").lower()
    good_guesses_word_list = list()
    answer_list = list(answer)
    temp = input("click THE ENTER KEY to start the game")  # variable not used - only here to pause the play
    success_tries_max = len(answer)

    for i in range(len(answer)):
        good_guesses_word_list += ["_"]

    while number_of_tries < 8:
        clear_screen()
        print_hangman(number_of_tries)
        print(f"*** you are looking for a {len(answer)} letters word ***\n")
        print(good_guesses_word_list)
        print(f"\nnumber of bad tries: {number_of_tries}")
        if number_of_tries > 0:
            print(f"\nlist of all of the letters you tried to guess from the start: {my_old_letters_guessed}")
        letter_guessed = input("\nGuess a letter: ")
        if check_valid_input(letter_guessed):
            letter_guessed = letter_guessed.lower()
            if try_update_letter_guessed(letter_guessed, my_old_letters_guessed):
                if letter_guessed in answer:
                    good_guesses = good_guesses + " -> " + letter_guessed
                    good_guesses_word_list = update_good_guesses_word_list(good_guesses_word_list, letter_guessed,
                                                                           answer_list)
                    my_old_letters_guessed = my_old_letters_guessed + " -> " + letter_guessed
                    success_tries_actual = success_tries_actual + answer.count(letter_guessed)
                    print("\nsuccess - the letter you guessed is in the word")
                    print("\n8~}")
                else:
                    number_of_tries = number_of_tries + 1
                    print("\nBASSAA - the letter you guessed is NOT in the word")
                    print("8~<\n")
                    my_old_letters_guessed = my_old_letters_guessed + " -> " + letter_guessed
        temp = input("click THE ENTER KEY to continue")  # variable not used - only here to pause the play
        if success_tries_max == success_tries_actual:
            print_winner(answer)
            number_of_tries = 9
    # ends the loop

    if number_of_tries == 8:
        clear_screen()
        print_hangman(number_of_tries)


if __name__ == "__main__":
    main()
