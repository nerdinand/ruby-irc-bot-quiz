# ruby-irc-bot-quiz

A Ruby IRC quiz bot.

## Usage

1. Clone this repository
2. Download a set of questions, see below
3. Run `ruby irc_bot.rb`

## Question sets

The bot supports two kinds of question format: [Moxxquizz](http://moxquizz.de/download.html) and [Triviabot](https://github.com/rawsonj/triviabot).
To get the bot to run, Download the question files you want from Moxxquizz or Triviabot and put them in the directories `quiz_data/moxquizz` and `quiz_data/triviabot` respectively.
The bot will automatically parse any questions in those directories on startup.

## Bot operation

### !startquiz

When the bot is in a channel and you send the message `!startquiz` to that channel, the bot will activate and start a quiz. It will pick one of the questions it has parsed on startup and ask it in the channel.

### Guessing

When a question is asked, the bot listens for the the answer in the channel.

### !tip

If a question is too hard and you need a hint, you can ask for one with the `!tip` command.

### !stopquiz

When the bot receives the `!stopquiz` command it immediately stops the quiz.
