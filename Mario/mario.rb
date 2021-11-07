require 'gosu'
require 'chipmunk'
require_relative 'virus'
require_relative 'platform'
require_relative 'wall'
# require_relative 'Player'
require_relative 'camera'
require_relative 'hydrant'
require_relative 'terrain'
require_relative 'health'

NILHEALTH = Gosu::Color.new(0xffFF0000)
FULLHEALTH = Gosu::Color.new(0xff49FF00)

class Player
  RUN_IMPULSE = 200 
  FLY_IMPULSE = 150 
  JUMP_IMPULSE = 300000 
  AIR_JUMP_IMPULSE = 1200 
  SPEED_LIMIT = 400
  FRICTION = 0.4
  ELASTICITY = 0.2 
  attr_accessor :off_ground
  
  def initialize(window, x, y)
      @window = window
      @space = window.space
      @images = Gosu::Image.load_tiles('../heroSprite.png', 217, 184) 
      @body = CP::Body.new(50, 100 / 0.0)
      @body.p = CP::Vec2.new(x, y)
      @body.v_limit = SPEED_LIMIT
      bounds = [CP::Vec2.new(-10, -50),
          CP::Vec2.new(-10, 70),
          CP::Vec2.new(35, 70),
          CP::Vec2.new(35, -50),
          CP::Vec2.new(33, -80)]
      shape = CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0, 0))
      shape.u = FRICTION
      shape.e = ELASTICITY
      @space.add_body(@body)
      @space.add_shape(shape)
      @action = :stand
      @image_index = 0
      @off_ground = true
  end

  def x
    @body.p.x
  end

  def y
    @body.p.y
  end
  
  def draw
      case @action 
      when :run_right
          @images[@image_index].draw_rot(@body.p.x, @body.p.y, 2, 0)
          @image_index = (@image_index + 0.2) % 7 
      when :stand
          @images[2].draw_rot(@body.p.x, @body.p.y, 2, 0) 
      when :jump_left
          @images[6].draw_rot(@body.p.x, @body.p.y, 2, 0, 0.5, 0.5, -1, 1) 
      when :run_left
          @images[@image_index].draw_rot(@body.p.x, @body.p.y, 2, 0, 0.5, 0.5, -1, 1)
          @image_index = (@image_index + 0.2) % 7 
      when :jump_right
          @images[6].draw_rot(@body.p.x, @body.p.y, 2, 0) 
          @image_index = (@image_index + 0.2) % 7 
      else
          @images[2].draw_rot(@body.p.x, @body.p.y, 2, 0)
      end 
  end

  def touching?(footing)
      # x_diff = (@body.p.x - footing.body.p.x).abs
      # y_diff = (@body.p.y + 100 - footing.body.p.y).abs
      # puts (x_diff < 4000 + footing.width/2 and y_diff < 100 + footing.height/2).to_s()
      # x_diff < 4000 + footing.width/2 and y_diff < 100 + footing.height/2
      x_diff = (@body.p.x - footing.body.p.x).abs
      y_diff = (@body.p.y + 100 - footing.body.p.y).abs
      x_diff < 30 + footing.width/2 and y_diff < 5 + footing.height/2
  end

  def check_footing(things,holes_arr)
    @off_ground = true
    things.each do |thing|
      @off_ground = false if touching?(thing)
    end
    if @body.p.y > 400
      @off_ground = false
    end
    i = 0
    while i < holes_arr.length()
      if (@body.p.x-10 >= holes_arr[i] and @body.p.x <= holes_arr[i]+145 and @body.p.y > 400)
        @off_ground = true
        # puts "onTopofHole: " + @body.p.x.to_s
      end
      i+=1
    end
    if @off_ground == true
      # puts "Highest Jump: " + @body.p.y.to_s
    end
  end

  def move_right
      if @off_ground
        @action = :jump_right
        @body.apply_impulse(CP::Vec2.new(FLY_IMPULSE, 0), CP::Vec2.new(0,0))
      else
        @action = :run_right
        @body.apply_impulse(CP::Vec2.new(RUN_IMPULSE, 0), CP::Vec2.new(0,0))
      end
  end
  
  def move_left
      if @off_ground
        @action = :jump_left
        @body.apply_impulse(CP::Vec2.new(-FLY_IMPULSE, 0), CP::Vec2.new(0,0))
      else
        @action = :run_left
        @body.apply_impulse(CP::Vec2.new(-RUN_IMPULSE, 0), CP::Vec2.new(0,0))
      end
  end

  def jump
      if @off_ground
        @body.apply_impulse(CP::Vec2.new(0, -AIR_JUMP_IMPULSE),CP::Vec2.new(0,0))
      else
        @body.apply_impulse(CP::Vec2.new(0, -JUMP_IMPULSE), CP::Vec2.new(0,0))
        if @action == :left
          @action = :jump_left
        else
          @action = :jump_right
        end
      end
  end

  def stand
      @action = :stand unless off_ground
  end

  def remove_virus(virusArr , health)
      # virusArr.reject! do |virus|
      #   (virus.body.p.x - @body.p.x).abs < 75 and (virus.body.p.y - @body.p.y).abs < 102
      #   if(virus.body.p.x - @body.p.x).abs < 75 and (virus.body.p.y - @body.p.y).abs < 102
      #     @space.remove_body(virus.body)
      #     @space.remove_shape(virus.shape)
      #   end
      # end
      virusArr.reject! do |virus|
        if(Gosu.distance(@body.p.x, @body.p.y, virus.body.p.x, virus.body.p.y) < 102)
          @space.remove_body(virus.body)
          @space.remove_shape(virus.shape)
          virus.body.apply_impulse(CP::Vec2.new(2000, 0),CP::Vec2.new(0,0))
          # health -=20
        end
      end
      return health
  end

  def add_health(immuneArr , health)
    # virusArr.reject! do |virus|
    #   (virus.body.p.x - @body.p.x).abs < 75 and (virus.body.p.y - @body.p.y).abs < 102
    #   if(virus.body.p.x - @body.p.x).abs < 75 and (virus.body.p.y - @body.p.y).abs < 102
    #     @space.remove_body(virus.body)
    #     @space.remove_shape(virus.shape)
    #   end
    # end
    # immuneArr.reject! do |immune|
    #   if(Gosu.distance(@body.p.x, @body.p.y, immune.body.p.x, immune.body.p.y) < 90)
    #     # immune.body.apply_impulse(CP::Vec2.new(2000, 0),CP::Vec2.new(0,0))
    #     @space.remove_body(immune.body)
    #     @space.remove_shape(immune.shape)
    #     health +=20
    #   end
    # end
    return health
