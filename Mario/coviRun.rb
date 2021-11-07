require 'gosu'
require 'chipmunk'
require_relative 'virus'
require_relative 'platform'
require_relative 'hydrant'

class Player
    attr_accessor :body,:action,:image_index,:off_ground,:images
end

RUN_IMPULSE = 200 
FLY_IMPULSE = 150 
JUMP_IMPULSE = 300000 
AIR_JUMP_IMPULSE = 1200 
SPEED_LIMIT = 400
FRICTION = 0.4
ELASTICITY = 0.2 

def setup_player(window, x, y,player)
    window = window
    space = window.space
    player.images = Gosu::Image.load_tiles('../heroSprite.png', 217, 184) 
    player.body = CP::Body.new(50, 100 / 0.0)
    player.body.p = CP::Vec2.new(x, y)
    player.body.v_limit = SPEED_LIMIT
    bounds = [CP::Vec2.new(-10, -50),
        CP::Vec2.new(-10, 70),
        CP::Vec2.new(35, 70),
        CP::Vec2.new(35, -50),
        CP::Vec2.new(33, -80)]
    shape = CP::Shape::Poly.new(player.body, bounds, CP::Vec2.new(0, 0))
    shape.u = FRICTION
    shape.e = ELASTICITY
    space.add_body(player.body)
    space.add_shape(shape)
    player.action = :stand
    player.image_index = 0
    player.off_ground = true
    return player
end

def draw_player(player)
    case player.action 
    when :run_right
        player.images[player.image_index].draw_rot(player.body.p.x, player.body.p.y, 2, 0)
        player.image_index = (player.image_index + 0.2) % 7 
    when :stand
        player.images[2].draw_rot(player.body.p.x, player.body.p.y, 2, 0) 
    when :jump_left
        player.images[6].draw_rot(player.body.p.x, player.body.p.y, 2, 0, 0.5, 0.5, -1, 1) 
    when :run_left
        player.images[player.image_index].draw_rot(player.body.p.x, player.body.p.y, 2, 0, 0.5, 0.5, -1, 1)
        player.image_index = (player.image_index + 0.2) % 7 
    when :jump_right
        player.images[6].draw_rot(player.body.p.x, player.body.p.y, 2, 0) 
        player.image_index = (player.image_index + 0.2) % 7 
    else
        player.images[2].draw_rot(player.body.p.x, player.body.p.y, 2, 0)
    end 
end

def player_x(player)
    player.body.p.x
end

def player_y(player)
    player.body.p.y
end

def touching_ground?(footing,player)
    x_diff = (player.body.p.x - footing.body.p.x).abs
    y_diff = (player.body.p.y + 100 - footing.body.p.y).abs
    x_diff < 30 + footing.width/2 and y_diff < 5 + footing.height/2
end

def check_footing(things,holes_arr,player)
    player.off_ground = true
    things.each do |thing|
      player.off_ground = false if touching_ground?(thing,player)
    end
    if player.body.p.y > 400
      player.off_ground = false
    end
    i = 0
    while i < holes_arr.length()
      if (player.body.p.x-10 >= holes_arr[i] and player.body.p.x <= holes_arr[i]+145 and player.body.p.y > 400)
        player.off_ground = true
      end
      i+=1
    end
  end

#   Trying Something New

def player_movements(direction,player)
    def move_right(player)
        if player.off_ground
          player.action = :jump_right
          player.body.apply_impulse(CP::Vec2.new(FLY_IMPULSE, 0), CP::Vec2.new(0,0))
        else
          player.action = :run_right
          player.body.apply_impulse(CP::Vec2.new(RUN_IMPULSE, 0), CP::Vec2.new(0,0))
        end
    end
    
    def move_left(player)
        if player.off_ground
          player.action = :jump_left
          player.body.apply_impulse(CP::Vec2.new(-FLY_IMPULSE, 0), CP::Vec2.new(0,0))
        else
          player.action = :run_left
          player.body.apply_impulse(CP::Vec2.new(-RUN_IMPULSE, 0), CP::Vec2.new(0,0))
        end
    end
    
    def jump(player)
        if player.off_ground
          player.body.apply_impulse(CP::Vec2.new(0, -AIR_JUMP_IMPULSE),CP::Vec2.new(0,0))
        else
          player.body.apply_impulse(CP::Vec2.new(0, -JUMP_IMPULSE), CP::Vec2.new(0,0))
          if player.action == :left
            player.action = :jump_left
          else
            player.action = :jump_right
          end
        end
    end

    def stand(player)
        player.action = :stand unless player.off_ground
    end

    if (direction=="Right")
        move_right(player)
    elsif (direction=="Left")
        move_left(player)
    elsif (direction=="Jump")
        jump(player)
    else
        stand(player)
    end

end
# End of Try

