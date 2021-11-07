class Platform
    FRICTION = 0.7
    ELASTICITY = 0.8
    attr_reader :body, :width, :height
    def initialize(window , x, y)
        space = window.space
        @width = 70
        @height = 70
        @body = CP::Body.new_static
        @body.p = CP::Vec2.new(x,y)
        bounds = [
            CP::Vec2.new(-31, -31),
            CP::Vec2.new(-31, 31),
            CP::Vec2.new(31, 31),
            CP::Vec2.new(31, -31),
        ]
        shape = CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0, 0))
        shape.u = FRICTION
        shape.e = ELASTICITY
        space.add_shape(shape)
        @image = Gosu::Image.new('../obstacles2/brick.png')
    end

    def draw
        @image.draw_rot(@body.p.x, @body.p.y, 1, 0)
    end
end

class GoldBrick
    FRICTION = 0.7
    ELASTICITY = 0.8
    attr_reader :body, :width, :height
    def initialize(window , x, y)
        space = window.space
        @width = 70
        @height = 70
        @body = CP::Body.new_static
        @body.p = CP::Vec2.new(x,y)
        bounds = [
            CP::Vec2.new(-31, -31),
            CP::Vec2.new(-31, 31),
            CP::Vec2.new(31, 31),
            CP::Vec2.new(31, -31),
        ]
        shape = CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0, 0))
        shape.u = FRICTION
        shape.e = ELASTICITY
        space.add_shape(shape)
        @image = Gosu::Image.new('../obstacles2/gold_brick.png')
    end

    def draw
        @image.draw_rot(@body.p.x, @body.p.y, 1, 0)
    end
end