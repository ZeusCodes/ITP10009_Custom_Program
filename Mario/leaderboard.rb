require 'gosu'

TOP_COLOR = Gosu::Color.new(0x191A19)
BOTTOM_COLOR = Gosu::Color.new(0x70191A19)
TEXT_COLOR = Gosu::Color.new(0xffFF8243)

module ZOrder
    BACKGROUND, MENU, UI = *0..2
end

# Class for storing Name and Scores of Leaderboard Players
class Leader
    attr_accessor :Name,:Score
    def initialize ( name, score)
        @Name = name
        @Score = score
    end
end

# Read Leaderboard Player from Textfile
def leader
    leader_file = File.new("leaders.txt", "r")
    i = 0
    leaders = Array.new()
    while i < 9
        name = leader_file.gets()
        score = leader_file.gets()
        leader =  Leader.new(name,score)
        leaders << leader
        i+=1
    end
    return leaders
end

class Leaderboard < Gosu::Window

    def initialize
        super 800, 600
			self.caption = "Main Menu"
            @background = Gosu::Image.new("../backImages/leaderboard.png")
			@font = Gosu::Font.new(30)
            leader_file = File.new("leaders.txt", "r")
            @leaders = leader
    end

    def update
    end

    def button_down(id)
		case id
			when Gosu::MsLeft
				area_clicked(mouse_x, mouse_y)
	    end
	end

    def draw_menu_options
        i = 0
        y_axis = 135
        while i < 8
            # Drawing Player Names and Score
            @font.draw(@leaders[i].Name, 180 , y_axis, 3, 1.0, 1.0, TEXT_COLOR)
            @font.draw(@leaders[i].Score, 600 , y_axis, 3, 1.0, 1.0, TEXT_COLOR)
            y_axis += 69
            i+=1
        end
    end

    # Going Back to Main Menu
    def area_clicked(mouse_x, mouse_y)

        if ((mouse_x >75 && mouse_x < 200)&& (mouse_y > 40 && mouse_y < 95 ))
            puts "Back"
            close
        end
    end

    def draw
        draw_menu_options
        @font.draw("BACK", 100 ,50 , 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(75,40,0xff_7F7C82,200,40,0xff_7F7C82,200,95,0xff_7F7C82,75,95,0xff_7F7C82,ZOrder::UI)
        @background.draw(25,0,ZOrder::BACKGROUND)
    end
end

# window = Leaderboard.new
# window.show