require 'gosu'
require './leaderboard'
require_relative 'mario'


TOP_COLOR = Gosu::Color.new(0x191A19)
BOTTOM_COLOR = Gosu::Color.new(0x70191A19)
TEXT_COLOR = Gosu::Color.new(0xffFF8243)

module ZOrder
    BACKGROUND, MENU, UI = *0..2
end

class MainMenu < Gosu::Window

    def initialize
        super 800, 600
			self.caption = "Main Menu"
            @background = Gosu::Image.new("../background/super_mario_animation.gif")
            @paris = Gosu::Image.new("../background/paris_2.jpeg")
            @melbourne = Gosu::Image.new("../background/melbourne.jpeg")
            @tokyo = Gosu::Image.new("../background/tokyo.jpeg")
            @london = Gosu::Image.new("../background/test.png")
            # @background = Gosu::Image.new("../backImages/super_mario_animation.gif")

			@font = Gosu::Font.new(30)
    end

    def update
    end

    def button_down(id)
		case id
			when Gosu::MsLeft
				area_clicked(mouse_x, mouse_y)
	    end
	end

    def draw_menu
        draw_quad(50,50, BOTTOM_COLOR, 50, 400, TOP_COLOR, 400, 50, BOTTOM_COLOR, 400, 400, BOTTOM_COLOR, 10)
    end

    def draw_menu_options
        @font.draw("Play Game >", 100 , 125, 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(80,120,0xff_7F7C82,300,120,0xff_7F7C82,300,155,0xff_7F7C82,80,155,0xff_7F7C82,ZOrder::UI)

        @font.draw("Leaderboard", 100 , 175, 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(80,170,0xff_7F7C82,300,170,0xff_7F7C82,300,205,0xff_7F7C82,80,205,0xff_7F7C82,ZOrder::UI)

        @font.draw("Sounds", 100 , 225, 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(80,220,0xff_7F7C82,300,220,0xff_7F7C82,300,255,0xff_7F7C82,80,255,0xff_7F7C82,ZOrder::UI)

        @font.draw("Exit", 100 , 275, 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(80,270,0xff_7F7C82,300,270,0xff_7F7C82,300,305,0xff_7F7C82,80,305,0xff_7F7C82,ZOrder::UI)

        # @font.draw("Exit", 100 , 325, 3, 1.0, 1.0, TEXT_COLOR)
        # draw_quad(80,320,0xff_7F7C82,300,320,0xff_7F7C82,300,355,0xff_7F7C82,80,355,0xff_7F7C82,ZOrder::UI)
    end

    def draw_city
        @paris.draw(500,50,5)
        @melbourne.draw(500,175,5)
        @london.draw(500,300,5)
        @tokyo.draw(500,425,5)
    end

    def area_clicked(mouse_x, mouse_y)

        # Menu Options
        if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 120 && mouse_y < 155 ))
            close
            window = Mario.new("../backImages/paris_2.jpeg")
            window.show
		end
		if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 170 && mouse_y < 205 ))
            lead = Leaderboard.new
            lead.show
            window = MainMenu.new
            window.show
		end
		if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 220 && mouse_y < 255 ))
            puts "Sound"
		end
		if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 270 && mouse_y < 305 ))
            puts "Exit"
            close
        end

        # Selecting City
        if ((mouse_x >500 && mouse_x < 700)&& (mouse_y > 50 && mouse_y < 150 ))
            close
            window = Mario.new("../backImages/paris_2.jpeg")
            window.show
        end
        if ((mouse_x >500 && mouse_x < 700)&& (mouse_y > 175 && mouse_y < 275 ))
            close
            window = Mario.new("../backImages/melbourne.jpeg")
            window.show
        end
        if ((mouse_x >500 && mouse_x < 700)&& (mouse_y > 300 && mouse_y < 400 ))
            close
            window = Mario.new("../backImages/test.png")
            window.show
        end
        if ((mouse_x >500 && mouse_x < 700)&& (mouse_y > 425 && mouse_y < 525 ))
            close
            window = Mario.new("../backImages/tokyo.png")
            window.show
        end
    end

    def draw
        draw_menu
        draw_menu_options
        draw_city
        @background.draw(0,0,ZOrder::BACKGROUND)
        @font.draw("Main Menu", 150 , 75, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLUE)
    end
end

window = MainMenu.new
window.show