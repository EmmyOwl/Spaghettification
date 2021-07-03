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
