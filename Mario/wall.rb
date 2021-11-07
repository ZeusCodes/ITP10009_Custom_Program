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