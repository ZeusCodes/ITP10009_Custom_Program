require 'chipmunk'

class Virus
    FRICTION = 0.7
    ELASTICITY = 0.95
    SPEED_LIMIT = 500
    attr_reader :body, :shape
    def initialize(window , x , y)
        @body = CP::Body.new(10,4000)
        @body.p = CP::Vec2.new(x, y)
        @body.v_limit = SPEED_LIMIT
        
        bounds = [
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
        
        @shape = CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0, 0))
        @shape.u = FRICTION
        @shape.e = ELASTICITY
        # @width = 34
        # @height = 34
        window.space.add_body(@body)
        window.space.add_shape(@shape)
        @image = Gosu::Image.new('../obstacles2/coronavirus.png')
        @body.apply_impulse(CP::Vec2.new(rand(100000) - 50000, 100000),CP::Vec2.new(0,0))
    end

    def draw
        @image.draw_rot(@body.p.x, @body.p.y, 1, @body.angle * (180.0 / Math::PI))
    end
    
end