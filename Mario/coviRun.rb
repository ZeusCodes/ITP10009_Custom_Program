require 'gosu'
require 'chipmunk'

RUN_IMPULSE = 200 
FLY_IMPULSE = 150 
JUMP_IMPULSE = 300000 
AIR_JUMP_IMPULSE = 1200 
SPEED_LIMIT = 400
FRICTION = 0.4
ELASTICITY = 0.2 

# Player Class to Initiate a Player
class Player
    attr_accessor :body,:action,:image_index,:off_ground,:images
end

# Initializing Player Properties
def setup_player(window, x, y,player)
    window = window
    space = window.space
    player.images = Gosu::Image.load_tiles('../heroSprite.png', 217, 184) 
    player.body = CP::Body.new(50, 100 / 0.0)
    player.body.p = CP::Vec2.new(x, y)
    player.body.v_limit = SPEED_LIMIT
    bounds = [CP::Vec2.new(-10, -50), #Redering a Shape to the object to interact with the Physics System
        CP::Vec2.new(-10, 70),
        CP::Vec2.new(35, 70),
        CP::Vec2.new(35, -50),
        CP::Vec2.new(33, -80)]
    shape = CP::Shape::Poly.new(player.body, bounds, CP::Vec2.new(0, 0))
    shape.u = FRICTION
    shape.e = ELASTICITY
    space.add_body(player.body) #Adding the Player Body to the Space
    space.add_shape(shape) #Adding the Player Shape to the Space
    player.action = :stand
    player.image_index = 0
    player.off_ground = true
    return player
end

# Drawing the Player on Window
def draw_player(player)
  # Using Switch Statements to draw the image of the player
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

# Returns the X coordinate of the Player
def player_x(player)
    player.body.p.x
end

# Returns the Y coordinate of the Player
def player_y(player)
    player.body.p.y
end

# Checks if the Player is standing on top of an object by checking distance between the objects
def touching_ground?(footing,player)
    x_diff = (player.body.p.x - footing.body.p.x).abs
    y_diff = (player.body.p.y + 100 - footing.body.p.y).abs
    x_diff < 30 + footing.width/2 and y_diff < 5 + footing.height/2
end

# Checks if the Player is standing on top of an object or in Air and return T or F
def check_footing(things,holes_arr,player)
    player.off_ground = true
    things.each do |thing|
      player.off_ground = false if touching_ground?(thing,player)
    end
    if player.body.p.y > 400
      player.off_ground = false
    end
    # Checks if the Player is on top of an Pot Hole or not and Disable Jump
    i = 0
    while i < holes_arr.length()
      if (player.body.p.x-10 >= holes_arr[i] and player.body.p.x <= holes_arr[i]+145 and player.body.p.y > 400)
        player.off_ground = true
      end
      i+=1
    end
  end

# Controlling Player Movements and The consequent Image to be rendered
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

# To Remove Virus and Reduce Health on Collision
def remove_virus(virusArr , health , player,sound)
    virusArr.reject! do |virus|
      if(Gosu.distance(player.body.p.x, player.body.p.y, virus.body.p.x, virus.body.p.y) < 102)
        sound.play
        @space.remove_body(virus.body)
        @space.remove_shape(virus.shape)
        virus.body.apply_impulse(CP::Vec2.new(2000, 0),CP::Vec2.new(0,0))
        health -=15
      end
    end
    return health
end

# To Remove Vaccine and Increase Health on Collision
def add_health(immuneArr , health , player,sound)
    immuneArr.reject! do |immune|
      if(Gosu.distance(player.body.p.x, player.body.p.y, immune.body.p.x, immune.body.p.y) < 90)
        sound.play
        @space.remove_body(immune.body)
        @space.remove_shape(immune.shape)
        health +=20
      end
    end
    return health
end

# Platform Bricks
class Platform
    attr_accessor :body, :width, :height,:image
end

