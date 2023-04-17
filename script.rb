def  _p(*args)
    for arg in args
        STDERR.puts arg.inspect
    end

    return arg if args.length == 1

    return args
end

CARDS_NAME = %w( 2 3 4 5 6 7 8 9 10 J Q K A )
CARDS_VALUE = {}
START_VALUE = 2

card_value = START_VALUE
for card_name in CARDS_NAME
    CARDS_VALUE[card_name] = card_value
    card_value += 1
end

class Card
    attr_reader :card, :player

    def initialize(card)
        @card = CARDS_VALUE[card]
    end

    def >(other)
        return @card > other.card
    end

    def ==(other)
        return @card == other.card
    end
end

class Player
    attr_reader :deck_size, :cards, :name, :played_cards

    def initialize(name,deck_size)
        @cards = []
        @played_cards = []
        @name = name
        @deck_size = deck_size
    end

    def can_play?() @cards.length > 0 end

    def can_battle?() @cards.length > 3 end

    def pick_cards(*cards)
        for card in cards
            @cards << card
        end
    end

    def play_card(n:1)
        played_cards = @cards[0...n]
        @cards = @cards[n..-1]
        for played_card in played_cards
            @played_cards << played_card
        end
        
        return played_cards.length == 1 ? played_cards[0] : played_cards
    end

    def reset_played()
      @played_cards = []
    end
end

class Game
    
    def initialize(p1,p2)
        @p1 = p1
        @p2 = p2
        @round = 0
        @winner = nil
        @loser = nil
        @pat = false
    end

    def endgame() 
        @pat ? puts("PAT") : puts("#{@winner.name} #{@round}")
    end

    def play()
        return unless new_round?()
        p1_card = @p1.play_card
        p2_card = @p2.play_card
        _p("P1 : #{p1_card.card} / P2 : #{p2_card.card}")
        if p1_card == p2_card
            if not new_battle?
                @pat = true
                return
            end
            battle()
            return play()
        elsif p1_card > p2_card
            @winner = @p1
            @loser = @p2
        else
            @loser = @p1
            @winner = @p2
        end
        resort_card()
        @round += 1
        return play()
    end

    def battle()
        [@p1,@p2].each { _1.play_card(n:3) }
    end

    def resort_card()
        winner_new_cards = @p1.played_cards+@p2.played_cards
        [@p1,@p2].each { _1.reset_played }
        @winner.pick_cards(*winner_new_cards)
    end


    def get_cards()
        cards = []
        [@p1,@p2].each do |player|
            cards << player.play_card
        end

        return cards
    end

    def new_battle?()
        return [@p1,@p2].all?{ _1.can_battle? }
    end

    def new_round?()
        return [@p1,@p2].all?{ _1.can_play? }
    end
end



p1 = Player.new("1",gets.to_i)

p1.deck_size.times do
    card = Card.new(gets.chomp.gsub(/d|h|c|s/i,""))
    p1.pick_cards(card)
end

p2 = Player.new("2",gets.to_i)

p2.deck_size.times do
    card = Card.new(gets.chomp.gsub(/d|h|c|s/i,""))
    p2.pick_cards(card)
end

game = Game.new(p1,p2)
game.play()
game.endgame()
