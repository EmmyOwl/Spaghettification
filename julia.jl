"""
File: julia.jl
Authors: Adrian Fried, Richard Schneider, Emmy Schmidt
Version: 4.1
Date: 06.07.21
Name: Sphere Projection

Description: programm to map an PNG image as a texture to a sphere in 3D vector space
             and take a photo of the sphere from a view point that gets exported to a view file
"""

using Base: Int16
using LinearAlgebra
using Printf

# takes p, a 3-tuple representing a point in 3D- vector space
# checks if point is within field of view of defined image plane from the origin perspective at (0,0,0)
# returns a 2-tuple representing the intersection of the vector from the origin to p with the image plane
# image plane dimensions: (-250 <= x < 250, -250 <= y < 250, z = 250)

function abbild(p)
    # Set plane defined by a normal vector and a point
    planeNorm = [0, 0,   1]
    planePnt  = [0, 0, 250]

    # Define ray starting point (in the direction of p)
    origin = [0, 0, 0]

    """
    Dot product vector math to find the intersect of a line and plane
    in this case the line is the vector from the origin to p and the plane is the image plane
    as defined above.
    Dot product: a .* b = |a||b|cos(θ)
    """
    nDotp               = dot(planeNorm, p)
    originPlaneDistance = origin - planePnt
    si                  = -dot(planeNorm, originPlaneDistance) / nDotp
    intersect           = originPlaneDistance .+ si .* p .+ planePnt

    # if p is in the picture of the camera return location, else return nothing
    if abs(intersect[1]) <= 250 && abs(intersect[2]) <= 250
        return (floor(Int16,intersect[1]),floor(Int16,intersect[2]))
    else
        return nothing
    end
end


function is_visible(p, m, r)
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
        return false
    end

    return true
end


function samples(x, y, b, h, m, r, dichte)
    """
    Projects a single Pixel onto a specific spot of the sphere and
    returns an array with the length floor(dichte)*8.
    """
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

    return punkte
end

function spherepoint(x, y, b, h)
    """Converts the points into a form suiting for the function."""
    return ((x * pi) / h, (y * 2 * pi) / b)
end

function spherepointtranslate(x, y, m, r)
    """Translates the point into its sphere coordinates."""
    return (m[1] + r * sin(x) * cos(y), m[2] + r * sin(x) * sin(y), m[3] + r * cos(x))
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
     # create image plane as 500x500 array of RGBA-tuple initialized as (0,0,0,250)
    image_plane = Array{Tuple{Float64,Float64,Float64,Float64}}(undef, 500, 500)

    # initialize an array of zeroes to count mappings from each pixel
    mapping_counter = zeros(Int, 500, 500)

    # iterate over list of pixels of original image to derive x & y cooridnates for each pixel
    for l in 1:(b*h)
        y = l % b
        x = floor(Int, l // b)

    # get sample of pixel as 3-tuple (x, y, z) and filter for visible pixels
        sample_array  = samples(x,y,b,h,m,r,dichte)
        visible_pixels = map((q) -> is_visible(q,m,r), sample_array)
        visible_array = sample_array[visible_pixels]

    # iterate over list of visible pixels
        for p in 1:length(visible_array)
        # get coordinates of intersection with image plane at (x, y, 250) and assign to individual variables
            x_axis, y_axis = abbild(visible_array[p])
        # offset x and y axes to center the image orthogonal to the z axis
            x_axis += 249
            y_axis += 249
        # counts number of mappings from sphere to image plane for each pixel
            mapping_counter[x_axis, y_axis] +=1
        # collect RGBA value of the pixel p at (x,y) in original image into an array
            previous_value = collect(image_plane[x_axis, y_axis])
        # calculate cumulative average of RGBA values of pixels mapped to the same pixel on image plane
            current_average = previous_value + (collect(daten[l])-previous_value)/mapping_counter[x_axis, y_axis]
        # update the image plane with the current average RGBA value of pixel p
            image_plane[x_axis, y_axis] = tuple(current_average...)
        end
    end
    println("######### IMAGE PLANE COMPLETE #########")

    return image_plane
end