# Initializing Brick Properties. Method is Reused to Create normal and Gold Bricks, which initiate a vaccine on top of it
def setup_platform(window , x, y,brick , brickImage)
    space = window.space
    brick.width = 70
    brick.height = 70
    brick.body = CP::Body.new_static
    brick.body.p = CP::Vec2.new(x,y)
    bounds = [ #Redering a Shape to the object to interact with the Physics System
        CP::Vec2.new(-31, -31),
        CP::Vec2.new(-31, 31),
        CP::Vec2.new(31, 31),
        CP::Vec2.new(31, -31),
    ]
    shape = CP::Shape::Poly.new(brick.body, bounds, CP::Vec2.new(0, 0))
    shape.u = 0.7 #FRICTION
    shape.e = 0.8 #ELASTICITY
    space.add_shape(shape) #Adding the Platform Shape to the Space
    brick.image = Gosu::Image.new(brickImage)
    return brick
end

# To draw the Platforms on the Window
def draw_platform(platform)
    platform.image.draw_rot(platform.body.p.x, platform.body.p.y, 1, 0)
end

# Hydrant Class initialization
class Hydrant
    attr_accessor :body, :width, :height,:image
end

# Initializing Hydrant Properties
def setup_hydrant(window , x, y ,  hydrant)
    space = window.space
    hydrant.width = 70
    hydrant.height = 70
    hydrant.body = CP::Body.new_static
    hydrant.body.p = CP::Vec2.new(x,y)
    bounds = [ #Redering a Shape to the object to interact with the Physics System
        CP::Vec2.new(-17, -56),
        CP::Vec2.new(-17, 57),
        CP::Vec2.new(17, 57),
        CP::Vec2.new(17, -56),
    ]

    shape = CP::Shape::Poly.new(hydrant.body, bounds, CP::Vec2.new(0, 0))
    shape.u = 0.7 #FRICTION
    shape.e = 0.8 #ELASTICITY
    space.add_shape(shape) #Adding the Hydrant Shape to the Space
    hydrant.image = Gosu::Image.new('../obstacles2/climbable3.png')
    return hydrant
end

# Initializing Wall Properties. These are invisible entities meant only for boundaries around the Play area
def setup_wall(window, x, y, width, height)
    space = window.space
    body = CP::Body.new_static()
    body.p = CP::Vec2.new(x,y)
    sideBounds = (width / 2) - 5
    heightBounds = (height / 2) - 5
    bounds = [CP::Vec2.new(-sideBounds, -heightBounds), #Redering a Shape to the object to interact with the Physics System
               CP::Vec2.new(-sideBounds, heightBounds),
               CP::Vec2.new(sideBounds, heightBounds),
               CP::Vec2.new(sideBounds, -heightBounds)]
    shape = CP::Shape::Poly.new(body, bounds, CP::Vec2.new(0, 0))
    shape.u = FRICTION
    shape.e = ELASTICITY
    space.add_shape(shape) #Adding the Wall Shape to the Space
end  

# Terrain Class initialization
class Terrain
    attr_accessor :holes_arr,:hole
end

# Initializing Terrain Properties. These initiate Pot Holes and Walls to setup the boundaries of play area.
# It can be Configured to have different levels of Randomness
def setup_terrain(window,terrain)
    terrain.hole = Gosu::Image.new("../obstacles2/hole3.png",tileable: true)
    # LEVEL 1
    # terrain.holes_arr = []

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
                setup_wall(window, last_hole_at,500,space_left_to_hole,20)
                # @floor = Wall.new(window, last_hole_at,500,space_left_to_hole,20)
                last_hole_at = terrain.holes_arr[i] + 180 + 90
            else
                setup_wall(window, last_hole_at,500,180,20)
                last_hole_at += 90
            end
        end
        i += 1
        if i == terrain.holes_arr.length()
            while last_hole_at < 5000
                setup_wall(window, last_hole_at,500,180,20)
                last_hole_at += 90
            end
        end
    end
    return terrain
end

# To Draw the Terrain Holes
def draw_terrain(terrain)
    i = 0
    while i < terrain.holes_arr.length()
        terrain.hole.draw(terrain.holes_arr[i],390, 0)
        i += 1
    end
end

# Covid Virus
class Virus
    attr_accessor :body, :shape, :image