def remove_virus(virusArr , health , player)
    virusArr.reject! do |virus|
      if(Gosu.distance(player.body.p.x, player.body.p.y, virus.body.p.x, virus.body.p.y) < 102)
        @space.remove_body(virus.body)
        @space.remove_shape(virus.shape)
        virus.body.apply_impulse(CP::Vec2.new(2000, 0),CP::Vec2.new(0,0))
        health -=20
      end
    end
    return health
end

def add_health(immuneArr , health , player)
    immuneArr.reject! do |immune|
      if(Gosu.distance(player.body.p.x, player.body.p.y, immune.body.p.x, immune.body.p.y) < 90)
        # immune.body.apply_impulse(CP::Vec2.new(2000, 0),CP::Vec2.new(0,0))
        @space.remove_body(immune.body)
        @space.remove_shape(immune.shape)
        health +=20
      end
    end
    return health
end

# Walls
class Wall
    FRICTION = 0.3
    ELASTICITY = 0.2
    attr_reader :body, :width, :height
    def initialize(window, x, y, width, height)
        space = window.space
        @x = x
        @y = y
        @width = width
        @height = height
        @body = CP::Body.new_static()
        @body.p = CP::Vec2.new(x,y)
        sideBounds = (width / 2) - 5
        heightBounds = (height / 2) - 5
        @bounds = [CP::Vec2.new(-sideBounds, -heightBounds),
                   CP::Vec2.new(-sideBounds, heightBounds),
                   CP::Vec2.new(sideBounds, heightBounds),
                   CP::Vec2.new(sideBounds, -heightBounds)]
        @shape = CP::Shape::Poly.new(@body, @bounds, CP::Vec2.new(0, 0))
        @shape.u = FRICTION
        @shape.e = ELASTICITY
        space.add_shape(@shape)
    end    
end

# Terrain 
class Terrain
    attr_accessor :holes_arr,:hole
end

def setup_terrain(window,terrain)
    terrain.hole = Gosu::Image.new("../obstacles2/hole3.png",tileable: true)
    # LEVEL 1
    # terrain.holes_arr = []
    # @floor = Wall.new(window, 2000,500,4000,20)

    # LEVEL 2
    terrain.holes_arr = [400,950,1700,2900] 

    # LEVEL 3
    # no_of_holes = rand(1...6)
    # puts no_of_holes
    # terrain.holes_arr  = Array.new(no_of_holes)
    # terrain.holes_arr[0] = rand(50...1500)
    # i = 1
    # while i < no_of_holes 
    #     terrain.holes_arr[i] = rand((terrain.holes_arr[i-1]+400)...3500)
    #     i+=1
    # end

    i = 0
    last_hole_at = 90
    while i < terrain.holes_arr.length()
        while last_hole_at < terrain.holes_arr[i]
            if last_hole_at+90 > terrain.holes_arr[i]
                space_left_to_hole = (terrain.holes_arr[i]-last_hole_at)*2
                @floor = Wall.new(window, last_hole_at,500,space_left_to_hole,20)
                last_hole_at = terrain.holes_arr[i] + 180 + 90
            else
                @floor = Wall.new(window, last_hole_at,500,180,20)
                last_hole_at += 90
            end
        end
        i += 1
        if i == terrain.holes_arr.length()
            while last_hole_at < 5000
                @floor = Wall.new(window, last_hole_at,500,180,20)
                last_hole_at += 90
            end
        end
    end
    return terrain
end

def draw_terrain(terrain)
    i = 0
    while i < terrain.holes_arr.length()
        terrain.hole.draw(terrain.holes_arr[i],390, 0)
        i += 1
    end
end

# Health Vaccine
class Health
    attr_accessor :body, :shape, :image
end

def setup_vaccine(window , x , y , vaccine)
    vaccine.body = CP::Body.new(10,4000)
    vaccine.body.p = CP::Vec2.new(x, 300)
    vaccine.body.v_limit = 500 #SPEED_LIMIT
    
    bounds = [
        CP::Vec2.new(-19,-25),
        CP::Vec2.new(-29, -13),
        CP::Vec2.new(-29, 0),
        CP::Vec2.new(-26, 22),
        CP::Vec2.new(-9, 29),
        CP::Vec2.new(2, 32),
        CP::Vec2.new(19, 24),
        CP::Vec2.new(30, 7),
        CP::Vec2.new(30, -13),
        CP::Vec2.new(17, -22),
        CP::Vec2.new(-2, -35)]
    
    vaccine.shape = CP::Shape::Poly.new(vaccine.body, bounds, CP::Vec2.new(0, 0))
    vaccine.shape.u = 0.7 #FRICTION
    vaccine.shape.e = 0.95 #ELASTICITY

    window.space.add_body(vaccine.body)
    window.space.add_shape(vaccine.shape)
    vaccine.image = Gosu::Image.new('../obstacles2/vaccine.png')   
    # @body.apply_impulse(CP::Vec2.new(0, 0),CP::Vec2.new(0,0))
    return vaccine
