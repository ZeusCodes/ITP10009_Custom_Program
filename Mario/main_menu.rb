require 'gosu'
require './leaderboard'
require_relative 'coviRun'


TOP_COLOR = Gosu::Color.new(0x191A19)
BOTTOM_COLOR = Gosu::Color.new(0x70191A19)
TEXT_COLOR = Gosu::Color.new(0xffFF8243)
INSTRUCTION_COLOR = Gosu::Color.new(0xff161E54)
INACTIVE_COLOR  = 0xcc_666666
ACTIVE_COLOR    = 0xcc_ff6666
SELECTION_COLOR = 0xcc_0000ff
WIDTH = 350

# Enumerations For Setting Z - Order of display on Screen
module ZOrder
    BACKGROUND, MENU, UI , INSTRUCTIONS = *0..3
end

# To Create an "Input For UserName"
class TextField < Gosu::TextInput
    FONT = Gosu::Font.new(20)    
    attr_reader :x, :y
    
    def initialize(window, x, y)
      super()
      
      @window, @x, @y = window, x, y
      
      # Start with a self-explanatory text in each field.
      self.text = "Name"
    end
    
    def returnName
      return self.text
    end
  
    def draw(z)
      # Change the background colour if this is the currently selected text field.
      if @window.text_input == self
        color = ACTIVE_COLOR
      else
        color = INACTIVE_COLOR
      end
      Gosu.draw_rect x - 5, y - 5, WIDTH + 2 * 5, height + 2 * 5, color, z
  
      # Draw the text
      FONT.draw self.text, x, y, z
    end
    
    def height
      FONT.height
    end
  
    # Selecting a text field with the mouse.
    def under_mouse?
      @window.mouse_x > x - 5 and @window.mouse_x < x + WIDTH + 5 and
        @window.mouse_y > y - 5 and @window.mouse_y < y + height + 5
    end    
end
  
class MainMenu < Gosu::Window

    def initialize
        super 800, 600
			self.caption = "Main Menu"
            # Setting the Images for Game Background Selection
            @background = Gosu::Image.new("../background/super_mario_animation.gif")
            @paris = Gosu::Image.new("../background/paris_2.jpeg")
            @melbourne = Gosu::Image.new("../background/melbourne.jpeg")
            @tokyo = Gosu::Image.new("../background/tokyo.jpeg")
            @london = Gosu::Image.new("../background/test.png")

			@font = Gosu::Font.new(30)
            # If Instruction Menu is crossed or not
            @insMenu = true
            # Input Field Initialization
            @text_fields = Array.new(1) { |index| TextField.new(self, 85, 320) }
            @userName  = ""
    end

    def update
    end

    def button_down(id)
        # Setting Username to Input value from the TextField
        @userName = @text_fields[0].returnName
		case id
			when Gosu::MsLeft
                self.text_input = @text_fields.find { |tf| tf.under_mouse? }
				area_clicked(mouse_x, mouse_y)
            when Gosu::KB_RETURN
				@userName = @text_fields[0].returnName
            when Gosu::KB_ESCAPE
                if self.text_input
                  self.text_input = nil
                else
                  close
                end
	    end
	end

    def draw_menu
        # Drawing Show for menu options
        draw_quad(50,50, BOTTOM_COLOR, 50, 400, TOP_COLOR, 400, 50, BOTTOM_COLOR, 400, 400, BOTTOM_COLOR, ZOrder::MENU)
    end

    def draw_menu_options
        # Drawing Menu Options
        @font.draw("Play Game >", 100 , 125, 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(80,120,0xff_7F7C82,300,120,0xff_7F7C82,300,155,0xff_7F7C82,80,155,0xff_7F7C82,ZOrder::UI)

        @font.draw("Leaderboard", 100 , 175, 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(80,170,0xff_7F7C82,300,170,0xff_7F7C82,300,205,0xff_7F7C82,80,205,0xff_7F7C82,ZOrder::UI)

        @font.draw("Sounds", 100 , 225, 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(80,220,0xff_7F7C82,300,220,0xff_7F7C82,300,255,0xff_7F7C82,80,255,0xff_7F7C82,ZOrder::UI)

        @font.draw("Exit", 100 , 275, 3, 1.0, 1.0, TEXT_COLOR)
        draw_quad(80,270,0xff_7F7C82,300,270,0xff_7F7C82,300,305,0xff_7F7C82,80,305,0xff_7F7C82,ZOrder::UI)

        # Drawing Instruction Menu
        if  @insMenu == true
            instructions = ">Use the 2 arrow keys to Go 'RIGHT' & 'LEFT' \n\n>Use the 'Space Bar' to jump\n\n>Press 'ESC' to close the game\n\n>Try to complete the course as fast as you can \n to earn a place on the leaderboard."
            draw_quad(50,100,0xff_FF5151,750,100,0xff_FF5151,750,500,0xff_FF5151,50,500,0xff_FF5151,ZOrder::INSTRUCTIONS)
            @font.draw(instructions, 75 , 175, 3, 1.0, 1.0, INSTRUCTION_COLOR)
            @font.draw("X", 50 , 100, 3, 1.0, 1.0, INSTRUCTION_COLOR)
        end

    end

    def draw_city
        @paris.draw(500,50,ZOrder::MENU)
        @melbourne.draw(500,175,ZOrder::MENU)
        @london.draw(500,300,ZOrder::MENU)
        @tokyo.draw(500,425,ZOrder::MENU)
    end

    # Performing Task Based on Area Clicked
    def area_clicked(mouse_x, mouse_y)

        # Menu Options
        if ((mouse_x >80 && mouse_x < 300)&& (mouse_y > 120 && mouse_y < 155 ))
            close
            window = CoviRun.new("../backImages/paris_2.jpeg",@userName)
            window.show
		end
        # Opening Leaderboard
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

        #Instruction Menu Closing
        if((mouse_x >50 && mouse_x < 75)&& (mouse_y > 100 && mouse_y < 125 ))
            @insMenu = false
        end

        # Selecting City and Starting Game with thee Selected Background
        if ((mouse_x >500 && mouse_x < 700)&& (mouse_y > 50 && mouse_y < 150 ))
            close
            window = CoviRun.new("../backImages/paris_2.jpeg",@userName)
            window.show
        end
        if ((mouse_x >500 && mouse_x < 700)&& (mouse_y > 175 && mouse_y < 275 ))
            close
            window = CoviRun.new("../backImages/melbourne.jpeg",@userName)
            window.show
        end
        if ((mouse_x >500 && mouse_x < 700)&& (mouse_y > 300 && mouse_y < 400 ))
            close
            window = CoviRun.new("../backImages/test.png",@userName)
            window.show
        end
        if ((mouse_x >500 && mouse_x < 700)&& (mouse_y > 425 && mouse_y < 525 ))
            close
            window = CoviRun.new("../backImages/tokyo.png",@userName)
            window.show
        end
    end

    def draw
        draw_menu
        draw_menu_options
        draw_city
        @background.draw(0,0,ZOrder::BACKGROUND)
        @font.draw("Main Menu", 150 , 75, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLUE)
        @text_fields.each { |tf| tf.draw(0) }
    end
end

window = MainMenu.new
window.show