end

# Initializing Virus Properties.
def setup_virus(window , x , y , covid)
    covid.body = CP::Body.new(10,4000)
    covid.body.p = CP::Vec2.new(x, y)
    covid.body.v_limit = 500 #SPEED_LIMIT
    
    bounds = [ #Redering a Shape to the object to interact with the Physics System
        CP::Vec2.new(-21,-25),
        CP::Vec2.new(-31, -13),
        CP::Vec2.new(-31, 0),
        CP::Vec2.new(-28, 22),
        CP::Vec2.new(-11, 29),
        CP::Vec2.new(2, 32),
        CP::Vec2.new(21, 24),
        CP::Vec2.new(32, 7),
        CP::Vec2.new(32, -13),
        CP::Vec2.new(19, -22),
        CP::Vec2.new(0, -35)]
    
    covid.shape = CP::Shape::Poly.new(covid.body, bounds, CP::Vec2.new(0, 0))
    covid.shape.u =  0.7 #FRICTION
    covid.shape.e = 0.95 #ELASTICITY
    window.space.add_body(covid.body) #Adding the Virus Body to the Space
    window.space.add_shape(covid.shape) #Adding the Virus Shape to the Space
    covid.image = Gosu::Image.new('../obstacles2/coronavirus.png')
    covid.body.apply_impulse(CP::Vec2.new(rand(100000) - 50000, 100000),CP::Vec2.new(0,0))
    return covid
end

# Drawing Virus to the Window
def draw_covid(covid)
    covid.image.draw_rot(covid.body.p.x, covid.body.p.y, 1, covid.body.angle * (180.0 / Math::PI))
end

# Health Vaccine
class Health
    attr_accessor :body, :shape, :image
end

