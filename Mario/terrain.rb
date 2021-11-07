require_relative 'wall'

class Terrain
    attr_accessor :holes_arr
    def initialize(window)
        @hole = Gosu::Image.new("../obstacles2/hole3.png",tileable: true)
        # LEVEL 1
        # @holes_arr = []
        # @floor = Wall.new(window, 2000,500,4000,20)

        # LEVEL 2
        @holes_arr = [400,950,1700,2900] 

        # LEVEL 3
        # no_of_holes = rand(1...6)
        # puts no_of_holes
        # @holes_arr  = Array.new(no_of_holes)
        # @holes_arr[0] = rand(50...1500)
        # i = 1
        # while i < no_of_holes 
        #     @holes_arr[i] = rand((@holes_arr[i-1]+400)...3500)
        #     i+=1
        # end

        i = 0
        last_hole_at = 90
        while i < @holes_arr.length()
            while last_hole_at < @holes_arr[i]
                if last_hole_at+90 > @holes_arr[i]
                    space_left_to_hole = (@holes_arr[i]-last_hole_at)*2
                    @floor = Wall.new(window, last_hole_at,500,space_left_to_hole,20)
                    last_hole_at = @holes_arr[i] + 180 + 90
                else
                    @floor = Wall.new(window, last_hole_at,500,180,20)
                    last_hole_at += 90
                end
            end
            i += 1
            if i == @holes_arr.length()
                while last_hole_at < 5000
                    @floor = Wall.new(window, last_hole_at,500,180,20)
                    last_hole_at += 90
                end
            end
        end
    end

    def draw_terrain
        i = 0
        while i < @holes_arr.length()
            @hole.draw(@holes_arr[i],390, 0)
            i += 1
        end
    end
end

# LOGIC OF GROUND PLACEMENT
#  350 + 350 = 700 
#  1000 - 120 = 880
#  hole radius = 180

# 90+90=180+90=270+90=360+90=  450+90(shouldnt happen)
# 500-450=50
# floors with length of 180 hence 90 on left and 90 on right