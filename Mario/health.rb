require 'chipmunk'

class Health
    FRICTION = 0.7
    ELASTICITY = 0.95
    SPEED_LIMIT = 500
    attr_reader :body, :shape
    
    def initialize(window , x , y)
        @body = CP::Body.new(10,4000)
        @body.p = CP::Vec2.new(x, 300)
        @body.v_limit = 500 #SPEED_LIMIT
        
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
        
        @shape = CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0, 0))
        @shape.u = 0.7 #FRICTION
        @shape.e = 0.95 #ELASTICITY
        # @width = 34
        # @height = 34
        window.space.add_body(@body)
        window.space.add_shape(@shape)
        @image = Gosu::Image.new('../obstacles2/vaccine.png')
        # @body.apply_impulse(CP::Vec2.new(0, 0),CP::Vec2.new(0,0))
    end

    def draw
        @image.draw_rot(@body.p.x, @body.p.y, 1, @body.angle * (180.0 / Math::PI))
    end
    
end