end

end

# things.each do |thing|
#   if touching?(thing) 
#       @off_ground = false 
#       puts "Can Jump"
#   end
# end

class Mario < Gosu::Window
    # Constants
    DAMPING = 0.90
    GRAVITY = 400.0
    # Optimize for Mario
    VIRUS_FREQUENCY = 0.01 #This

    attr_reader :space,:HealthBar
    def initialize(background)
        super(1000,521)
        self.caption = "Mario Run"
        @game_over = false
        @space = CP::Space.new
        @space.damping = DAMPING
        @space.gravity = CP::Vec2.new(0.0,GRAVITY)
        @background = Gosu::Image.new(background)

        # holes = [700 , 1300 , 3000]
        @terr = Terrain.new(self)
        # Optimize for Mario
        @virusArr = [] #This
        @goldArr = []
        @immuneArr = []
        @platforms = make_platforms
        # @floor = Wall.new(self, 400,500,630,20)
        @left_wall = Wall.new(self, -10, 520, 20,800)
        # @right_wall = Wall.new(self, 810,470,20,660)
        @player = Player.new(self,100,380)
        @camera = Camera.new(self, 521, 4000)
        @font = Gosu::Font.new(40)
        @HealthBar = 100
        @status = "Lost"
        @leaderBoardCheck = ""
        @start_time=(Gosu.milliseconds / 1000).to_i
        
        # del
        @name = "Pallab"
    end

    def make_platforms
      platforms = []
      (1..2).each do |row|
        (0..15).each do |column|
          x = column * 300 + 100 # places a platform every other column
          y = row * 120 + 65 # places a platform every other row
          # if row % 2 == 0
          #   x -= 150
          # end
          x += rand(100) - 50
          if(y<300)
            y -= rand(100)
          end
          # if( y > 340 )
            # y -= rand(50)
          # end
          num = rand
          if num < 0.10
            platforms.push Hydrant.new(self, 200 + rand(3200), 433)
            # direction = rand < 0.5 ? :vertical : :horizontal
            # range = 30 + rand(40)
            # platforms.push MovingPlatform.new(self, x, y, range, direction)
          elsif num < 0.80
            platforms.push Platform.new(self, x, y)
            platforms.push Platform.new(self, x+65, y)
          elsif num > 0.93
            platforms.push GoldBrick.new(self, x, y)
            @goldArr.push GoldBrick.new(self, x, y)
            @immuneArr.push Health.new(self,x+2, y-20)
          end
        end # end |column| loop
      end # end |row| loop
      # platforms.push Hydrant.new(self, 200 + rand(3200), 433)
      # platforms.push Hydrant.new(self, 200 + rand(3200), 433)
      # platforms.push GoldBrick.new(self, 100, 350)
      # @goldArr.push GoldBrick.new(self, 100, 350)
      # @immuneArr.push Health.new(self,100, 350)
      return platforms
    end
    # def make_platforms
    #     platforms = []
    #     platforms.push Platform.new(self,150,460) 
    #     platforms.push Platform.new(self,350,460) 
    #     platforms.push Platform.new(self,320,430) 
    #     platforms.push Platform.new(self,320,430) 
    #     platforms.push Platform.new(self,150,453) 
    #     platforms.push Platform.new(self,470,200) 
    #     platforms.push Platform.new(self,400,200) 
    #     platforms.push Platform.new(self,465,200) 
    #     platforms.push Platform.new(self,530,200) 
    #     platforms.push Hydrant.new(self, 200 + rand(3200), 433)
    #     platforms.push Hydrant.new(self, 200 + rand(3200), 433)
    #     platforms.push Hydrant.new(self, 200 + rand(3200), 433)
    #     platforms.push Hydrant.new(self, 200 + rand(3200), 433)

    #     return platforms
    # end

    def update
      @camera.center_on(@player, 500, 100)
      @HealthBar = @player.remove_virus(@virusArr,@HealthBar)
      @HealthBar = @player.add_health(@immuneArr,@HealthBar)
        unless @game_over
            10.times do 
                @space.step(1.0/600)
            end 
            if rand < VIRUS_FREQUENCY
                @virusArr.push Virus.new(self, 200 + rand(3200), -20)
            end

            @player.check_footing(@platforms,@terr.holes_arr)
            if button_down?(Gosu::KbRight)
                @player.move_right
            elsif button_down?(Gosu::KbLeft)
                @player.move_left
            else
                @player.stand
            end
            
            if(@HealthBar == 0)
              @game_over = true
              @status = "Lost"
            end
            if(@player.y > 650)
              @game_over = true
              @status = "Lost"
              puts "Lost"
              Cheack_Leaderboard(@name , @score)
            end
            if(@player.x > 4000)
              @game_over = true
              @status = "Won"
              puts "Won"
              Cheack_Leaderboard(@name , @score)
            end
        end
    end

    def button_down(id)
        if id == Gosu::KbSpace
          @player.jump
        end
        if id == Gosu::KbEscape
          close
        end
    end

    # def draw
    #     @background.draw(0,0,0)
    #     @virusArr.each do |virus|
    #         virus.draw
    #     end
    #     @platforms.each do |platform|
    #         platform.draw
    #     end
    #     @player.draw
    # end

    def draw
      draw_quad(10,60, NILHEALTH, 10, 75, NILHEALTH, @HealthBar*2+15, 60, FULLHEALTH, @HealthBar*2+15, 75, FULLHEALTH, 10)
        @camera.view do # draws the background tile image
          (0..3).each do |row|
            (0..1).each do |column|
              @background.draw(3200 * column,row, 0)
            end
          end
          @virusArr.each do |virus|
            virus.draw
          end
          @immuneArr.each do |health|
            health.draw
          end
          @platforms.each do |platform|
            platform.draw
          end
          @player.draw
          @terr.draw_terrain
        end # end camera.view loop
        if @game_over == false
          @score =(Gosu.milliseconds / 1000).to_i -  @start_time
          @font.draw("#{@score}", 10,20,3,1,1,0xff00ff00)
        else
          @font.draw("You have " + @status + " the Game", 250,100,3,1.5,1.5,0xff00ff00)
          @font.draw(@leaderBoardCheck, 50,150,3,1,1,0xff00ff00)
          
        end

    end


    def Cheack_Leaderboard(pname , pscore)
      puts "Checking Leaderboard: "
      leader_file = File.new("leaders.txt", "r")
      i = 0
      name = Array.new(8)
      score = Array.new(8)

      while i < 8
        name[i] = leader_file.gets()
        score[i] = leader_file.gets().to_i
        i+=1
      end

      leader_file.close()
      if(score[7]> pscore)
        name[8] = pname
        score[8] = pscore
        @leaderBoardCheck = "You have Successfully Landed a Place on the Leaderboard.\nCheck it out."
        
        score = selection_sort_score(score,name)
        name = selection_sort_name(score,name)
  
        i = 0
        while i < 9
          puts "Scores: " + score[i].to_s
          i+=1
        end
        leader_file = File.new("leaders.txt", "w")
        i = 0
        while i < 9
          leader_file.puts(name[i].to_s)
          leader_file.puts(score[i].to_s)
          i+=1
        end
        leader_file.close() 
      else
        @leaderBoardCheck = "Try to Finish the course Faster to get on the Leaderboard."
      end
    end

    def selection_sort_score(array , array2)
      current_minimum = 0
       while current_minimum < array.length - 1
        smallest_value_index = find_smallest_value_index(array, current_minimum)
        array[current_minimum], array[smallest_value_index] = array[smallest_value_index], array[current_minimum]
        array2[current_minimum], array2[smallest_value_index] = array2[smallest_value_index], array2[current_minimum]
        current_minimum += 1
      end
      return array
    end
    
    def selection_sort_name(array , array2)
      current_minimum = 0
       while current_minimum < array.length - 1
        smallest_value_index = find_smallest_value_index(array, current_minimum)
        array[current_minimum], array[smallest_value_index] = array[smallest_value_index], array[current_minimum]
        array2[current_minimum], array2[smallest_value_index] = array2[smallest_value_index], array2[current_minimum]
        current_minimum += 1
      end
      return array2
    end

    def find_smallest_value_index(array, current_minimum)
      smallest_value = array[current_minimum]
      smallest_index = current_minimum
        while current_minimum < array.length
          if (array[current_minimum] < smallest_value)
            smallest_value = array[current_minimum]
            smallest_index = current_minimum
          end
        current_minimum += 1
        end
        return smallest_index
    end 
    

  end

# window = Mario.new("../backImages/test.png")
# window.show