# Initializing Vaccine Properties.
def setup_vaccine(window , x , y , vaccine)
    vaccine.body = CP::Body.new(10,4000)
    vaccine.body.p = CP::Vec2.new(x, 300)
    vaccine.body.v_limit = 500 #SPEED_LIMIT
    
    bounds = [ #Redering a Shape to the object to interact with the Physics System
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

    window.space.add_body(vaccine.body) #Adding the Vaccine Body to the Space
    window.space.add_shape(vaccine.shape) #Adding the Vaccine Shape to the Space
    vaccine.image = Gosu::Image.new('../obstacles2/vaccine.png')   
    return vaccine
end

# Drawing Vaccine to the Window
def draw_vaccine(vaccine)
    vaccine.image.draw_rot(vaccine.body.p.x, vaccine.body.p.y, 1, vaccine.body.angle * (180.0 / Math::PI))
end

# Camera Struct to Store the Properties of the Camera
Cam = Struct.new(:window,:window_height,:window_width,:x_offset_max, :y_offset_max,:x_offset, :y_offset)

# To move the Camera according to the Player Movement and offset
def view(cam)
    cam.window.translate(-cam.x_offset, -cam.y_offset) do
      yield
    end
end

# To focus the Camera on the Player and set the values to move the camera
def center_on(cam , x,y, right_margin, bottom_margin)
    cam.x_offset = right_margin - cam.window_width + x 
    cam.y_offset = bottom_margin - cam.window_height + y 
    cam.x_offset = cam.x_offset_max if cam.x_offset > cam.x_offset_max
    cam.x_offset = 0 if cam.x_offset < 0
    cam.y_offset = cam.y_offset_max if cam.y_offset > cam.y_offset_max
    cam.y_offset = 0 if cam.y_offset < 0
end

# Game Class
class CoviRun < Gosu::Window
    # Constants
    DAMPING = 0.90
    GRAVITY = 400.0
    NILHEALTH = Gosu::Color.new(0xffFF0000)
    FULLHEALTH = Gosu::Color.new(0xff49FF00)
    VIRUS_FREQUENCY = 0.005 

    attr_reader :space,:HealthBar

    def initialize(background,userName) # Getting Background Image and User Name from Player
        super(1000,521)
        self.caption = "Covi Run"
        @game_over = false
        @space = CP::Space.new
        @space.damping = DAMPING #Setting Air Friction of Environment
        @space.gravity = CP::Vec2.new(0.0,GRAVITY) #Setting Gravity of Environment
        @background = Gosu::Image.new(background)

        @terr = Terrain.new() 
        @terr = setup_terrain(self , @terr)
        @virusArr = [] #Store All the Virus objects of Virus Data Type
        @goldArr = [] #Store All the Gold Brick x-coordinates
        @immuneArr = [] #Store All the Vaccine objects of Vaccine Data Type
        @platforms = make_platforms #Calling to Make Platforms and store them
        @left_wall = setup_wall(self, -10, 520, 20,800) #Left Bound of Game
        @player = setup_player(self,100,380,Player.new()) #Setting up Player 
        @cam = Cam.new(self,self.height,self.width,4000-self.width,521-self.height) 
        @font = Gosu::Font.new(40) #Font initialization for Score and End Screen
        @HealthBar = 100 #HealthBar checking if dead or not
        @status = "Lost" 
        @leaderBoardCheck = "" #To Write to Screen if you landed a leaderboard spot or not
        @start_time=(Gosu.milliseconds / 1000).to_i
        @name = userName

        # Playing and Initializing Music
        @music = Gosu::Song.new('Monkeys-Spinning-Monkeys.mp3')
        @vaccine_impact = Gosu::Sample.new('impact-sound.wav')
        @impact_sound = Gosu::Sample.new('virus-impact.wav')
        @music.play(true) 
    end

    # Method to initialze Platforms, Hydrants, Holes and consequestly the Terrain
    def make_platforms
        platforms = []
        (1..2).each do |row|
          (0..15).each do |column|
            x = column * 300 + 100 # places a platform every other column
            y = row * 120 + 65 # places a platform every other row
            if row % 2 == 0
              x -= 100
            end
            x += rand(100) - 50
            if(y<300)
              y -= rand(100)
            end

            num = rand
            hydrant = Array.new()
            if num < 0.40
              i = 0
              while i < @terr.holes_arr.length()
                hydrant_x = 200 + rand(3200)
                if((hydrant_x < @terr.holes_arr[i]-20) and (hydrant_x > @terr.holes_arr[i]-200))
                  j=0
                  if(hydrant.length() == 0)
                    platforms.push setup_hydrant(self, hydrant_x , 433  ,Hydrant.new())
                    hydrant.push hydrant_x
                  else
                    # while j < hydrant.length()
                    #   if((hydrant_x <= hydrant[i]-20) and (hydrant_x > hydrant[i]+50))
                    #     platforms.push setup_hydrant(self, hydrant_x , 433  ,Hydrant.new())
                    #     hydrant.push hydrant_x
                    #   end
                    #   j += 1
                    # end
                  end
                end
                i += 1
              end

            elsif num < 0.90
              platforms.push setup_platform(self , x ,y , Platform.new() , '../obstacles2/brick.png')
              platforms.push setup_platform(self , x+65 ,y , Platform.new() , '../obstacles2/brick.png')
            elsif num > 0.93
              platforms.push setup_platform(self , x+65 ,y , Platform.new() , '../obstacles2/gold_brick.png')
              @goldArr.push setup_platform(self , x+65 ,y , Platform.new() , '../obstacles2/gold_brick.png')
              @immuneArr.push setup_vaccine(self , x+2 , y-20 , Health.new())
            #   Health.new(self,x+2, y-20)
            end
          end # end |column| loop
        end # end |row| loop
        return platforms
    end

    def update
        # Changing camera position to keep player in center
        center_on(@cam , @player.body.p.x , @player.body.p.y , 500, 100)
        # Changing health on Collision
        @HealthBar = remove_virus(@virusArr,@HealthBar,@player,@impact_sound)
        @HealthBar = add_health(@immuneArr,@HealthBar,@player,@vaccine_impact)
          unless @game_over
              10.times do 
                  @space.step(1.0/600) #Increase the number of reders on window
              end 
              if rand < VIRUS_FREQUENCY
                  @virusArr.push setup_virus(self, 200 + rand(3200), -20 , Virus.new()) # Creating Virus at random positions above screen
              end
              check_footing(@platforms,@terr.holes_arr,@player)
              # Changing the player position
              if button_down?(Gosu::KbRight)
                  player_movements("Right",@player)
              elsif button_down?(Gosu::KbLeft)
                  player_movements("Left",@player)
              else
                  player_movements("stand",@player)
              end
              
              # Checking Player Lost or Won
              if(@HealthBar == 0)
                @game_over = true
                @status = "Lost"
              end
              if(player_y(@player) > 650)
                @game_over = true
                @status = "Lost"
              end
              if(player_x(@player) > 4030)
                @game_over = true
                @status = "Won"
                Cheack_Leaderboard(@name , @score) #Check if Score has leaderboard finish
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
        draw_quad(10,60, NILHEALTH, 10, 75, NILHEALTH, @HealthBar*2+15, 60, FULLHEALTH, @HealthBar*2+15, 75, FULLHEALTH, 10) #Draw HealthBar
          view(@cam) do # draws the background tile image
            (0..3).each do |row|
              (0..1).each do |column|
                @background.draw(3200 * column,row, 0)
              end
            end
            # Draws Virus
            @virusArr.each do |virus|
                draw_covid(virus)
            end
            # Draws Vaccine
            @immuneArr.each do |vaccine|
                draw_vaccine(vaccine)
            end
            # Draws Bricks
            @platforms.each do |platform|
                draw_platform(platform)
            end
            # Draws Player
            draw_player(@player)
            # Draws Holes
            draw_terrain(@terr)
          end # end camera view loop
          if @game_over == false
            @score =(Gosu.milliseconds / 1000).to_i -  @start_time
            # Draws Score
            @font.draw("#{@score}", 10,20,3,1,1,0xff00ff00)
          else
            # Draw Final Score and Status of Game
            @font.draw("You have " + @status + " the Game", 250,100,3,1.5,1.5,0xff00ff00)
            @font.draw(@leaderBoardCheck, 50,150,3,1,1,0xff00ff00)        
          end
    end

    # To check if Player Landed a Leaderboard finish or not
    def Cheack_Leaderboard(pname , pscore)
        leader_file = File.new("leaders.txt", "r")
        i = 0
        name = Array.new(8)
        score = Array.new(8)
  
        # Reading data from file and storing in Array
        while i < 8
          name[i] = leader_file.gets()
          score[i] = leader_file.gets().to_i
          i+=1
        end
  
        leader_file.close()
        # Checking if Score if better than the Last person's Score on Leaderboard
        if(score[7]> pscore)
          name[8] = pname
          score[8] = pscore
          @leaderBoardCheck = "You have Successfully Landed a Place on the Leaderboard.\nCheck it out."
          
          # Sorting the Arrays according to the Score
          score = selection_sort_score(score,name)
          name = selection_sort_name(score,name)
    
          leader_file = File.new("leaders.txt", "w")
          i = 0
          while i < 9
            # Printing to Text File the updated Leaderboard
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
        smallest_value_index = find_smallest_value_index(array, current_minimum) #Finding Smallest Value after the index mentioned
        array[current_minimum], array[smallest_value_index] = array[smallest_value_index], array[current_minimum] #Swapping Values of Score
        current_minimum += 1
      end
      return array
    end
    
    def selection_sort_name(array , array2)
      current_minimum = 0
       while current_minimum < array.length - 1
        smallest_value_index = find_smallest_value_index(array, current_minimum)
        array[current_minimum], array[smallest_value_index] = array[smallest_value_index], array[current_minimum] #Swapping Values of Score
        array2[current_minimum], array2[smallest_value_index] = array2[smallest_value_index], array2[current_minimum] #Swapping Values of Name
        current_minimum += 1
      end
      return array2
    end

    def find_smallest_value_index(array, current_minimum)
      smallest_value = array[current_minimum]
      smallest_index = current_minimum
      # Looping through to find Smallest value after specfied index
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

# window = CoviRun.new("../backImages/test.png")
# window.show