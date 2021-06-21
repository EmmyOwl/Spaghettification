using LinearAlgebra
#= function abbild(p):
    # if p is in the picture of the camera
    if :
    
    # if p is not in the picture of the camera
    else:
        return nothing
    =#
    
    function lineplanecollision(planenorm::Vector, planepnt::Vector, pVector::Vector, origin::Vector)
        ndotu = dot(planenorm, pVector)
        if ndotu ≈ 0 error("no intersection or line is within plane") end
     
        w  = origin - planepnt
        si = -dot(planenorm, w) / ndotu
        ψ  = w .+ si .* pVector .+ planepnt
        return ψ
    end
     
    # Define plane
    planenorm = Float64[0, 0, 1]
    planepnt  = Float64[0, 0, 250]
     
    # Define ray
    pVector = Float64[50, -100, -10]
    origin = Float64[0,  0, 0]
     
    ψ = lineplanecollision(planenorm, planepnt, pVector, origin)
    println("Intersection at $ψ")