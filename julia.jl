using Base: Int16
using LinearAlgebra
using Printf

function abbild(p)
    # Define plane
    planeNorm = [0, 0,   1]
    planePnt  = [0, 0, 250]

    # Define ray
    origin = [0, 0, 0]

    nDotu               = dot(planeNorm, p)
    originPlaneDistance = origin - planePnt
    si                  = -dot(planeNorm, originPlaneDistance) / nDotu
    intersect           = originPlaneDistance .+ si .* p .+ planePnt

    # if p is in the picture of the camera return location, else return nothing
    if abs(intersect[1]) <= 250 && abs(intersect[2]) <= 250
        return (floor(Int16,intersect[1]),floor(Int16,intersect[2]))
    else
        return nothing
    end
end

#=
    ψ = lineplanecollision(planenorm, planepnt, pVector, origin)
    println("Intersection at $ψ")
=#

"""function is_visible(p, m, r)
    # check whether p lies within camera frame
    if abbild(p) === nothing
        return false
    end

    # check whether there is a second intersection with the sphere
    a = sum(p .^ 2)
    b = -2 * sum(p .* m)
    c = sum(m .^ 2) - r ^ 2
    # check if solution is real-valued
    if b^2 - 4*a*c > 0
        # check if closer solution corresponds to t == 1
        if abs((-b - sqrt(b^2 - 4*a*c)) / (2*a) - 1) < abs((-b + sqrt(b^2 - 4*a*c)) / (2*a) - 1)
            return false
        end
    else
        return true
    end
    return false
end
"""

function is_visible(p,m,r)
    isInImage = abbild(p)
    numberOfIntersects = intersectSphere(p,m,r)
    println(numberOfIntersects)
    if numberOfIntersects
        println("aha!")
        println("stop")
    end
    # if p is in the image of the camera and the line segment intersects with the sphere at most in 1 point
    if  isInImage !== nothing && numberOfIntersects
        return true

    # if p is not in the image of the camera or the line segment intersects with the sphere in a 2nd point
    else
        return false
    end
end

function intersectSphere(p,m,r)
    α = p[1]
    β = p[2]
    γ = p[3]
    x0 = m[1]
    y0 = m[2]
    z0 = m[3]
    a = α^2 + β^2 + γ^2
    b = -2*(α*x0+β*y0+γ*z0)
    c = (x0^2+y0^2+z0^2-r^2)
    t = 250/γ

    # catch exeption: if discriminant is negative
    try
        sqrt(b^2-4*a*c)
    catch exception
        if isa(exception, DomainError)
            #solutions = 0
            #println("No solutions")
        end
    end
    D = sqrt(b^2-4*a*c)

    # Case 1: one intersection point
    if D == 0
        solutions = 1
    
    # Case 2: two intersection points
    elseif D > 0
        solutions = 2
    end

    t1 = (-b+sqrt(b^2-4*a*c))/(2*a)
    t2 = (-b-sqrt(b^2-4*a*c))/(2*a)
    @printf("p(%d, %d, %d)\n", p[1], p[2], p[3])
    @printf("t1: %f\n", t1)
    @printf("p1: %d(%d), %d(%d), %d(%d)\n", t1, p[1], t1, p[2], t1, p[3])
    @printf("p1: %d, %d, %d\n", (t1*(p[1])), (t1*(p[2])), (t1*(p[3])))
    @printf("t2: %f\n", t2)
    @printf("p2: %d(%d), %d(%d), %d(%d)\n", t2, p[1], t2, p[2], t2, p[3])
    @printf("p2: %d, %d, %d\n", (t2*(p[1])), (t2*(p[2])), (t2*(p[3])))

    intersect1 = 1 >= round(t1, digits=3) > t
    intersect2 = 1 >= round(t2, digits=3) > t
    println(intersect1)
    println(intersect2)
    if intersect1 && intersect2
        return false
    elseif intersect1
        return true
    elseif intersect2
        return true
    end
end

