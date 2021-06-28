using Base: Int16, Tuple
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
    
function is_visible(p,m,r)
    isInImage = abbild(p)
    numberOfIntersects = intersectSphere(p,m,r)
    # if p is in the image of the camera and the line segment intersects with the sphere at most in 1 point
    if  isInImage != nothing && numberOfIntersects == 1
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
        D = sqrt(b^2-4*a*c)
    catch exception
        if isa(exception, DomainError)
            solutions = 0
        end
    end

    # Case 1: one intersection point
    if D == 0
        solutions = 1
    
    # Case 2: two intersection points
    elseif D > 0
        solutions = 2
    end

    t_1 = (-b+sqrt(b^2-4*a*c))/(2*a)
    t_2 = (-b-sqrt(b^2-4*a*c))/(2*a)
    println(t_1)
    println(t_2)

    intersect1 = 1 >= round(t_1, digits=3) > t
    intersect2 = 1 >= round(t_2, digits=3) > t
    println(intersect1)
    println(intersect2)


    return solutions
end

####################################### MAIN #################################################
    p = [50,75,100]
    result = abbild(p)
    println(result)
    m = [50,75,250]
    r = 50
    result2 = 0
    println(result2)
    result2 = is_visible(p,m,r)
    #println(result2)