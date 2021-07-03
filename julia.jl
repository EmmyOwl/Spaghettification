using Base: Int16
using LinearAlgebra

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

function is_visible(p, m, r)
    # check whether p lies within camera frame
    if abbild(p) == nothing
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
end


function sample(x, y, b, h, m, r, dichte)
    return nothing
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
    # create projection plane as 500x500 array of RGBA-tuple
    image_plane = Array{Tuple{Float64,Float64,Float64,Float64}}(undef, 500, 500)

    for l in 1:(b*h)
        y = l % b
        x = floor(Int, l // b)
        
        # get samples and create array of visible pixels
        sample_array  = samples(x,y,b,h,m,r,dichte)
        visible_pixels = map((x) --> is_visible(x.m,r), sample_array)
        sample_array = sample_array[visible_pixels]

        for p in 1:length(sample_array)
            x_axis, y_axis = abbild(sample_array[p])
            mapping_counter[x_axis+249, y_axis+249] +=1
            previous_value = collect(image_plane[x_axis+249, y_axis+249])
            current_average = previous_value + (collect(daten[l]-previuous_value)/mapping_counter[x_axis+249, y_axis+249])
            image_plane[x_axis+249, y_axis+249] = tuple(current_average)
        end
    end

    return image_plane
end

"
function snapshot_sphere(b, h, daten, m, r, dichte)
    # create 2D-array of black RGBA tuples
    bildebene = fill((0, 0, 0, 255), (500, 500))

    # TODO: write function


    # flatten and return the array
    flat = fill((0,0,0,0), 500*500)
    for i = 1:500
        for j = 1:500
            flat[(i-1) * 500 + j] = bildebene[i,j]
        end
    end
    return flat

    # flatten and return the array (this flattens the wrong way, I think)
    #return vcat(bildebene...)
end
"