function samples(x, y, b, h, m, r, dichte)
    """Projects a single Pixel onto a specific spot of the sphere and returns an array with the length floor(dichte)^9."""
    point = spherepoint(x, y, b, h)
    punkte = [spherepointtranslate(point[1], point[2], m, r)]
    #Spraying even more points around the original one, according to "dichte".
    δ = 0 + 1/dichte
    while δ <= 0.5 && δ > 0
        deltavals = [(x - δ, x, x + δ), (y - δ, y, y + δ)]
        for p1 in deltavals[1]
            for p2 in deltavals[2]
                if 0 <= p1 <= b && 0 <= p2 <= h
                    point = spherepoint(p1, p2, b, h)
                    newpoint = spherepointtranslate(point[1], point[2], m, r)
                    push!(punkte, newpoint)
                end
            end
        end
        δ += 1/dichte
        
    end 
    #@printf("punkte: p%d", punkte)
    return punkte
end

function spherepoint(x, y, b, h)
    """Converts the points into a form suiting for the function."""
    return ((x * pi) / h, (y * 2 * pi) / b)
end

function spherepointtranslate(x, y, m, r)
    """Translates the point into its sphere coordinates."""
    return (m[1] + r * sin(x) * cos(y), m[2] + r * sin(x) * sin(y), m[3] + r * cos(y))
end

function snapshot_sphere(b,h,daten,m,r,dichte)
    "
    b: takes width of image as an integer
    h: takes height of image as an integer
    daten: takes a 4-tuple of RGBA values
    m: takes center of the sphere as 3-tuple
    r: takes radius of the sphere numerical values
    dichte: takes number of samples per pixel

    returns projected image as an array of 4-tuples with resolution 500x500
     "
    println("Start by creating image plane array")
     # create image plane as 500x500 array of RGBA-tuple initialized as (0,0,0,250)
    image_plane = Array{Tuple{Float64,Float64,Float64,Float64}}(undef, 500, 500)
    
    println("Now initialise a counter array to zero")
    # initialize an array of zeroes to count mappings from each pixel
    mapping_counter = zeros(Int, 500, 500)

    println("Next, Start iterating through empty pixel array to get x,y")
    # iterate over list of pixels of original image to derive x & y cooridnates for each pixel
    for l in 0:(b*h-1)
        y = l % b
        x = floor(Int, l // b)
        @printf("p%d: (%d,%d)", l, x, y)
        @printf("\n")
       # println("get coordinates from pixel and Dichte as 4-tuple")
    # get sample of pixel as 3-tuple (x, y, z) and filter for visible pixels
        sample_array  = samples(x,y,b,h,m,r,dichte)
        #println("mapping boolean result of is_visible to each sample")
        visible_pixels = map((q) -> is_visible(q,m,r), sample_array)
        #@printf("x: p%d", x)
        #println("\n")
        #println(visible_pixels)
        visible_array = sample_array[visible_pixels]
        println("stop at breakpoint")

    # iterate over list of visible pixels
        for p in 1:length(visible_array)
        # get coordinates of intersection with image plane at (x, y, 250) and assign to individual variables
            x_axis, y_axis = abbild(visible_array[p])
        # offset x and y axes to center the image orthogonal to the z axis
            x_axes += 249
            y_axes += 249
        # counts number of mappings from sphere to image plane for each pixel
            mapping_counter[x_axis, y_axis] +=1
        # collect RGBA value of the pixel p at (x,y) in original image into an array
            previous_value = collect(image_plane[x_axis, y_axis])
        # calculate cumulative average of RGBA values of pixels mapped to the same pixel on image plane
            current_average = previous_value + (collect(daten[l]-previuous_value)/mapping_counter[x_axis, y_axis])
        # update the image plane with the current average RGBA value of pixel p
            image_plane[x_axis, y_axis] = tuple(current_average...)
            println("End inside loop")

        end
    end

    return image_plane
end


h = 5
b = 5
daten = [(0,100,200, 250), (0,100,200, 250), (0,100,200, 250), (0,100,200, 250), (0,100,200, 250), 
         (200,100,0, 250), (200,100,20, 250), (200,100,40, 250), (200,100,60, 250), (200,100,80, 250), 
         (0,100,200, 250), (0,100,200, 250), (0,100,200, 250), (0,100,200, 250), (0,100,200, 250), 
         (200,100,0, 250), (200,100,20, 250), (200,100,40, 250), (200,100,60, 250), (200,100,80, 250),
         (0,100,200, 250), (0,100,200, 250), (0,100,200, 250), (0,100,200, 250), (0,100,200, 250)]
m = (0, 0, 300)
r = 3
dichte = 100

snapshot_sphere(b,h,daten,m,r,dichte)
