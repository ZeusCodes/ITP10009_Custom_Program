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