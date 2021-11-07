require 'gosu'

TOP_COLOR = Gosu::Color.new(0x191A19)
BOTTOM_COLOR = Gosu::Color.new(0x70191A19)
TEXT_COLOR = Gosu::Color.new(0xffFF8243)

module ZOrder
    BACKGROUND, MENU, UI = *0..2
end

class CityBackground
    attr_accessor :backImg
end

class City < Gosu::Window

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
            @font.draw(@leaders[i].Name, 180 , y_axis, 3, 1.0, 1.0, TEXT_COLOR)
            @font.draw(@leaders[i].Score, 600 , y_axis, 3, 1.0, 1.0, TEXT_COLOR)
            y_axis += 69
            i+=1
        end
    end

    def area_clicked(mouse_x, mouse_y)

        if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 120 && mouse_y < 155 ))
            CityBackground.backImg = "../backImages/paris.jpeg"
		end
		if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 170 && mouse_y < 205 ))
            CityBackground.backImg = "../backImages/paris_2.jpeg"
		end
		if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 220 && mouse_y < 255 ))
            CityBackground.backImg = "../backImages/melbourne.jpeg"
		end
		# if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 270 && mouse_y < 305 ))
        #     CityBackground.backImg = "../backImages/paris_2.jpeg"
        # end
        # if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 320 && mouse_y < 355 ))
        #     CityBackground.backImg = "../backImages/paris_2.jpeg"
        # end

        close

    end

    def draw
        draw_menu_options
        @font.draw("BACK", 100 ,50 , 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(75,40,0xff_7F7C82,200,40,0xff_7F7C82,200,95,0xff_7F7C82,75,95,0xff_7F7C82,ZOrder::UI)
        @background.draw(25,0,ZOrder::BACKGROUND)
    end
end