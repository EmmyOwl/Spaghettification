using Base: Int16
using LinearAlgebra

function abbild(p)
    # Define plane
    planeNorm = [0,0,1]
    planePnt = [0,0,250]

    # Define ray
    origin = [0,0,0]

    nDotu = dot(planeNorm, p)
    originPlaneDistance  = origin - planePnt
    si = -dot(planeNorm, originPlaneDistance) / nDotu
    intersect = originPlaneDistance .+ si .* p .+ planePnt
    # if p is in the picture of the camera
    if (intersect[1] <= 250 && intersect[1] >= -250) && (intersect[2] <= 250 && intersect[2] >= -250)
        return (floor(Int16,intersect[1]),floor(Int16,intersect[2]))
     # if p is not in the picture of the camera
    else
        return nothing
    end
end
    
#=
    ψ = lineplanecollision(planenorm, planepnt, pVector, origin)
    println("Intersection at $ψ")
=#

    p = [50,75,100]
    result = abbild(p)
    println(result)