end

def draw_vaccine(vaccine)
    vaccine.image.draw_rot(vaccine.body.p.x, vaccine.body.p.y, 1, vaccine.body.angle * (180.0 / Math::PI))
end

# Camera
class Camera
    attr_accessor :x_offset, :y_offset,:window_width,:window_height,:x_offset_max,:y_offset_max,:window
end

def setup_camera(cam , window, space_height, space_width)
    cam.window = window
    # @space_height = space_height
    cam.window_height = window.height
    # @space_width = space_width
    cam.window_width = window.width
    cam.x_offset_max = space_width - cam.window_width
    cam.y_offset_max = space_height - cam.window_height
    return cam
end

def view(cam)
    cam.window.translate(-cam.x_offset, -cam.y_offset) do
      yield
    end
end

def center_on(cam , x,y, right_margin, bottom_margin)
    cam.x_offset = right_margin - cam.window_width + x #player_x(player) #player.body.p.x 
    cam.y_offset = bottom_margin - cam.window_height + y #player_y(player) #player.body.p.y 
    cam.x_offset = cam.x_offset_max if cam.x_offset > cam.x_offset_max
    cam.x_offset = 0 if cam.x_offset < 0
    cam.y_offset = cam.y_offset_max if cam.y_offset > cam.y_offset_max
    cam.y_offset = 0 if cam.y_offset < 0
end

class Mario < Gosu::Window
    # Constants
    DAMPING = 0.90
    GRAVITY = 400.0
    NILHEALTH = Gosu::Color.new(0xffFF0000)
    FULLHEALTH = Gosu::Color.new(0xff49FF00)
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

        @terr = Terrain.new()
        @terr = setup_terrain(self , @terr)
        # Optimize for Mario
        @virusArr = [] 
        @goldArr = []
        @immuneArr = []
        @platforms = make_platforms
        # @floor = Wall.new(self, 400,500,630,20)
        @floor = Wall.new(self, 2000,500,4000,20)
        @left_wall = Wall.new(self, -10, 520, 20,800)
        @player = Player.new()
        @player = setup_player(self,100,380,@player)
        # @camera = Camera.new(self, 521, 4000)
        @cam = Camera.new()
        setup_camera(@cam,self, 521, 4000)
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
              @immuneArr.push setup_vaccine(self , x+2 , y-20 , Health.new())
            #   Health.new(self,x+2, y-20)
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

    def update
        center_on(@cam , @player.body.p.x , @player.body.p.y , 500, 100)
        @HealthBar = remove_virus(@virusArr,@HealthBar,@player)
        @HealthBar = add_health(@immuneArr,@HealthBar,@player)
          unless @game_over
              10.times do 
                  @space.step(1.0/600)
              end 
              if rand < VIRUS_FREQUENCY
                  @virusArr.push Virus.new(self, 200 + rand(3200), -20)
              end

            #   puts @terr.hole
              check_footing(@platforms,@terr.holes_arr,@player)
              if button_down?(Gosu::KbRight)
                #   @player.move_right
                  player_movements("Right",@player)
              elsif button_down?(Gosu::KbLeft)
                #   @player.move_left
                  player_movements("Left",@player)
              else
                  player_movements("stand",@player)
              end
              
              if(@HealthBar == 0)
                @game_over = true
                @status = "Lost"
              end
              if(player_y(@player) > 650)
                @game_over = true
                @status = "Lost"
                puts "Lost"
                Cheack_Leaderboard(@name , @score)
              end
              if(player_x(@player) > 4000)
                @game_over = true
                @status = "Won"
                puts "Won"
                Cheack_Leaderboard(@name , @score)
              end
          end
    end

    def button_down(id)
        if id == Gosu::KbSpace
            player_movements("Jump",@player)
        end
        if id == Gosu::KbEscape
          close
        end
    end

    def draw
        draw_quad(10,60, NILHEALTH, 10, 75, NILHEALTH, @HealthBar*2+15, 60, FULLHEALTH, @HealthBar*2+15, 75, FULLHEALTH, 10)
          view(@cam) do # draws the background tile image
            (0..3).each do |row|
              (0..1).each do |column|
                @background.draw(3200 * column,row, 0)
              end
            end
            @virusArr.each do |virus|
              virus.draw
            end
            @immuneArr.each do |vaccine|
                draw_vaccine(vaccine)
            #   health.draw
            end
            @platforms.each do |platform|
              platform.draw
            end
            # @player.draw
            draw_player(@player)
            draw_terrain(@terr)
          end # end camera view loop
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

window = Mario.new("../backImages/test.png")
window.show